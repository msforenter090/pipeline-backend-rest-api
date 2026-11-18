# Test strategy

Entries marked **TBD** are not decided yet. Values marked *proposed* must be
confirmed before this strategy is approved.

## Contents

1. [Introduction](#1-introduction)
   - 1.1 [Background](#11-background)
2. [Testing strategy overview](#2-testing-strategy-overview)
   - 2.1 [Objectives](#21-objectives)
   - 2.2 [Testing levels](#22-testing-levels)
3. [Scope](#3-scope)
   - 3.1 [In scope](#31-in-scope)
   - 3.2 [Out of scope](#32-out-of-scope)
4. [Test approach](#4-test-approach)
   - 4.1 [Entry and exit criteria](#41-entry-and-exit-criteria)
   - 4.2 [Team responsibilities](#42-team-responsibilities)
   - 4.3 [Testing environments](#43-testing-environments)
   - 4.4 [Testing tools](#44-testing-tools)
   - 4.5 [Defect management](#45-defect-management)
   - 4.6 [Behavior tests](#46-behavior-tests)
   - 4.7 [Test design techniques](#47-test-design-techniques)
   - 4.8 [Timing measurements](#48-timing-measurements)
   - 4.9 [Traceability and coverage](#49-traceability-and-coverage)
   - 4.10 [Execution and CI](#410-execution-and-ci)
5. [Release information](#5-release-information)
6. [Reporting and metrics](#6-reporting-and-metrics)
7. [Risk](#7-risk)
8. [Summary](#8-summary)

---

## 1. Introduction

This document describes how the device is verified: which test levels exist,
where they run, how behavior tests are designed and judged, and what evidence
a release needs. It applies to every requirement in this project.

Each feature has its own behavior test plan, written from the
[template](templates/behavior-test-plan.md), that applies this strategy to its
acceptance criteria. Example: [user-led](plans/user-led.md).

### 1.1 Background

The device is firmware running on a microcontroller board with a user button
and a user LED (see [glossary](../glossary.md#product-and-board)). Its
behavior is specified in two levels of requirements:

| Level | Folder | Verified by |
|-------|--------|-------------|
| System (`SYS-*`) | [`requirements/system/`](../requirements/system/SYS-LED-001.md) | Its acceptance criteria, through its software children |
| Software (`REQ-*`) | [`requirements/software/`](../requirements/software/REQ-LED-001.md) | Unit tests and behavior tests tagged with its acceptance criteria |

How requirements, acceptance criteria and test tags are written is defined
in the [conventions](../conventions.md). This strategy builds on them and does
not repeat them.

## 2. Testing strategy overview

### 2.1 Objectives

| # | Objective | Measured by ([§6](#6-reporting-and-metrics)) |
|---|-----------|---------------------------------------------|
| O-1 | Show that every acceptance criterion in a release is met, at every level its **Verif. level** field requires | Acceptance criterion coverage |
| O-2 | Verify timing limits on the real board, with measured values and margins | HIL timing margin |
| O-3 | Find defects on every pull request, before they reach the main branch | Defects found per stage |
| O-4 | Keep every test traceable to one acceptance criterion and one requirement version | Untagged and stale tests |
| O-5 | Keep test results trustworthy: no hidden retries, no ignored flaky tests | Flaky and quarantined tests |

### 2.2 Testing levels

The **Verif. level** field of an acceptance criterion names the levels at
which it must be verified. Each level means:

| Level         | What is tested | Runs on | Written as | Hardware |
|---------------|----------------|---------|------------|----------|
| `unit`        | One software module, against its acceptance criteria | PC | C unit tests | Replaced by fakes (GPIO, timer) |
| `integration` | Several modules together, through their interfaces | PC or emulator | C tests | Faked or emulated |
| `system`      | The complete firmware, from the outside | Emulator | Behavior tests (Gherkin) | Emulated board |
| `hil`         | The complete firmware on the real board | HIL rig | Behavior tests (Gherkin) | Real board, driven by test equipment |

Rules:

- A criterion is verified only when it passes at **every** level listed in its
  **Verif. level** field.
- Behavior tests are the same `.feature` files at `system` and `hil`. Only the
  step definitions differ.
- Results from a level that is **not** listed may be used for fast feedback,
  but do not count as verification evidence.
- The mapping of `system` to emulator-based behavior tests is *proposed* and
  must be agreed.

## 3. Scope

### 3.1 In scope

- Verification of `SYS-*` and `REQ-*` requirements through their acceptance
  criteria.
- Unit, integration, system and HIL tests of the firmware.
- Behavior tests written in Gherkin, and their step definitions.
- Timing measurements of firmware responses on the real board.
- The traceability report and release test evidence.

### 3.2 Out of scope

| Item | Where it is covered |
|------|---------------------|
| Validation with users ([glossary](../glossary.md#testing-and-verification)) | **TBD** |
| Requirements verified by `analysis`, `inspection` or `demonstration` | Verification plan (planned) |
| Electrical, EMC and environmental qualification of the board | Hardware qualification, **TBD** |
| Production (end-of-line) tests | Production test specification, **TBD** |
| Static analysis and coding-standard checks | Development process, **TBD** |

## 4. Test approach

### 4.1 Entry and exit criteria

**Entry** (before a release candidate is tested):

- The firmware builds without warnings, from a tagged commit.
- Every requirement in the release is `approved`.
- Every behavior test plan in the release is `approved`.
- The HIL rig passed its self-check on the day of the run.

**Exit** (before a release is made):

- Every acceptance criterion in the release passes at every level in its
  **Verif. level** field.
- No test is quarantined ([§4.5](#45-defect-management)).
- No stale tests ([§4.9](#49-traceability-and-coverage)).
- No open defects of severity `critical` or `major`.
- The release test report ([§6](#6-reporting-and-metrics)) has been reviewed
  and attached to the release.

### 4.2 Team responsibilities

| Role | Responsibility |
|------|----------------|
| Requirement owner | Acceptance criteria are testable; reviews the behavior test plan |
| Test owner | Writes the behavior test plan, scenarios and step definitions |
| Developer | Writes unit tests; fixes defects; keeps pull-request tests green |
| Reviewer | Approves the plan and the feature file; is not the test owner |
| HIL rig owner | Keeps the rig calibrated and available; runs its self-check |
| Release manager | Checks the entry and exit criteria; signs off the release test report |

One person may hold several roles, except that a reviewer never approves their
own work. **TBD:** names per role.

### 4.3 Testing environments

| Environment | Conclusive for logic | Conclusive for timing | Conclusive for electrical behavior |
|-------------|----------------------|-----------------------|------------------------------------|
| PC (unit)   | yes | no (fake timer) | no |
| Emulator    | yes | no (virtual time) | no |
| HIL rig     | yes | **yes** | partly (signal levels only) |

- Timing limits (`within 50 ms`, `≤ 15 µA`) are only verified on HIL.
  Emulator runs check the logic of a timing scenario, not the limit.
- The HIL rig drives the button input electrically, not with a mechanical
  actuator, so that contact bounce and glitches can be reproduced exactly.
- Each HIL rig has an ID. Results are always recorded with the rig ID and the
  board serial number.

### 4.4 Testing tools

| Purpose | Tool | Status |
|---------|------|--------|
| Unit test framework (C) | **TBD** (candidates: Unity, CppUTest) | open |
| Gherkin runner and step definitions | **TBD** (candidates: behave, pytest-bdd) | open |
| Emulator | **TBD** (candidates: Renode, QEMU) | open |
| Button stimulus on HIL (bounce, glitches) | **TBD:** pulse / pattern generator or rig microcontroller | open |
| LED and timing measurement on HIL | **TBD:** logic analyzer, sampling ≤ 0.1 ms | open |
| Traceability report | **TBD:** tool that reads tags and requirement files | open |
| CI system | **TBD** | open |
| Defect tracker | **TBD** | open |

Every tool used to produce verification evidence is recorded with its version
in the test evidence ([§6](#6-reporting-and-metrics)).

### 4.5 Defect management

**Severity**

| Severity | Meaning | Release |
|----------|---------|---------|
| `critical` | An acceptance criterion with Safety other than `QM` fails, or the device locks up | Blocks |
| `major` | An acceptance criterion fails | Blocks |
| `minor` | A test, step definition or rig defect; no acceptance criterion is affected | Does not block, if analyzed |

**Rules**

- A failing test is a defect in the firmware, the test or the rig until shown
  otherwise. Each failure gets an issue.
- An issue names the acceptance criterion (`REQ-LED-001.AC-1`), the firmware
  build, the environment (emulator version or rig ID) and links the run
  evidence.
- Automatic retries are **not** used to turn a failure into a pass.
- A test that passes and fails on the same firmware without changes is
  **flaky**. A flaky test is a defect.
- A flaky test may be tagged `@quarantine` for at most **10 working days**
  (*proposed*), with a link to its issue. Quarantined tests still run but do
  not block pull requests. They block a release.
- A defect is closed only after the test that found it passes on a build with
  the fix.

### 4.6 Behavior tests

**Files**

- One `.feature` file per feature, in `features/`.
- One behavior test plan per `.feature` file, in `verification/plans/`, with
  the same base name: `features/user-led.feature` →
  `verification/plans/user-led.md`.
- Tags follow [conventions §7.2](../conventions.md#7-traceability).

**Writing scenarios**

- **One acceptance criterion per scenario.** A scenario checks one outcome.
- **Black box.** Steps act on the device from the outside (button, LED, power)
  and never read internal variables.
- **Declarative.** Steps say *what* happens (`the user button is pressed and
  held for 100 ms`), not *how* the rig does it (`set pin PB3 high`).
- **Glossary terms only.** Use the terms defined in the
  [glossary](../glossary.md). Write numbers with units.
- **Exact values.** Every duration, count and limit in a step is a number.
  No *briefly*, *a while*, *quickly*.
- **Background** holds only the start state shared by every scenario in the
  file.
- **Scenario Outline** is used for boundary and partition values. Each row of
  `Examples` is one test case.
- A scenario's title states the expected behavior: *Releasing the button turns
  the LED off*, not *Test release*.

**Step definitions**

- Step definitions live in one shared library per environment
  (emulator, HIL). **TBD:** location and language.
- The same step text means the same action in every feature file. New step
  texts are added to the library before they are used.
- Steps that check a time limit measure it as described in
  [§4.8](#48-timing-measurements).

### 4.7 Test design techniques

Each behavior test plan states which techniques it uses for each acceptance
criterion, and why the chosen values were chosen.

| Technique | When to use | Example |
|-----------|-------------|---------|
| **Normal case** | Always | Press held for 100 ms turns the LED on |
| **Equivalence partitions** | Input ranges with the same expected outcome | Glitches of 1–9 ms: all must be ignored |
| **Boundary values** | Every numeric limit: just inside, at, and just outside | Press held for exactly 30 ms |
| **Tolerance bands** | Ranges where the requirement allows either outcome | 10–30 ms pulses: may or may not switch the LED |
| **Repeated events** | Event-driven requirements | Press, release, press again |
| **State and timing context** | Behavior that may differ by device state | Press right after start-up |
| **Repetition with random phase** | Timing limits | Press at a random offset to the firmware tick, 20 times |

Tolerance bands are tested only to check that the device does not crash or
lock up there. The outcome inside the band is not judged.

### 4.8 Timing measurements

| Rule | Value |
|------|-------|
| Start of the measurement | First edge on the raw button input, as defined in the [glossary](../glossary.md) (*press*, *release*) |
| End of the measurement | First edge on the output (for example the user LED) at its new level |
| Sampling resolution of the rig | **≤ 0.1 ms** (*proposed*) |
| Pass condition | Measured time **+** measurement uncertainty **≤** limit |
| Repetitions per timing test case | **20** (*proposed*), each at a random phase to the firmware tick |
| Reported value | Worst case (maximum) of all repetitions, plus the mean |

A timing test case fails if any single repetition exceeds the limit.

### 4.9 Traceability and coverage

- Every acceptance criterion whose **Verif. level** contains `system` or
  `hil` has at least one scenario tagged with it.
- Every acceptance criterion whose **Verif. level** contains `unit` has at
  least one unit test with a matching `@relation` comment.
- The traceability report is generated by tooling from the tags. It lists,
  per acceptance criterion: the tests, the levels they ran at, and the result.
- A test tagged with an older version (`:v1` while the requirement is at v2)
  is reported as **stale** and does not count as evidence.
  Versioning rules: see [conventions §9](../conventions.md#9-versioning).

### 4.10 Execution and CI

| Trigger | Unit | System (emulator) | HIL |
|---------|------|-------------------|-----|
| Every pull request | all | all | — |
| Nightly, main branch | all | all | all |
| Release candidate | all | all | all, with full repetitions |

**TBD:** HIL rig scheduling when several runs compete for one rig.

## 5. Release information

A release contains every requirement whose **Release** field names it. The
test scope of a release is the acceptance criteria of those requirements,
and the behavior test plans whose **Release** field names it.

| Release | Requirements | Behavior test plans | Planned date | Status |
|---------|--------------|---------------------|--------------|--------|
| 1.0.0 | [SYS-LED-001](../requirements/system/SYS-LED-001.md) v1, [REQ-LED-001](../requirements/software/REQ-LED-001.md) v1 | [user-led](plans/user-led.md) v1 | **TBD** | in preparation |

Release test sequence:

1. A release candidate is tagged from the main branch.
2. The entry criteria ([§4.1](#41-entry-and-exit-criteria)) are checked.
3. All tests run on the release candidate, HIL with full repetitions.
4. The release test report is produced and reviewed.
5. The release manager checks the exit criteria and signs off.

Any change to the firmware after step 1 makes a new release candidate and
restarts the sequence. **TBD:** firmware version numbering.

## 6. Reporting and metrics

**Reports**

| Report | Produced | Content | Audience |
|--------|----------|---------|----------|
| Run report | Every run | Results per test, Cucumber JSON and JUnit XML | Developers |
| Traceability report | Every nightly run and release candidate | Per acceptance criterion: tests, levels, results, stale tests | Requirement and test owners |
| Release test report | Each release candidate | Exit criteria status, metrics below, open defects, evidence links | Release manager, reviewers |

Every report records the firmware commit and build ID, the environment
(emulator version or rig ID and board serial number), tool versions, and
start and end time in UTC. Timing tests store all measured values, not only
pass/fail. Release evidence is kept for the life of the product.
**TBD:** storage location.

**Metrics**

| Metric | Definition | Release target |
|--------|------------|----------------|
| Acceptance criterion coverage | Criteria with a passing test at every required level ÷ criteria in the release | 100 % |
| Pass rate per level | Passed ÷ executed tests, per level | 100 % on the release candidate |
| HIL timing margin | (Limit − worst-case measured time) ÷ limit, per timing test case | ≥ 20 % (*proposed*) |
| Stale tests | Tests tagged with an older requirement version | 0 |
| Flaky / quarantined tests | Tests tagged `@quarantine` | 0 |
| Open defects | By severity | 0 `critical`, 0 `major` |
| Defects found per stage | Pull request, nightly, release candidate | Trend only |

## 7. Risk

| # | Risk | Impact | Mitigation |
|---|------|--------|------------|
| R-1 | Emulator timing is virtual | Emulator passes do not prove timing limits | Timing judged on HIL only ([§4.3](#43-testing-environments)) |
| R-2 | Only one HIL rig | Nightly and release runs queue; rig failure stops verification | **TBD:** second rig or reserved release slots |
| R-3 | Synthetic bounce and glitch stimulus | Real switches may behave differently | Compare stimulus with scope captures of the real button |
| R-4 | Versioning rules not defined ([conventions §9](../conventions.md#9-versioning)) | Stale tests cannot be detected reliably | Define versioning rules before release 1.0.0 |
| R-5 | GPIO pins and active levels are **TBD** | HIL step definitions cannot be finished | Close in interface documents (planned) |
| R-6 | Traceability tooling not built yet | Coverage and stale-test checks are manual | Build or choose a tool ([§4.4](#44-testing-tools)) |
| R-7 | Flaky HIL tests | Results stop being trusted | Flaky tests are defects with a time limit ([§4.5](#45-defect-management)) |

## 8. Summary

- Every acceptance criterion is verified at every level its **Verif. level**
  field names: unit tests on the PC, behavior tests in the emulator
  (`system`) and on the real board (`hil`).
- Behavior tests are Gherkin scenarios, one acceptance criterion each, tagged
  with the requirement version, and planned in one behavior test plan per
  feature file.
- Timing limits are judged on HIL only, with repeated measurements and the
  measurement uncertainty counted against the limit.
- A release ships only when coverage is complete, nothing is stale or
  quarantined, and no `critical` or `major` defect is open.
- Open items: tools, HIL rig, CI, evidence storage, versioning rules, and the
  *proposed* values in this document.
