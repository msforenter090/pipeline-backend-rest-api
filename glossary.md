# Glossary

Defined terms used in requirements, tests and other documentation. When a
term from this list appears in a requirement, it has exactly the meaning
given here.

Entries marked **TBD** are not fully defined yet.

## Contents

- [Product and interface](#product-and-interface)
- [Numbers and operations](#numbers-and-operations)
- [Testing and verification](#testing-and-verification)
- [Requirements engineering](#requirements-engineering)

---

## Product and interface

| Term | Definition |
|------|------------|
| **Service** | The product described by this documentation: a Spring Boot web application that calculates with string numbers. Also referred to as "the system" in requirement statements. It keeps no state between requests and has no user interface. |
| **Client** | Any program that sends HTTP requests to the service. |
| **Calculation request** | An HTTP `POST` request to `/api/v1/<operation>` with a JSON object body holding the operands `a` and `b`. See REQ-API-001. |
| **Valid calculation request** | A calculation request with a known operation and two valid operands that the service does not reject. |
| **Addition / subtraction / multiplication / division request** | A calculation request whose operation is `add`, `subtract`, `multiply` or `divide`. |
| **Result** | The string number returned in the `result` field of the response to a valid calculation request. |
| **Error response** | The response to a rejected calculation request: HTTP status 400 with a JSON body holding `error` and `message`. See REQ-API-002. |
| **Error code** | The value of the `error` field of an error response. One of the codes below. Meant for programs; stable. |
| `INVALID_NUMBER` | Error code: an operand is missing, is not a JSON string, or is not a valid string number. See REQ-VAL-001. |
| `DIVISION_BY_ZERO` | Error code: the divisor of a division request is zero. See REQ-VAL-002. |
| `MALFORMED_REQUEST` | Error code: the request body is not valid JSON, or not a JSON object. See REQ-API-002. |

## Numbers and operations

| Term | Definition |
|------|------------|
| **Operand** | One of the two input numbers of a calculation request: `a` (first) or `b` (second). |
| **String number** | A decimal number written as a JSON string: an optional sign (`+` or `-`), one or more digits `0`–`9`, and optionally a decimal point `.` followed by one or more digits. Regular expression `^[+-]?[0-9]+(\.[0-9]+)?$`. Examples: `42`, `-0.5`, `+007.10`. No whitespace, exponent or digit grouping. |
| **Valid operand** | An operand that is a string number of **1 to 1000** characters. See REQ-VAL-001. |
| **Canonical decimal string** | The single way the service writes a result: a `-` sign only for values below zero, no `+` sign, no leading zeros in the integer part (but at least one digit), and a decimal point only if a non-zero fractional digit follows, with no trailing zeros. Zero is `0`. Examples: `3`, `-2.5`, `0.01`. |
| **Dividend / divisor** | In a division request: `a` is the dividend, `b` is the divisor. The service calculates `a ÷ b`. |
| **Exact** | Without any lost or rounded digit. |
| **Fractional digits** | The digits after the decimal point. |
| **Rounding away from zero on ties** | Rounding to the nearest value with the given number of fractional digits; when the value is exactly halfway, the one further from zero is chosen (`0.5` → `1`, `-0.5` → `-1`). Also called *half up*. |

## Testing and verification

| Term | Definition |
|------|------------|
| **Unit test** | A test of one class or function without the web layer, run with the build (for example JUnit). |
| **Integration test** | A test of several parts of the service together, including the web layer, inside one test process (for example with a Spring application context). |
| **System test** | A test of the complete, running service from the outside, over HTTP only. Behavior tests run at this level. |
| **SUT** | System under test: the running service during a system test. |
| **Behavior test** | A test written as a Gherkin scenario (Given / When / Then) that checks one acceptance criterion from the outside. |
| **Step definition** | Code that executes one Gherkin step against the SUT. |
| **Verification** | Checking that the service meets its written requirements ("built it right"). |
| **Validation** | Checking that the requirements meet the users' needs ("built the right thing"). |

## Requirements engineering

| Term | Definition |
|------|------------|
| **Requirement** | A single, testable statement of what the system **shall** do or how well it shall do it. See [conventions](conventions.md). |
| **System requirement** | A requirement on the service as a whole (`SYS-*`), as the client sees it, independent of how it is implemented. |
| **Software requirement** | A detailed requirement on the service's software (`REQ-*`), usually derived from a system requirement. |
| **Acceptance criterion** | A numbered, testable condition that must hold for a requirement to be considered met (`<ID>.AC-<n>`). |
| **Parent** | The higher-level requirement that a requirement is derived from. |
| **Traceability** | The ability to follow links from a requirement to its parent, its acceptance criteria and the tests that verify them. |
| **Fit criterion** | A measurable condition that defines when a requirement is met. Expressed in this project through acceptance criteria. |
