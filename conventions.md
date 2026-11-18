# Documentation conventions

How requirements, acceptance criteria and behavior tests are written, named
and linked in this project. Every contributor (human or AI agent) follows
these rules.

## Contents

1. [Folder layout](#1-folder-layout)
2. [Identifiers](#2-identifiers)
3. [Requirement files](#3-requirement-files)
4. [Field values](#4-field-values)
5. [Writing a requirement](#5-writing-a-requirement)
6. [Acceptance criteria](#6-acceptance-criteria)
7. [Traceability](#7-traceability)
8. [Status and approval](#8-status-and-approval)
9. [Versioning](#9-versioning)
10. [General formatting](#10-general-formatting)

---

## 1. Folder layout

```text
doc/
├── conventions.md             This document
├── glossary.md                Defined terms
├── requirements/
│   ├── requirements.sgra      StrictDoc grammar shared by all .sdoc files
│   ├── system/                SYS-* requirements (.sdoc)
│   ├── software/              REQ-* requirements (.sdoc)
│   └── acceptance-criteria/   <ID>-AC.sdoc, in system/ and software/
├── features/                  Behavior tests (Gherkin .feature files)
├── interfaces/                (planned) Pin map, protocols, data formats
├── architecture/              (planned) Architecture description and ADRs
└── verification/
    ├── test-strategy.md       Test levels, environments, rules for all tests
    ├── plans/                 One behavior test plan per .feature file
    └── templates/             Templates (behavior test plan)
```

## 2. Identifiers

### 2.1 Requirement IDs

| Level       | Format           | Example       | Folder                  |
|-------------|------------------|---------------|-------------------------|
| System      | `SYS-<AREA>-<NNN>` | `SYS-ARI-001` | `requirements/system/`  |
| Software    | `REQ-<AREA>-<NNN>` | `REQ-ARI-001` | `requirements/software/`|

- `<AREA>` is a code from the table below.
- `<NNN>` is a three-digit number, assigned in order within the area.
- IDs **never change** and are **never reused**, even after a requirement is
  deprecated.

### 2.2 Area codes

| Code  | Area                                  |
|-------|---------------------------------------|
| `API` | HTTP interface: endpoints, request and response formats |
| `ARI` | Arithmetic operations                 |
| `PLT` | Platform and runtime constraints      |
| `VAL` | Input validation and rejected requests |

New area codes are added to this table in the same pull request that first
uses them.

### 2.3 Acceptance criterion IDs

Acceptance criteria are numbered within their requirement:

```text
<REQUIREMENT-ID>.AC-<n>        e.g. REQ-ARI-001.AC-4
```

AC numbers are **never reused** within a requirement. A removed criterion
leaves a gap.

## 3. Requirement files

- **One requirement per file.**
- File name = requirement ID: `requirements/software/REQ-ARI-001.sdoc`.
- Its acceptance criteria are in
  `requirements/acceptance-criteria/software/REQ-ARI-001-AC.sdoc`.
- StrictDoc format, using the grammar in `requirements/requirements.sgra`.
  **TBD:** the section table below still describes the earlier Markdown
  format; the grammar is authoritative.
- Sections appear in this order:

| # | Section                 | Required |
|---|-------------------------|----------|
| 1 | Title `# <ID> · <name>` | yes      |
| 2 | Requirement statement (quote block) | yes |
| 3 | `## Details`            | yes      |
| 4 | `## Acceptance criteria`| yes      |
| 5 | `## Traceability`       | yes      |
| 6 | `## Ownership`          | yes      |
| 7 | `## Rationale`          | yes      |
| 8 | `## Notes`              | optional |

Use [`REQ-ARI-004.sdoc`](requirements/software/REQ-ARI-004.sdoc) as the reference
example.

## 4. Field values

| Field            | Allowed values                                          |
|------------------|---------------------------------------------------------|
| **Type**         | `functional` · `non-functional` · `constraint`          |
| **Level**        | `stakeholder` · `system` · `software`                   |
| **Status**       | `draft` · `review` · `approved` · `deprecated`          |
| **Priority**     | `high` · `medium` · `low`                               |
| **Safety**       | `QM` · `ASIL A`–`ASIL D` · `SIL 1`–`SIL 4`              |
| **Verification** | `test` · `analysis` · `inspection` · `demonstration`    |
| **Verif. level** | `unit` · `integration` · `system`                       |
| **Component**    | A module name from the architecture, in backticks       |
| **Tags**         | Lowercase, hyphenated, in backticks                     |

## 5. Writing a requirement

### 5.1 Keywords

| Keyword        | Meaning                         |
|----------------|---------------------------------|
| **shall**      | Mandatory                       |
| **should**     | Recommended, deviation must be justified |
| **may**        | Optional                        |

Write the keyword in bold in the requirement statement.

### 5.2 Sentence patterns (EARS)

| Pattern       | Template                                              |
|---------------|-------------------------------------------------------|
| Ubiquitous    | The `<system>` **shall** `<response>`.                |
| Event-driven  | When `<trigger>`, the `<system>` **shall** `<response>`. |
| State-driven  | While `<state>`, the `<system>` **shall** `<response>`. |
| Unwanted      | If `<condition>`, then the `<system>` **shall** `<response>`. |
| Optional      | Where `<feature>`, the `<system>` **shall** `<response>`. |

### 5.3 Rules

- One **shall** per requirement.
- Every requirement is **measurable**: state limits with numbers and units
  (`at most 20 fractional digits`, `≤ 1000 characters`). Put the limit values in bold.
- State **what**, not **how**. Design belongs in the architecture documents.
- Use terms defined in the [glossary](glossary.md). Add new terms there first.
- Avoid vague words: *fast, quickly, user-friendly, robust, appropriate,
  as soon as possible, etc., and/or, normally, if possible*.

## 6. Acceptance criteria

- Every requirement has at least one acceptance criterion.
- Each criterion is a single, testable statement, written in a table:

  | ID | Criterion | Verif. level |
  |----|-----------|--------------|

- Cover the normal case **and** the edge and error cases (invalid input,
  repeated events, boundaries).
- Criteria describe the expected outcome, not test steps. Test steps belong
  in the behavior tests.

## 7. Traceability

### 7.1 Direction of links

```text
SYS-ARI-001  ◄── parent ──  REQ-ARI-001.AC-n  ◄── tag ──  behavior / unit tests
```

- Requirements link **upward** to their parent (`Parent` field).
- Tests link **upward** to acceptance criteria.
- Requirements **do not list** their children or their tests. These lists
  are generated by tooling.

### 7.2 Tag formats

| Where              | Format                                       |
|--------------------|----------------------------------------------|
| Gherkin feature    | `@REQ-ARI-001:v1` on the `Feature`           |
| Gherkin scenario   | `@REQ-ARI-001.AC-1:v1` on each `Scenario`    |
| Java test          | `// @relation(REQ-ARI-001.AC-1:v1)` above the test method |

- Every scenario carries exactly one acceptance criterion tag.
- One acceptance criterion may be verified by any number of scenarios and
  unit tests, in any number of files.

## 8. Status and approval

```text
draft ──► review ──► approved ──► deprecated
            ▲            │
            └────────────┘   (change requested)
```

- `draft`: being written; may change freely.
- `review`: open pull request; waiting for approval.
- `approved`: reviewed and accepted. **Approved by** and **Approved at** are
  filled in at this point.
- `deprecated`: no longer valid. Add a note pointing to the replacing
  requirement, if any. The file is kept.

## 9. Versioning

Each requirement carries a **Version** field, and test tags carry the
version they were written against (`:v1`).

The rules for when and how versions change are **to be defined**.

## 10. General formatting

- Dates and times in UTC, ISO 8601: `2026-11-11T08:00:00Z`.
- People are referred to by user name (`j.doe`).
- Links between documents are relative (`../system/SYS-ARI-001.sdoc`).
