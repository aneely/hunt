#!/bin/bash
# Unit tests for service selection functions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test_helpers.sh"

# Setup: Create test JSON first, then load hunt functions
TEST_JSON='[
  {"name": "Bing", "url": "https://www.bing.com/search?q=", "space_delimiter": "+"},
  {"name": "Google", "url": "https://www.google.com/search?q=", "space_delimiter": "+"},
  {"name": "DuckDuckGo", "url": "https://duckduckgo.com/?q=", "space_delimiter": "+"}
]'
TEST_JSON_FILE=$(create_test_json "$TEST_JSON")

# Set SEARCH_ENGINES_JSON before loading functions so it uses our test JSON
export SEARCH_ENGINES_JSON="$TEST_JSON_FILE"

# Load hunt functions (will use our test JSON)
load_hunt_functions

# Ensure arrays are loaded (they should be from load_hunt_functions, but verify)
if [ ${#SEARCH_ENGINE_NAMES[@]} -eq 0 ]; then
    load_search_engines_from_json "$SEARCH_ENGINES_JSON"
fi

echo "Testing service selection functions"
echo "===================================="

test_start "is_service_selection accepts number 0 (all)"
is_service_selection "0"
assert_success "is_service_selection '0'"

test_start "is_service_selection accepts valid engine numbers"
is_service_selection "1" && is_service_selection "2" && is_service_selection "3"
assert_success "is_service_selection '1' && is_service_selection '2' && is_service_selection '3'"

test_start "is_service_selection rejects invalid numbers"
! is_service_selection "9" && ! is_service_selection "10"
assert_success "! is_service_selection '9' && ! is_service_selection '10'"

test_start "is_service_selection accepts 'all' (case-insensitive)"
is_service_selection "all" && is_service_selection "All" && is_service_selection "ALL"
assert_success "is_service_selection 'all' && is_service_selection 'All' && is_service_selection 'ALL'"

test_start "is_service_selection accepts service names (case-insensitive)"
is_service_selection "Bing" && is_service_selection "bing" && is_service_selection "BING"
assert_success "is_service_selection 'Bing' && is_service_selection 'bing' && is_service_selection 'BING'"

test_start "is_service_selection rejects invalid service names"
! is_service_selection "InvalidService"
assert_success "! is_service_selection 'InvalidService'"

test_start "resolve_service_selection resolves number 0 to 'all'"
result=$(resolve_service_selection "0")
assert_equal "all" "$result"

test_start "resolve_service_selection resolves number 1 to index 0"
result=$(resolve_service_selection "1")
assert_equal "0" "$result"

test_start "resolve_service_selection resolves number 2 to index 1"
result=$(resolve_service_selection "2")
assert_equal "1" "$result"

test_start "resolve_service_selection resolves 'all' to 'all'"
result=$(resolve_service_selection "all")
assert_equal "all" "$result"
result=$(resolve_service_selection "All")
assert_equal "all" "$result"

test_start "resolve_service_selection resolves service names to indices (case-insensitive)"
result=$(resolve_service_selection "Bing")
assert_equal "0" "$result"
result=$(resolve_service_selection "bing")
assert_equal "0" "$result"
result=$(resolve_service_selection "Google")
assert_equal "1" "$result"

test_start "resolve_service_selection returns -1 for invalid selection"
result=$(resolve_service_selection "InvalidService")
assert_equal "-1" "$result"

test_start "parse_service_selections selects all when 'all' is specified"
parse_service_selections "all"
assert_array_length "SELECTED_INDICES" 3
assert_equal "0" "${SELECTED_INDICES[0]}"
assert_equal "1" "${SELECTED_INDICES[1]}"
assert_equal "2" "${SELECTED_INDICES[2]}"

test_start "parse_service_selections selects all when 0 is specified"
parse_service_selections "0"
assert_array_length "SELECTED_INDICES" 3

test_start "parse_service_selections selects single engine by number"
parse_service_selections "1"
assert_array_length "SELECTED_INDICES" 1
assert_equal "0" "${SELECTED_INDICES[0]}"

test_start "parse_service_selections selects multiple engines by number"
parse_service_selections "1" "2"
assert_array_length "SELECTED_INDICES" 2
assert_equal "0" "${SELECTED_INDICES[0]}"
assert_equal "1" "${SELECTED_INDICES[1]}"

test_start "parse_service_selections selects engines by name"
parse_service_selections "Bing" "Google"
assert_array_length "SELECTED_INDICES" 2
assert_equal "0" "${SELECTED_INDICES[0]}"
assert_equal "1" "${SELECTED_INDICES[1]}"

test_start "parse_service_selections case-insensitive name matching"
parse_service_selections "bing" "GOOGLE"
assert_array_length "SELECTED_INDICES" 2
assert_equal "0" "${SELECTED_INDICES[0]}"
assert_equal "1" "${SELECTED_INDICES[1]}"

test_start "parse_service_selections removes duplicates"
parse_service_selections "1" "1" "Bing"
assert_array_length "SELECTED_INDICES" 1
assert_equal "0" "${SELECTED_INDICES[0]}"

test_start "parse_service_selections ignores invalid selections"
parse_service_selections "1" "InvalidService" "2"
assert_array_length "SELECTED_INDICES" 2
assert_equal "0" "${SELECTED_INDICES[0]}"
assert_equal "1" "${SELECTED_INDICES[1]}"

test_start "parse_service_selections mixes numbers and names"
parse_service_selections "1" "Google" "3"
assert_array_length "SELECTED_INDICES" 3
assert_equal "0" "${SELECTED_INDICES[0]}"
assert_equal "1" "${SELECTED_INDICES[1]}"
assert_equal "2" "${SELECTED_INDICES[2]}"

cleanup_test
print_summary
exit $?

