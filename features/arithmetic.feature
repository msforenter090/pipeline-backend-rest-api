@REQ-ARI-001:v1 @REQ-ARI-002:v1 @REQ-ARI-003:v1 @REQ-ARI-004:v1
Feature: Arithmetic on string numbers
  The service adds, subtracts, multiplies and divides two string numbers and
  returns the result as a canonical decimal string. Requirements:
  REQ-ARI-001, REQ-ARI-002, REQ-ARI-003, REQ-ARI-004 (all v1).

  Background:
    Given the service is running

  # ---------------------------------------------------------------- addition

  @REQ-ARI-001.AC-1:v1
  Scenario: Adding two integers gives their sum
    When a client requests "add" with a = "2" and b = "3"
    Then the response status is 200
    And the result is "5"

  @REQ-ARI-001.AC-2:v1
  Scenario: Adding decimals gives the exact sum
    When a client requests "add" with a = "0.1" and b = "0.2"
    Then the response status is 200
    And the result is "0.3"

  @REQ-ARI-001.AC-3:v1
  Scenario Outline: Adding signed numbers gives the exact sum
    When a client requests "add" with a = "<a>" and b = "<b>"
    Then the response status is 200
    And the result is "<result>"

    Examples:
      | a    | b   | result |
      | -5   | 3   | -2     |
      | -1.5 | 1.5 | 0      |

  @REQ-ARI-001.AC-4:v1
  Scenario: Adding 30-digit numbers loses no digit
    When a client requests "add" with a = "123456789012345678901234567890" and b = "987654321098765432109876543210"
    Then the response status is 200
    And the result is "1111111110111111111011111111100"

  @REQ-ARI-001.AC-5:v1
  Scenario: Adding operands of 1000 characters gives the exact sum
    When a client requests "add" with a = 1000 repetitions of "9" and b = 1000 repetitions of "9"
    Then the response status is 200
    And the result is "1" followed by 999 repetitions of "9" followed by "8"

  # ------------------------------------------------------------- subtraction

  @REQ-ARI-002.AC-1:v1
  Scenario: Subtracting a smaller number gives a positive difference
    When a client requests "subtract" with a = "5" and b = "3"
    Then the response status is 200
    And the result is "2"

  @REQ-ARI-002.AC-2:v1
  Scenario: Subtracting a larger number gives a negative difference
    When a client requests "subtract" with a = "3" and b = "5"
    Then the response status is 200
    And the result is "-2"

  @REQ-ARI-002.AC-3:v1
  Scenario: Subtracting decimals gives the exact difference
    When a client requests "subtract" with a = "1.0" and b = "0.9"
    Then the response status is 200
    And the result is "0.1"

  @REQ-ARI-002.AC-4:v1
  Scenario: Subtracting 30-digit numbers loses no digit
    When a client requests "subtract" with a = "123456789012345678901234567890" and b = "987654321098765432109876543210"
    Then the response status is 200
    And the result is "-864197532086419753208641975320"

  @REQ-ARI-002.AC-5:v1
  Scenario: Subtracting a number from itself gives zero
    When a client requests "subtract" with a = "4.25" and b = "4.25"
    Then the response status is 200
    And the result is "0"

  # ---------------------------------------------------------- multiplication

  @REQ-ARI-003.AC-1:v1
  Scenario: Multiplying two integers gives their product
    When a client requests "multiply" with a = "2" and b = "3"
    Then the response status is 200
    And the result is "6"

  @REQ-ARI-003.AC-2:v1
  Scenario Outline: Multiplying signed numbers gives the product with the right sign
    When a client requests "multiply" with a = "<a>" and b = "<b>"
    Then the response status is 200
    And the result is "<result>"

    Examples:
      | a    | b  | result |
      | -1.5 | 2  | -3     |
      | -2   | -3 | 6      |

  @REQ-ARI-003.AC-3:v1
  Scenario: Multiplying decimals gives the exact product
    When a client requests "multiply" with a = "0.1" and b = "0.1"
    Then the response status is 200
    And the result is "0.01"

  @REQ-ARI-003.AC-4:v1
  Scenario: Multiplying by zero gives zero without a sign
    When a client requests "multiply" with a = "0" and b = "-5"
    Then the response status is 200
    And the result is "0"

  @REQ-ARI-003.AC-5:v1
  Scenario: Multiplying 30-digit numbers loses no digit
    When a client requests "multiply" with a = "123456789012345678901234567890" and b = "987654321098765432109876543210"
    Then the response status is 200
    And the result is "121932631137021795226185032733622923332237463801111263526900"

  @REQ-ARI-003.AC-6:v1
  Scenario: Multiplying operands of 1000 characters gives the exact product
    When a client requests "multiply" with a = 1000 repetitions of "9" and b = 1000 repetitions of "9"
    Then the response status is 200
    And the result is 999 repetitions of "9" followed by "8" followed by 999 repetitions of "0" followed by "1"

  # ---------------------------------------------------------------- division

  @REQ-ARI-004.AC-1:v1
  Scenario Outline: Dividing gives the exact quotient when it is short enough
    When a client requests "divide" with a = "<a>" and b = "<b>"
    Then the response status is 200
    And the result is "<result>"

    Examples:
      | a  | b | result |
      | 10 | 4 | 2.5    |
      | 1  | 8 | 0.125  |

  @REQ-ARI-004.AC-2:v1
  Scenario: A non-terminating quotient is cut to 20 fractional digits
    When a client requests "divide" with a = "1" and b = "3"
    Then the response status is 200
    And the result is "0.33333333333333333333"

  @REQ-ARI-004.AC-3:v1
  Scenario Outline: A non-terminating quotient is rounded at the 20th fractional digit
    When a client requests "divide" with a = "<a>" and b = "<b>"
    Then the response status is 200
    And the result is "<result>"

    Examples:
      | a  | b | result                  |
      | 2  | 3 | 0.66666666666666666667  |
      | -2 | 3 | -0.66666666666666666667 |

  @REQ-ARI-004.AC-4:v1
  Scenario Outline: A tie at the 21st fractional digit is rounded away from zero
    When a client requests "divide" with a = "<a>" and b = "<b>"
    Then the response status is 200
    And the result is "<result>"

    Examples:
      | a  | b                     | result                  |
      | 1  | 200000000000000000000 | 0.00000000000000000001  |
      | -1 | 200000000000000000000 | -0.00000000000000000001 |

  @REQ-ARI-004.AC-5:v1
  Scenario: A quotient below half of the last kept digit is rounded to zero
    When a client requests "divide" with a = "1" and b = "300000000000000000000"
    Then the response status is 200
    And the result is "0"

  @REQ-ARI-004.AC-6:v1
  Scenario: Dividing a 30-digit number loses no digit
    When a client requests "divide" with a = "123456789012345678901234567890" and b = "2"
    Then the response status is 200
    And the result is "61728394506172839450617283945"

  @REQ-ARI-004.AC-7:v1
  Scenario: Dividing zero gives zero
    When a client requests "divide" with a = "0" and b = "5"
    Then the response status is 200
    And the result is "0"
