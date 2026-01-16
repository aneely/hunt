#!/bin/bash
# Acceptance tests - end-to-end behavior with mocked open command

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test_helpers.sh"

HUNT_SCRIPT="${SCRIPT_DIR}/../hunt.sh"
SEARCH_ENGINES_JSON="${SCRIPT_DIR}/../search_engines.json"

# Ensure script is executable
chmod +x "$HUNT_SCRIPT"

echo "Testing end-to-end behavior"
echo "==========================="

test_start "default mode opens all engines"
setup_mock_open
"$HUNT_SCRIPT" "test query" >/dev/null 2>&1
count=$(count_opened_urls)
assert_equal "8" "$count" "Should open 8 URLs (one for each engine)"
urls=$(get_opened_urls)
assert_contains "$urls" "test+query" "URLs should contain encoded search term"
assert_contains "$urls" "bing.com" "Should include Bing"
assert_contains "$urls" "google.com" "Should include Google"
cleanup_test

test_start "services flag with single engine"
setup_mock_open
"$HUNT_SCRIPT" -s 1 "test query" >/dev/null 2>&1
count=$(count_opened_urls)
assert_equal "1" "$count" "Should open 1 URL"
urls=$(get_opened_urls)
assert_contains "$urls" "bing.com" "Should include Bing"
cleanup_test

test_start "services flag with multiple engines by number"
setup_mock_open
"$HUNT_SCRIPT" -s 1 3 5 "test query" >/dev/null 2>&1
count=$(count_opened_urls)
assert_equal "3" "$count" "Should open 3 URLs"
urls=$(get_opened_urls)
assert_contains "$urls" "bing.com" "Should include Bing"
assert_contains "$urls" "google.com" "Should include Google"
assert_contains "$urls" "mojeek.com" "Should include Mojeek"
cleanup_test

test_start "services flag with engine names"
setup_mock_open
"$HUNT_SCRIPT" -s Bing Google "test query" >/dev/null 2>&1
count=$(count_opened_urls)
assert_equal "2" "$count" "Should open 2 URLs"
urls=$(get_opened_urls)
assert_contains "$urls" "bing.com" "Should include Bing"
assert_contains "$urls" "google.com" "Should include Google"
cleanup_test

test_start "services flag case-insensitive names"
setup_mock_open
"$HUNT_SCRIPT" -s bing GOOGLE "test query" >/dev/null 2>&1
count=$(count_opened_urls)
assert_equal "2" "$count" "Should open 2 URLs"
cleanup_test

test_start "services flag with 'all' keyword"
setup_mock_open
"$HUNT_SCRIPT" -s all "test query" >/dev/null 2>&1
count=$(count_opened_urls)
assert_equal "8" "$count" "Should open all 8 URLs"
cleanup_test

test_start "services flag with number 0 (all)"
setup_mock_open
"$HUNT_SCRIPT" -s 0 "test query" >/dev/null 2>&1
count=$(count_opened_urls)
assert_equal "8" "$count" "Should open all 8 URLs"
cleanup_test

test_start "URL encoding with spaces"
setup_mock_open
"$HUNT_SCRIPT" "hello world" >/dev/null 2>&1
urls=$(get_opened_urls)
assert_contains "$urls" "hello+world" "Should encode spaces as +"
cleanup_test

test_start "URL encoding with special characters"
setup_mock_open
"$HUNT_SCRIPT" "test & query" >/dev/null 2>&1
urls=$(get_opened_urls)
assert_contains "$urls" "test" "Should contain test"
assert_contains "$urls" "query" "Should contain query"
assert_not_contains "$urls" "test & query" "Should not contain raw &"
cleanup_test

test_start "error when no search term provided"
result=$("$HUNT_SCRIPT" 2>&1)
assert_contains "$result" "Usage" "Should show usage message"
cleanup_test

test_start "duplicate service selection removed"
setup_mock_open
"$HUNT_SCRIPT" -s 1 1 1 "test query" >/dev/null 2>&1
count=$(count_opened_urls)
assert_equal "1" "$count" "Should only open once (duplicates removed)"
cleanup_test

test_start "explicit separator -- works"
setup_mock_open
"$HUNT_SCRIPT" -s 1 -- "test query" >/dev/null 2>&1
count=$(count_opened_urls)
assert_equal "1" "$count" "Should open 1 URL"
cleanup_test

print_summary
exit $?


