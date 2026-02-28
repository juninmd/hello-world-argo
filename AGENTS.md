```markdown
# AGENTS.md - Guidelines for AI Coding Agents

These guidelines are designed to ensure the development of high-quality, maintainable, and robust AI coding agents within this repository. Adherence to these principles is mandatory for all development activities.

## 1. DRY (Don't Repeat Yourself)

*   All code should be modular and reusable.
*   Avoid duplicating logic or implementations across different files.
*   When a concept is used in multiple places, encapsulate it in a reusable component.
*   Favor single responsibilities for each agent component.

## 2. KISS (Keep It Simple, Stupid)

*   Code should be concise and easy to understand.
*   Minimize complexity within each file.
*   Strive for clarity and readability.
*   Avoid unnecessary abstractions or overly clever solutions.

## 3. SOLID Principles

*   **Single Responsibility Principle:** Each agent component should have a single, well-defined purpose.
*   **Open/Closed Principle:** Agent components should be open for extension but closed for modification.
*   **Liskov Substitution Principle:** Subclasses should be able to replace any underlying class without affecting the correctness of the application.
*   **Interface Segregation Principle:** Clients should not be forced to depend on methods they do not use.
*   **Dependency Inversion Principle:**  High-level modules should not depend on low-level modules; they should depend on abstractions.

## 4. YAGNI (You Aren't Gonna Need It)

*   Implement only what is currently needed for the current task.
*   Avoid adding features or functionalities that are not explicitly required.
*   Focus on delivering working functionality first.

## 5. Code Structure & File Organization

*   Each file should have a single, well-defined purpose.
*   Naming conventions: Follow a consistent naming scheme across the repository (e.g., `agent.py`, `agent.tests.py`).
*   Comments:  Provide clear and concise comments explaining the logic and reasoning behind code blocks.
*   Documentation:  Document important decisions, assumptions, and potential limitations.
*   File Size: Maximum file size: 180 lines.
*   Testing:  All code must be thoroughly tested.

## 6. Testing & Quality Assurance

*   **Unit Tests:** All code must have at least 80% code coverage through unit tests.
*   Testing Framework: Utilize a robust testing framework (e.g., `pytest`, `unittest`) consistently.
*   Test Case Design:  Tests should cover all critical scenarios and edge cases.
*   Test Coverage Report:  Generate a comprehensive test coverage report for each file.
*   Integration Tests: Consider integration tests to verify agent interactions.

## 7.  Coding Standards & Best Practices

*   Use consistent indentation and spacing.
*   Follow established style guides (e.g., PEP 8 for Python).
*   Employ error handling best practices.
*   Document API endpoints and data structures clearly.
*   Avoid magic numbers and strings.  Use named constants instead.

## 8.  Development Process

*   **Version Control:**  Use Git for version control.
*   **Code Reviews:**  All code changes should be reviewed by at least one other developer.
*   **Continuous Integration (CI):**  Implement a CI pipeline to automatically run tests and build.
*   **Documentation Updates:**  Maintain up-to-date documentation.

## 9.  Specific Considerations for AI Agents

*   **Agent State Management:**  Define clear data structures for managing agent state accurately.
*   **Input/Output Handling:**  Implement robust input validation and output processing.
*   **Decision Logic:**  Use well-defined rules and algorithms for agent decision-making.
*   **Memory Management:**  Consider efficient memory management strategies for agent memory usage.

## 10.  Data Flow & Dependency Management

*   Clearly define the data flow within each agent component.
*   Manage dependencies explicitly.
*   Avoid circular dependencies.

## 11.  Exercise for Testing (minimum):

*   All functions and classes should have at least three test cases covering different scenarios.
*   Each test case must pass with a high percentage of confidence (e.g., 90%).

## 12.  Overall Goal:  Produce high-quality, robust, and maintainable AI coding agent code.  Prioritize clarity, testability, and adherence to best practices.
```