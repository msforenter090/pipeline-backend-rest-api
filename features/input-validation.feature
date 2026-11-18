@REQ-VAL-001:v1 @REQ-VAL-002:v1
Feature: Input validation
  Operands must be string numbers of at most 1000 characters, and the
  divisor of a division must not be zero. Requirements: REQ-VAL-001,
  REQ-VAL-002 (both v1).

  Background:
    Given the service is running

  # -------------------------------------------------------- invalid operand

  @REQ-VAL-001.AC-1:v1
  Scenario Outline: A missing operand is rejected
    When a client sends POST to "/api/v1/add" with the body:
      """
      <body>
      """
    Then the response status is 400
    And the error code is "INVALID_NUMBER"

    Examples:
      | body       |
      | {"b": "1"} |
      | {"a": "1"} |
      | {}         |

  @REQ-VAL-001.AC-2:v1
  Scenario Outline: An operand that is not a JSON string is rejected
    When a client sends POST to "/api/v1/add" with the body:
      """
      {"a": <a>, "b": "1"}
      """
    Then the response status is 400
    And the error code is "INVALID_NUMBER"

    Examples:
      | a          |
      | 5          |
      | 1.5        |
      | true       |
      | null       |
      | ["1"]      |
      | {"v": "1"} |

  @REQ-VAL-001.AC-3:v1
  Scenario Outline: An operand that is not a string number is rejected
    When a client requests "add" with a = "<a>" and b = "1"
    Then the response status is 400
    And the error code is "INVALID_NUMBER"

    Examples:
      | a        |
      |          |
      |  1       |
      | 1   |
      | abc      |
      | 1e5      |
      | 1,000    |
      | 1,5      |
      | .5       |
      | 5.       |
      | --1      |
      | +-1      |
      | 1.2.3    |
      | 0x10     |
      | NaN      |
      | Infinity |

  @REQ-VAL-001.AC-3:v1
  Scenario: An operand with a leading space is rejected
    When a client requests "add" with a = " 1" and b = "1"
    Then the response status is 400
    And the error code is "INVALID_NUMBER"

  @REQ-VAL-001.AC-3:v1
  Scenario: An operand with a trailing space is rejected
    When a client requests "add" with a = "1 " and b = "1"
    Then the response status is 400
    And the error code is "INVALID_NUMBER"

  @REQ-VAL-001.AC-4:v1
  Scenario Outline: Operands are limited to 1000 characters
    When a client requests "add" with a = <length> repetitions of "1" and b = "1"
    Then the response status is <status>

    Examples:
      | length | status |
      | 1000   | 200    |
      | 1001   | 400    |

  @REQ-VAL-001.AC-5:v1
  Scenario Outline: Lenient spellings of valid numbers are accepted
    When a client requests "add" with a = "<a>" and b = "0"
    Then the response status is 200
    And the result is "<result>"

    Examples:
      | a    | result |
      | +1   | 1      |
      | -0   | 0      |
      | 007  | 7      |
      | 1.50 | 1.5    |

  @REQ-VAL-001.AC-6:v1
  Scenario Outline: The error message names the rejected operand
    When a client requests "add" with a = "<a>" and b = "<b>"
    Then the response status is 400
    And the error code is "INVALID_NUMBER"
    And the field "message" contains "<operand>"

    Examples:
      | a   | b   | operand |
      | abc | 1   | a       |
      | 1   | abc | b       |

  # ------------------------------------------------------- division by zero

  @REQ-VAL-002.AC-1:v1
  Scenario: Dividing by zero is rejected
    When a client requests "divide" with a = "1" and b = "0"
    Then the response status is 400
    And the error code is "DIVISION_BY_ZERO"

  @REQ-VAL-002.AC-2:v1
  Scenario Outline: Every spelling of zero is a zero divisor
    When a client requests "divide" with a = "1" and b = "<b>"
    Then the response status is 400
    And the error code is "DIVISION_BY_ZERO"

    Examples:
      | b     |
      | -0    |
      | +0    |
      | 000   |
      | 0.000 |

  @REQ-VAL-002.AC-3:v1
  Scenario: Dividing zero by zero is rejected
    When a client requests "divide" with a = "0" and b = "0"
    Then the response status is 400
    And the error code is "DIVISION_BY_ZERO"

  @REQ-VAL-002.AC-4:v1
  Scenario: An invalid operand takes precedence over a zero divisor
    When a client requests "divide" with a = "abc" and b = "0"
    Then the response status is 400
    And the error code is "INVALID_NUMBER"

  @REQ-VAL-002.AC-5:v1
  Scenario Outline: A zero second operand is allowed for other operations
    When a client requests "<operation>" with a = "5" and b = "0"
    Then the response status is 200
    And the result is "<result>"

    Examples:
      | operation | result |
      | add       | 5      |
      | subtract  | 5      |
      | multiply  | 0      |
