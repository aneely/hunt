# Hunt Test Suite

This directory contains acceptance and regression tests for the Hunt CLI tool. The test framework is a simple, dependency-free bash implementation with no external requirements.

## Test Structure

The test suite is organized into three categories:

### Unit Tests
- **`test_url_encode.sh`**: Tests for the URL encoding function (pure function)
- **`test_service_selection.sh`**: Tests for service selection validation and resolution

### Acceptance Tests
- **`test_acceptance.sh`**: End-to-end tests that run the full script with mocked browser opening

## Running Tests

### Prerequisites

**No external dependencies required!** The test framework uses only standard bash and common Unix utilities.

### Run All Tests

```bash
./tests/run_tests.sh
```

### Run Specific Test Files

```bash
./tests/test_url_encode.sh
./tests/test_service_selection.sh
./tests/test_acceptance.sh
```

## Test Helpers

The `test_helpers.sh` file provides utility functions for tests:

- `load_hunt_functions`: Loads hunt.sh functions without executing main
- `setup_mock_open`: Creates a mock `open` command that captures URLs
- `get_opened_urls`: Retrieves URLs that were "opened" by the mock
- `count_opened_urls`: Counts how many URLs were opened
- `create_test_json`: Creates temporary JSON files for testing
- `assert_equal`: Assert two values are equal
- `assert_success` / `assert_failure`: Assert command exit codes
- `assert_contains` / `assert_not_contains`: String matching
- `assert_array_length`: Array validation

## Writing New Tests

1. Create a new `test_*.sh` file in the tests directory
2. Source the helpers: `source "${SCRIPT_DIR}/test_helpers.sh"`
3. Use the test framework:

```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test_helpers.sh"

echo "Testing my feature"
echo "=================="

test_start "description of test"
result=$(some_function "input")
assert_equal "expected" "$result"

print_summary
exit $?
```

4. For tests that need mocked `open` command:
   - Call `setup_mock_open` before running the script
   - Use `get_opened_urls` or `count_opened_urls` to verify behavior
   - Call `cleanup_test` at the end

## Test Coverage

The test suite covers:

- ✅ URL encoding with various inputs (spaces, special chars, unicode)
- ✅ Service selection validation (numbers, names, case-insensitivity)
- ✅ End-to-end script execution
- ✅ Argument parsing and flag handling
- ✅ URL construction for all search engines
- ✅ Error handling (missing search term, invalid services)

## Continuous Integration

These tests can be integrated into CI/CD pipelines. The test runner script (`run_tests.sh`) exits with appropriate status codes for CI systems.

## Notes

- **No external dependencies**: Pure bash implementation
- Tests use mocked `open` command to avoid actually opening browser tabs
- Tests are compatible with bash 3.2+ (macOS default)
- All tests run in isolated temporary directories
- Simple and easy to understand - just bash scripts with assertion helpers
