<!--
  BEHAVIOR TEST PLAN TEMPLATE  (this comment is hidden in rendered Markdown)

  Copy this file to verification/plans/<feature>.md, where <feature> is the
  base name of the .feature file it covers. Replace every `<...>` and remove
  the guidance lines (starting with "Guidance:").

  Allowed values:
    Status ........ draft | review | approved | deprecated
    Environment ... emulator | hil
    Scenario state  implemented | planned | blocked
    Technique ..... normal | partition | boundary | tolerance | repeated |
                    context | random-phase   (see test-strategy.md §4.7)

  Rules:
    - One plan per .feature file, same base name.
    - Every acceptance criterion of the covered requirements appears in the
      coverage table, even if it is verified only by unit tests.
    - Scenarios are referred to by their exact title in the .feature file.
    - Planned scenarios are listed too, with state "planned".
    - Dates in UTC, ISO 8601 (YYYY-MM-DDThh:mm:ssZ).
-->

# `<feature>` · Behavior test plan

> `<One or two sentences: which behavior this plan verifies, and against which requirements.>`

## Details

| Field                 | Value                                              |
|-----------------------|----------------------------------------------------|
| **Feature file**      | `<feature>.feature`, as a relative link: `../../features/<feature>.feature` |
| **Requirements**      | `<REQ-ID>` v`<n>`, as a relative link: `../../requirements/software/<REQ-ID>.md` |
| **Plan version**      | 1                                                  |
| **Status**            | draft                                              |
| **Environments**      | `<emulator, hil>`                                  |
| **Release**           | `<x.y.z>`                                          |
| **Strategy**          | [Test strategy](../test-strategy.md)               |

## Scope

| In scope | Out of scope |
|----------|--------------|
| `<behavior verified here>` | `<behavior verified elsewhere, and where>` |

Guidance: name what is deliberately not tested here and say where it is
covered (unit tests, another feature, analysis).

## Test items

| Item | Value |
|------|-------|
| **Firmware** | `<build or version>` |
| **Board**    | `<board name and revision>` |
| **Interfaces used** | `<inputs driven and outputs observed, by glossary name>` |

## Environments and equipment

| Environment | Used for | Equipment / version |
|-------------|----------|---------------------|
| emulator    | `<logic of all scenarios>` | `<emulator and version>` |
| hil         | `<timing limits, electrical stimulus>` | `<rig ID, instruments>` |

## Coverage

One row per acceptance criterion and scenario.

| Acceptance criterion | Verif. level | Scenario | Technique | Environment | State |
|----------------------|--------------|----------|-----------|-------------|-------|
| `<REQ-ID>.AC-1` | `<unit, hil>` | `<scenario title>` | normal | `<emulator, hil>` | implemented |
| `<REQ-ID>.AC-n` | `<unit>` | — (unit tests only) | — | — | — |

## Test design

One subsection per acceptance criterion.

### `<REQ-ID>.AC-<n>`

| Item | Value |
|------|-------|
| **Criterion** | `<copied from the requirement>` |
| **Partitions** | `<input ranges and the expected outcome in each>` |
| **Boundaries** | `<limit values tested, and the values just inside/outside>` |
| **Chosen values** | `<values used in the scenarios>` |
| **Why these values** | `<reasoning>` |
| **Not tested here** | `<cases left out, and why>` |

## Stimulus and measurement

| Parameter | Value | Notes |
|-----------|-------|-------|
| `<stimulus name>` | `<shape, durations>` | `<e.g. bounce profile>` |
| Sampling resolution | `<≤ 0.1 ms>` | |
| Repetitions per timing case | `<20>` | random phase to firmware tick |

Guidance: values that differ from the [test strategy](../test-strategy.md)
must be justified here.

## Pass / fail criteria

- `<General rule, e.g. measured time + uncertainty ≤ limit, worst case of all repetitions.>`
- `<Feature-specific rules, e.g. outcome inside the tolerance band is not judged.>`

## Risks and open items

| Item | Impact | Action |
|------|--------|--------|
| `<risk or open question>` | `<what could go wrong>` | `<owner / next step>` |

## Ownership

| Field           | Value                |
|-----------------|----------------------|
| **Owner**       | `<user name>`        |
| **Created**     | `<YYYY-MM-DDThh:mm:ssZ>` |
| **Approved by** | —                    |
| **Approved at** | —                    |

## Notes

- `<optional>`
