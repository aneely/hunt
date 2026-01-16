#!/bin/bash
# Unit tests for URL construction (optimization 2 - direct testing)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test_helpers.sh"

# Setup: Load hunt functions and create test JSON
TEST_JSON='[
  {"name": "Bing", "url": "https://www.bing.com/search?q=", "space_delimiter": "+"},
  {"name": "Google", "url": "https://www.google.com/search?q=", "space_delimiter": "+"},
  {"name": "DuckDuckGo", "url": "https://duckduckgo.com/?q=", "space_delimiter": "+"},
  {"name": "Yahoo", "url": "https://search.yahoo.com/search?p=", "space_delimiter": "+"}
]'
TEST_JSON_FILE=$(create_test_json "$TEST_JSON")
export SEARCH_ENGINES_JSON="$TEST_JSON_FILE"
load_hunt_functions
load_search_engines_from_json "$SEARCH_ENGINES_JSON"

echo "Testing URL construction (direct testing)"
echo "========================================"

test_start "build_search_urls with single engine"
urls=$(build_search_urls "test query" 0)
url_count=$(echo "$urls" | wc -l | tr -d ' ')
assert_equal "1" "$url_count" "Should return 1 URL"
assert_contains "$urls" "https://www.bing.com/search?q=" "Should contain Bing base URL"
assert_contains "$urls" "test+query" "Should contain encoded search term"

test_start "build_search_urls with multiple engines"
urls=$(build_search_urls "hello world" 0 1 2)
url_count=$(echo "$urls" | wc -l | tr -d ' ')
assert_equal "3" "$url_count" "Should return 3 URLs"
assert_contains "$urls" "bing.com" "Should contain Bing"
assert_contains "$urls" "google.com" "Should contain Google"
assert_contains "$urls" "duckduckgo.com" "Should contain DuckDuckGo"

test_start "build_search_urls URL encoding with spaces"
urls=$(build_search_urls "test query" 0)
assert_contains "$urls" "test+query" "Should encode spaces as +"

test_start "build_search_urls URL encoding with special characters"
urls=$(build_search_urls "test & query" 0)
assert_contains "$urls" "test" "Should contain test"
assert_contains "$urls" "query" "Should contain query"
assert_not_contains "$urls" "test & query" "Should not contain raw &"

test_start "build_search_urls uses correct base URLs"
urls=$(build_search_urls "test" 0 1 3)
# Check each URL has the correct base
bing_url=$(echo "$urls" | head -n1)
google_url=$(echo "$urls" | sed -n '2p')
yahoo_url=$(echo "$urls" | tail -n1)
assert_contains "$bing_url" "https://www.bing.com/search?q=" "Bing URL should have correct base"
assert_contains "$google_url" "https://www.google.com/search?q=" "Google URL should have correct base"
assert_contains "$yahoo_url" "https://search.yahoo.com/search?p=" "Yahoo URL should have correct base"

test_start "build_search_urls handles all engines"
urls=$(build_search_urls "test" 0 1 2 3)
url_count=$(echo "$urls" | wc -l | tr -d ' ')
assert_equal "4" "$url_count" "Should return 4 URLs"

test_start "build_search_urls preserves search term encoding"
urls=$(build_search_urls "python 3.10" 0)
assert_contains "$urls" "python+3.10" "Should properly encode search term"

cleanup_test
print_summary
exit $?


