#!/bin/bash
# Simple test framework helpers - no external dependencies

# Test state tracking
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0
CURRENT_TEST=""
TEST_OUTPUT=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Start a test
test_start() {
    CURRENT_TEST="$1"
    TEST_COUNT=$((TEST_COUNT + 1))
    echo -n "  Test $TEST_COUNT: $CURRENT_TEST ... "
}

# Assert two values are equal
assert_equal() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"
    
    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}PASS${NC}"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "    Expected: '$expected'"
        echo "    Actual:   '$actual'"
        if [ -n "$message" ]; then
            echo "    $message"
        fi
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
}

# Assert a command succeeds (exit code 0)
assert_success() {
    local cmd="$1"
    local message="${2:-}"
    
    if eval "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        if [ -n "$message" ]; then
            echo "    $message"
        fi
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
}

# Assert a command fails (non-zero exit code)
assert_failure() {
    local cmd="$1"
    local message="${2:-}"
    
    if ! eval "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        if [ -n "$message" ]; then
            echo "    $message"
        fi
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
}

# Assert a string contains a substring
assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        echo -e "${GREEN}PASS${NC}"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "    String does not contain: '$needle'"
        echo "    In: '$haystack'"
        if [ -n "$message" ]; then
            echo "    $message"
        fi
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
}

# Assert a string does NOT contain a substring
assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-}"
    
    if [[ "$haystack" != *"$needle"* ]]; then
        echo -e "${GREEN}PASS${NC}"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "    String unexpectedly contains: '$needle'"
        echo "    In: '$haystack'"
        if [ -n "$message" ]; then
            echo "    $message"
        fi
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
}

# Assert array length
assert_array_length() {
    local array_name="$1"
    local expected_length="$2"
    local message="${3:-}"
    
    # Get array length using indirect reference
    local array_ref="${array_name}[@]"
    local actual_length=$(eval "echo \${#$array_ref}")
    
    if [ "$actual_length" -eq "$expected_length" ]; then
        echo -e "${GREEN}PASS${NC}"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "    Expected length: $expected_length"
        echo "    Actual length:   $actual_length"
        if [ -n "$message" ]; then
            echo "    $message"
        fi
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
}

# Load hunt.sh functions without executing main
load_hunt_functions() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    local script_file="${script_dir}/hunt.sh"
    
    if [ ! -f "$script_file" ]; then
        echo "Error: hunt.sh not found at $script_file" >&2
        return 1
    fi
    
    # Create temporary directory for test files
    TEST_TMPDIR="${TEST_TMPDIR:-/tmp/hunt_test_$$}"
    mkdir -p "$TEST_TMPDIR"
    
    # If SEARCH_ENGINES_JSON is not set, create a minimal valid JSON to satisfy any checks
    if [ -z "$SEARCH_ENGINES_JSON" ] || [ ! -f "$SEARCH_ENGINES_JSON" ]; then
        local dummy_json="${TEST_TMPDIR}/dummy_search_engines.json"
        echo '[{"name": "Test", "url": "https://test.com?q=", "space_delimiter": "+"}]' > "$dummy_json"
        export SEARCH_ENGINES_JSON="$dummy_json"
    fi
    
    # Extract all function definitions and setup code, but skip argument parsing and main()
    # Strategy: extract everything except:
    # 1. The automatic JSON loading line
    # 2. Argument parsing section (from "# Parse command-line arguments" to "# URL encode")
    # 3. The main() function call at the end
    local functions_only="${TEST_TMPDIR}/hunt_functions_only.sh"
    
    # Extract lines, skipping the argument parsing section
    awk '
        /^# Parse command-line arguments$/ { skip=1; next }
        /^# URL encode the search term/ { skip=0 }
        skip==0 { print }
    ' "$script_file" | \
    sed '/^SEARCH_ENGINES_JSON=/d' | \
    sed '/^load_search_engines_from_json "$SEARCH_ENGINES_JSON"$/d' | \
    sed '/^# Invoke main function$/,$d' > "$functions_only"
    
    # Override SCRIPT_DIR to point to the test directory to avoid path issues
    export SCRIPT_DIR="$script_dir"
    
    # Source the functions (without the automatic JSON loading or argument parsing)
    source "$functions_only"
}

# Mock the open command to capture URLs instead of opening them
setup_mock_open() {
    TEST_TMPDIR="${TEST_TMPDIR:-/tmp/hunt_test_$$}"
    mkdir -p "$TEST_TMPDIR"
    
    export MOCK_OPEN_OUTPUT="${TEST_TMPDIR}/mock_open_output.txt"
    export ORIGINAL_PATH="$PATH"
    export PATH="${TEST_TMPDIR}:${PATH}"
    
    # Enable test mode to skip sleep delays for faster test execution
    export HUNT_TEST_MODE=true
    
    # Create mock open command
    cat > "${TEST_TMPDIR}/open" << 'MOCK_EOF'
#!/bin/bash
echo "$1" >> "$MOCK_OPEN_OUTPUT"
MOCK_EOF
    chmod +x "${TEST_TMPDIR}/open"
    
    # Clear any previous output
    > "$MOCK_OPEN_OUTPUT"
}

# Restore original PATH
teardown_mock_open() {
    if [ -n "$ORIGINAL_PATH" ]; then
        export PATH="$ORIGINAL_PATH"
        unset ORIGINAL_PATH
    fi
    unset MOCK_OPEN_OUTPUT
    unset HUNT_TEST_MODE
}

# Get URLs that were "opened" by the mock
get_opened_urls() {
    if [ -f "$MOCK_OPEN_OUTPUT" ]; then
        cat "$MOCK_OPEN_OUTPUT"
    fi
}

# Count how many URLs were opened
count_opened_urls() {
    if [ -f "$MOCK_OPEN_OUTPUT" ]; then
        wc -l < "$MOCK_OPEN_OUTPUT" | tr -d ' '
    else
        echo "0"
    fi
}

# Create a temporary JSON file for testing
create_test_json() {
    local content="${1:-[]}"
    TEST_TMPDIR="${TEST_TMPDIR:-/tmp/hunt_test_$$}"
    mkdir -p "$TEST_TMPDIR"
    export TEST_JSON_FILE="${TEST_TMPDIR}/test_search_engines_$$.json"
    echo "$content" > "$TEST_JSON_FILE"
    echo "$TEST_JSON_FILE"
}

# Cleanup test environment
cleanup_test() {
    teardown_mock_open
    unset TEST_JSON_FILE
    if [ -n "$TEST_TMPDIR" ] && [ -d "$TEST_TMPDIR" ]; then
        rm -rf "$TEST_TMPDIR"
    fi
}

# Print test summary
print_summary() {
    echo ""
    echo "=========================================="
    echo "Test Summary"
    echo "=========================================="
    echo "Total tests:  $TEST_COUNT"
    echo -e "Passed:       ${GREEN}$PASS_COUNT${NC}"
    if [ $FAIL_COUNT -gt 0 ]; then
        echo -e "Failed:       ${RED}$FAIL_COUNT${NC}"
    else
        echo -e "Failed:       $FAIL_COUNT"
    fi
    echo "=========================================="
    
    if [ $FAIL_COUNT -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}Some tests failed${NC}"
        return 1
    fi
}

# Reset test counters
reset_test_counters() {
    TEST_COUNT=0
    PASS_COUNT=0
    FAIL_COUNT=0
}

