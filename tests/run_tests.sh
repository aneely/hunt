#!/bin/bash
# Simple test runner - no external dependencies

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="$SCRIPT_DIR"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "Hunt Test Suite"
echo "==============="
echo ""

# Find all test scripts (files starting with test_ and ending in .sh)
TEST_SCRIPTS=$(find "$TESTS_DIR" -name "test_*.sh" -type f | sort)

if [ -z "$TEST_SCRIPTS" ]; then
    echo "No test files found in $TESTS_DIR"
    exit 1
fi

TOTAL_TESTS=0
TOTAL_PASSED=0
TOTAL_FAILED=0

# Run each test script
for test_script in $TEST_SCRIPTS; do
    test_name=$(basename "$test_script" .sh)
    echo -e "${BLUE}Running: $test_name${NC}"
    echo "----------------------------------------"
    
    # Make sure it's executable
    chmod +x "$test_script"
    
    # Run the test and capture exit code
    if "$test_script"; then
        echo -e "${GREEN}✓ $test_name passed${NC}"
        TOTAL_PASSED=$((TOTAL_PASSED + 1))
    else
        echo -e "${RED}✗ $test_name failed${NC}"
        TOTAL_FAILED=$((TOTAL_FAILED + 1))
    fi
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo ""
done

# Summary
echo "========================================"
echo "Overall Summary"
echo "========================================"
echo "Test files run:  $TOTAL_TESTS"
echo -e "Passed:          ${GREEN}$TOTAL_PASSED${NC}"
if [ $TOTAL_FAILED -gt 0 ]; then
    echo -e "Failed:          ${RED}$TOTAL_FAILED${NC}"
else
    echo "Failed:          $TOTAL_FAILED"
fi
echo "========================================"

if [ $TOTAL_FAILED -eq 0 ]; then
    echo -e "${GREEN}All test suites passed!${NC}"
    exit 0
else
    echo -e "${RED}Some test suites failed${NC}"
    exit 1
fi

