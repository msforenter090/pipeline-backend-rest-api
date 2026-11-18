#!/usr/bin/env python3
"""Generate an sdoc document of behavior tests from Gherkin .feature files.

Every Scenario / Scenario Outline becomes one SCENARIO node whose Parent is
the acceptance criterion named by its tag:

    @REQ-LED-001.AC-1:v1
    Scenario: Holding the button turns the LED on

The .feature files stay the only source of the scenarios; the output is
generated on every export and is not edited or committed.

Checks (any error stops the script with exit code 1 and no output):
  - every scenario has exactly one acceptance criterion tag
  - every tag @<UID>:v<N> names an existing criterion (or, on a Feature, an
    existing requirement)
  - <N> equals the VERSION of the requirement the criterion belongs to
Warnings (printed, do not fail):
  - acceptance criteria that no scenario covers

Usage: feature_to_sdoc.py --requirements DIR --out FILE DIR|FILE...
"""

import argparse
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

# A tracing tag: @<UID>:v<N>. Tags without :v<N> (e.g. @wip) are not traced.
TRACE_TAG = re.compile(r"^@(?P<uid>[A-Za-z0-9][\w.\-]*):v(?P<version>[0-9]+)$")
KEYWORD = re.compile(
    r"^\s*(?P<kw>Feature|Background|Scenario Outline|Scenario Template|Scenario|Example|Rule):\s*(?P<name>.*)$"
)
SDOC_NODE = re.compile(r"^\[{1,2}(?P<type>[A-Z_]+)\]{1,2}$")
SDOC_FIELD = re.compile(r"^(?P<name>[A-Z_]+): (?P<value>.*)$")
SDOC_PARENT = re.compile(r"^  VALUE: (?P<uid>.+)$")


# --------------------------------------------------------------------------
# Requirements: read UIDs, versions and AC -> requirement links from .sdoc
# --------------------------------------------------------------------------

def read_requirements(root: Path):
    """Return ({requirement UID: version}, {criterion UID: requirement UID})."""
    requirements, criteria = {}, {}
    for path in sorted(root.rglob("*.sdoc")):
        node = None
        for line in path.read_text(encoding="utf-8").splitlines() + ["[END]"]:
            m = SDOC_NODE.match(line)
            if m:
                if node and node["type"] == "REQUIREMENT":
                    requirements[node["UID"]] = node.get("VERSION")
                elif node and node["type"] == "ACCEPTANCE_CRITERION":
                    criteria[node["UID"]] = node.get("parent")
                node = {"type": m["type"]}
                continue
            if node is None:
                continue
            if (f := SDOC_FIELD.match(line)) and f["name"] not in node:
                node[f["name"]] = f["value"].strip()
            elif (p := SDOC_PARENT.match(line)) and "parent" not in node:
                node["parent"] = p["uid"].strip()
    return requirements, criteria


# --------------------------------------------------------------------------
# Feature files
# --------------------------------------------------------------------------

@dataclass
class Scenario:
    path: str
    line: int
    kind: str
    name: str
    tags: list            # [(line, tag)]
    steps: list = field(default_factory=list)


@dataclass
class Feature:
    path: str
    line: int
    name: str
    tags: list
    description: list = field(default_factory=list)
    background: list = field(default_factory=list)
    scenarios: list = field(default_factory=list)


def parse_feature(path: Path) -> Feature:
    feature, current, pending = None, None, []
    for lineno, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        stripped = raw.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if stripped.startswith("@"):
            pending += [(lineno, t) for t in stripped.split()]
            continue
        m = KEYWORD.match(raw)
        if m and m["kw"] == "Feature":
            feature = Feature(str(path), lineno, m["name"].strip(), pending)
            current = feature.description
        elif m and m["kw"] == "Background":
            current = feature.background
        elif m and m["kw"] == "Rule":
            current = None
        elif m:
            kind = "Scenario Outline" if m["kw"] in ("Scenario Outline", "Scenario Template") else "Scenario"
            scenario = Scenario(str(path), lineno, kind, m["name"].strip(), pending)
            feature.scenarios.append(scenario)
            current = scenario.steps
        elif current is not None:
            current.append(stripped)
        pending = []
    if feature is None:
        raise ValueError(f"{path}: no 'Feature:' line")
    return feature


def feature_files(paths):
    for p in map(Path, paths):
        yield from sorted(p.rglob("*.feature")) if p.is_dir() else [p]


# --------------------------------------------------------------------------
# Checks
# --------------------------------------------------------------------------

def check(features, requirements, criteria):
    errors, links = [], {}   # links: id(scenario) -> (criterion UID, version)

    def tag_version_error(where, tag, uid, version):
        req = uid if uid in requirements else criteria.get(uid)
        expected = requirements.get(req)
        if expected is not None and version != expected:
            errors.append(f"{where}: tag {tag} has version {version}, "
                          f"but {req} is at VERSION {expected}")

    for feature in features:
        for line, tag in feature.tags:
            t = TRACE_TAG.match(tag)
            if not t:
                continue
            where = f"{feature.path}:{line}"
            if t["uid"] in requirements:
                tag_version_error(where, tag, t["uid"], t["version"])
            elif t["uid"] in criteria:
                errors.append(f"{where}: criterion tag {tag} belongs on a scenario, not on the Feature")
            else:
                errors.append(f"{where}: tag {tag} names no known requirement")

        for s in feature.scenarios:
            found = []
            for line, tag in s.tags:
                t = TRACE_TAG.match(tag)
                if not t:
                    continue
                where = f"{s.path}:{line}"
                if t["uid"] in criteria:
                    found.append((t["uid"], t["version"]))
                    tag_version_error(where, tag, t["uid"], t["version"])
                elif t["uid"] in requirements:
                    errors.append(f"{where}: tag {tag} names a requirement; "
                                  f"scenarios trace to acceptance criteria")
                else:
                    errors.append(f"{where}: tag {tag} names no known acceptance criterion")
            if len(found) != 1:
                errors.append(f"{s.path}:{s.line}: scenario '{s.name}' needs exactly one "
                              f"acceptance criterion tag, has {len(found)}")
            else:
                links[id(s)] = found[0]
    return errors, links


# --------------------------------------------------------------------------
# Output
# --------------------------------------------------------------------------

def multiline(lines):
    text = "\n".join(lines) if lines else "(none)"
    # A line starting with <<< would end the sdoc multiline string early.
    return ">>>\n" + re.sub(r"^<<<", " <<<", text, flags=re.M) + "\n<<<"


def write_sdoc(features, links) -> str:
    out = [
        "[DOCUMENT]",
        "TITLE: Behavior tests",
        "OPTIONS:",
        "  MARKUP: Text",
        "",
        "[GRAMMAR]",
        "IMPORT_FROM_FILE: @requirements",
    ]
    for feature in features:
        out += ["", "[[SECTION]]", f"TITLE: {feature.name or feature.path}"]
        intro = [f"Source: {feature.path}"] + feature.description
        if feature.background:
            intro += ["", "Background:"] + ["  " + s for s in feature.background]
        out += ["", "[TEXT]", "STATEMENT: " + multiline(intro)]
        for s in feature.scenarios:
            uid, version = links[id(s)]
            out += [
                "",
                "[SCENARIO]",
                f"UID: {s.path}:{s.line}",
                f"TITLE: {s.name or '(unnamed)'}",
                f"KIND: {s.kind}",
                f"LOCATION: {s.path}:{s.line}",
                f"TAG_VERSION: {version}",
                "STEPS: " + multiline(s.steps),
                "RELATIONS:",
                "- TYPE: Parent",
                f"  VALUE: {uid}",
            ]
        out += ["", "[[/SECTION]]"]
    return "\n".join(out) + "\n"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--requirements", required=True, metavar="DIR",
                    help="folder with the .sdoc requirement and criterion files")
    ap.add_argument("--out", required=True, metavar="FILE")
    ap.add_argument("inputs", nargs="+", metavar="DIR|FILE")
    args = ap.parse_args()

    out = Path(args.out)
    out.unlink(missing_ok=True)   # never leave a stale document behind

    requirements, criteria = read_requirements(Path(args.requirements))
    try:
        features = [parse_feature(f) for f in feature_files(args.inputs)]
    except ValueError as e:
        print(f"error: {e}", file=sys.stderr)
        return 1

    errors, links = check(features, requirements, criteria)
    for e in errors:
        print(f"error: {e}", file=sys.stderr)
    if errors:
        return 1

    covered = {uid for uid, _ in links.values()}
    for uid in sorted(set(criteria) - covered):
        print(f"warning: {uid} is not covered by any scenario", file=sys.stderr)

    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(write_sdoc(features, links), encoding="utf-8")
    n = sum(len(f.scenarios) for f in features)
    print(f"feature_to_sdoc: {n} scenarios from {len(features)} feature file(s) -> {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
