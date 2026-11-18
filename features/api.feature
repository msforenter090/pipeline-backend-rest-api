@REQ-API-001:v1 @REQ-API-002:v1
Feature: Calculation API
  Calculation requests are HTTP POST requests with a JSON body; results and
  errors are JSON responses in a fixed format. Requirements: REQ-API-001,
  REQ-API-002 (both v1).

  Background:
    Given the service is running

  # --------------------------------------------------------- valid requests

  @REQ-API-001.AC-1:v1
  Scenario: A valid request is answered with a JSON result
    When a client requests "add" with a = "2" and b = "3"
    Then the response status is 200
    And the response content type is "application/json"
    And the response body has exactly the fields "result"
    And the field "result" is a JSON string

  @REQ-API-001.AC-2:v1
  Scenario Outline: Each operation has its own endpoint
    When a client sends POST to "/api/v1/<operation>" with the body:
      """
      {"a": "6", "b": "3"}
      """
    Then the response status is 200
    And the result is "<result>"

    Examples:
      | operation | result |
      | add       | 9      |
      | subtract  | 3      |
      | multiply  | 18     |
      | divide    | 2      |

  @REQ-API-001.AC-3:v1
  Scenario Outline: Results are canonical decimal strings
    When a client requests "add" with a = "<a>" and b = "<b>"
    Then the response status is 200
    And the result is "<result>"

    Examples:
      | a    | b    | result |
      | 1.50 | 1.50 | 3      |
      | 007  | 0    | 7      |
      | -0   | 0    | 0      |

  @REQ-API-001.AC-4:v1
  Scenario Outline: An unknown operation is not found
    When a client sends POST to "/api/v1/<operation>" with the body:
      """
      {"a": "6", "b": "3"}
      """
    Then the response status is 404
    And the response has no result

    Examples:
      | operation |
      | power     |
      | ADD       |
      | modulo    |

  @REQ-API-001.AC-5:v1
  Scenario Outline: Methods other than POST are not allowed
    When a client sends <method> to "/api/v1/add"
    Then the response status is 405
    And the response has no result

    Examples:
      | method |
      | GET    |
      | PUT    |
      | DELETE |

  @REQ-API-001.AC-6:v1
  Scenario: Extra fields in the request body are ignored
    When a client sends POST to "/api/v1/add" with the body:
      """
      {"a": "2", "b": "3", "c": "100", "note": "ignored"}
      """
    Then the response status is 200
    And the result is "5"

  # ------------------------------------------------------- error responses

  @REQ-API-002.AC-1:v1
  Scenario: A rejected request is answered with a JSON error
    When a client requests "add" with a = "abc" and b = "3"
    Then the response status is 400
    And the response content type is "application/json"
    And the response body has exactly the fields "error, message"
    And the field "error" is a JSON string
    And the field "message" is a JSON string

  @REQ-API-002.AC-2:v1
  Scenario: The error message is not empty
    When a client requests "divide" with a = "1" and b = "0"
    Then the response status is 400
    And the field "message" is not empty

  @REQ-API-002.AC-3:v1
  Scenario Outline: A body that is not a JSON object is a malformed request
    When a client sends POST to "/api/v1/add" with the body:
      """
      <body>
      """
    Then the response status is 400
    And the error code is "MALFORMED_REQUEST"

    Examples:
      | body             |
      | not json         |
      | {"a": "1", "b":  |
      | ["1", "2"]       |
      | "1"              |

  @REQ-API-002.AC-4:v1
  Scenario: An error response carries no result
    When a client requests "add" with a = "1" and b = "1e5"
    Then the response status is 400
    And the response has no result
