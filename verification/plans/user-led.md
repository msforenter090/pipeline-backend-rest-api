<!--
  Behavior test plan. Template and rules:
  ../templates/behavior-test-plan.md
-->

# user-led · Behavior test plan

> Verifies from the outside that the user LED follows the user button: on
> while held, off when released, and unaffected by contact bounce and
> glitches, as required by REQ-LED-001.

## Details

| Field                 | Value                                              |
|-----------------------|----------------------------------------------------|
| **Feature file**      | [`user-led.feature`](../../features/user-led.feature) |
| **Requirements**      | [`REQ-LED-001`](../../requirements/software/REQ-LED-001.md) v1 |
| **Plan version**      | 1                                                  |
| **Status**            | draft                                              |
| **Environments**      | emulator, hil                                      |
| **Release**           | 1.0.0                                              |
| **Strategy**          | [Test strategy](../test-strategy.md)               |

## Scope

| In scope | Out of scope |
|----------|--------------|
| LED response to press and release, with timing | Debounce filter internals: unit tests of `led_ctrl` |
| Contact bounce on press and on release | LED brightness, color, current: board qualification |
| Glitches on the raw button input | Pin assignment: **TBD**, interface documents (planned) |
| Behavior shortly after start-up | Behavior during reset or brown-out: no requirement yet |

## Test items

| Item | Value |
|------|-------|
| **Firmware** | Release candidate for 1.0.0 |
| **Board**    | **TBD** |
| **Interfaces used** | Raw button input (driven), user LED (observed) |

## Environments and equipment

| Environment | Used for | Equipment / version |
|-------------|----------|---------------------|
| emulator    | Logic of all scenarios, on every pull request | **TBD** |
| hil         | Timing limits (AC-1, AC-2), bounce and glitch stimulus (AC-3) | **TBD:** rig ID, pulse generator, logic analyzer |

## Coverage

| Acceptance criterion | Verif. level | Scenario | Technique | Environment | State |
|----------------------|--------------|----------|-----------|-------------|-------|
| `REQ-LED-001.AC-1` | unit, hil | Holding the button turns the LED on | normal, random-phase | emulator, hil | implemented |
| `REQ-LED-001.AC-1` | unit, hil | Pressing the button shortly after startup turns the LED on | context | emulator, hil | implemented |
| `REQ-LED-001.AC-1` | unit, hil | A press held for exactly 30 ms turns the LED on | boundary | emulator, hil | planned |
| `REQ-LED-001.AC-2` | unit, hil | Releasing the button turns the LED off | normal, random-phase | emulator, hil | implemented |
| `REQ-LED-001.AC-2` | unit, hil | A release held for exactly 30 ms turns the LED off | boundary | emulator, hil | planned |
| `REQ-LED-001.AC-2` | unit, hil | Repeated press and release cycles | repeated | emulator, hil | planned |
| `REQ-LED-001.AC-3` | unit, hil | Contact bounce on press does not make the LED flicker | normal | emulator, hil | implemented |
| `REQ-LED-001.AC-3` | unit, hil | Contact bounce on release does not make the LED flicker | normal | emulator, hil | implemented |
| `REQ-LED-001.AC-4` | unit | Short glitches do not turn the LED on | partition, boundary | emulator | implemented |
| — (tolerance band) | — | Pulses in the tolerance band do not lock up the device | tolerance | emulator | planned |

AC-4 has `unit` as its only verification level, so its behavior test gives
fast feedback but is not verification evidence ([strategy §2.2](../test-strategy.md#22-testing-levels)).

## Test design

### REQ-LED-001.AC-1

| Item | Value |
|------|-------|
| **Criterion** | After a press held for at least 30 ms, the user LED is on no later than 50 ms after the press started. |
| **Partitions** | Press < 10 ms: ignored (AC-4). 10–30 ms: tolerance band. ≥ 30 ms: LED must turn on. |
| **Boundaries** | 30 ms hold (lower limit of the guaranteed partition). 50 ms response limit. |
| **Chosen values** | 100 ms hold (normal case). 30 ms hold (boundary, planned). |
| **Why these values** | 100 ms is well inside the partition and long enough to observe the LED after the 50 ms limit. 30 ms is the shortest press that must be shown. |
| **Not tested here** | Debounce timer behavior with a fake timer: unit tests. |

The start-up scenario checks that the button is already handled in the
first second after power-on, catching initialization-order defects (for
example the LED initialized after the button reading has started).

### REQ-LED-001.AC-2

| Item | Value |
|------|-------|
| **Criterion** | After a release held for at least 30 ms, the user LED is off no later than 50 ms after the release started. |
| **Partitions** | Same as AC-1, for the released level. |
| **Boundaries** | 30 ms released. 50 ms response limit. |
| **Chosen values** | 100 ms hold then 100 ms released (normal case). 30 ms released (boundary, planned). |
| **Why these values** | Mirror of AC-1, so that press and release are checked symmetrically. |
| **Not tested here** | — |

The repeated-cycles scenario (planned) presses and releases 10 times with
100 ms per level, to catch state that is not reset between presses.

### REQ-LED-001.AC-3

| Item | Value |
|------|-------|
| **Criterion** | Contact bounce of up to 10 ms after a press or release changes the user LED state at most once. |
| **Partitions** | Bounce ≤ 10 ms: at most one LED change. Bounce > 10 ms: not specified. |
| **Boundaries** | 10 ms bounce duration. |
| **Chosen values** | Bounce profile *B10* (see below), on press and on release. |
| **Why these values** | B10 uses the full 10 ms allowed, with gaps shorter and longer than a typical debounce tick. |
| **Not tested here** | Bounce longer than 10 ms: not specified by the requirement. |

Both scenarios check *exactly once*. This is stricter than *at most once*,
which is correct here because the button then stays at the new level for
100 ms, and AC-1 (press) or AC-2 (release) requires the LED to follow it.

### REQ-LED-001.AC-4

| Item | Value |
|------|-------|
| **Criterion** | A glitch (pulse on the button input) shorter than 10 ms does not turn the user LED on. |
| **Partitions** | < 10 ms: LED stays off. |
| **Boundaries** | 10 ms (exclusive upper limit). |
| **Chosen values** | 1 ms, 5 ms, 9 ms. |
| **Why these values** | 1 ms: very short noise. 5 ms: middle of the partition. 9 ms: just inside the limit. 10 ms is not tested, it is in the tolerance band. |
| **Not tested here** | Glitches while the button is held: no requirement yet. |

## Stimulus and measurement

| Parameter | Value | Notes |
|-----------|-------|-------|
| Bounce profile *B10* | Input toggles at 0, 0.4, 1.0, 1.8, 3.0, 4.5, 6.5, 9.0 ms, then stays at the new level | Proposed. Ends at the new level at 9.0 ms, inside 10 ms |
| Glitch | Rectangular pulse from released to pressed level, width as in `Examples` | |
| Sampling resolution | ≤ 0.1 ms | As in strategy |
| Repetitions per timing case | 20, random phase to firmware tick | As in strategy |
| "Shortly after startup" | Press starts 200 ms after power-on | Proposed; the feature file says "less than 1 second" |

## Pass / fail criteria

- Timing: measured time + measurement uncertainty ≤ 50 ms, for every one of
  the 20 repetitions. Report worst case and mean.
- Bounce: count of LED edges after the stimulus starts, over the next 100 ms.
- Glitch: the LED shows no edge from the start of the pulse until 100 ms after it.
- Tolerance band: only that the device still responds to a normal press
  afterwards. The LED outcome during the band is not judged.

## Risks and open items

| Item | Impact | Action |
|------|--------|--------|
| GPIO pins and active levels are **TBD** | HIL step definitions cannot be finished | Owner of REQ-LED-001 |
| Emulator timing is virtual | Emulator passes do not prove AC-1 / AC-2 | Timing judged on HIL only |
| Bounce profile B10 is synthetic | Real switches may bounce differently | Compare with scope captures of the real button |
| Planned scenarios not in the feature file yet | Boundaries (30 ms hold and release), repeated cycles and the tolerance band are not covered | Add before plan goes to `review` |

## Ownership

| Field           | Value                |
|-----------------|----------------------|
| **Owner**       | **TBD**              |
| **Created**     | 2026-11-12T10:00:00Z |
| **Approved by** | —                    |
| **Approved at** | —                    |

## Notes

- Scenario titles in the coverage table must match the `.feature` file
  exactly, so tooling can link them.
