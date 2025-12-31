# Hunt - Meta-Search CLI Tool Project Context

## Project Overview

**Hunt** is a CLI tool that takes a search term and opens it across multiple search engines and services simultaneously in the user's default browser. The tool constructs URLs for registered services and opens them in separate browser tabs.

## Current Status

### MVP Implementation (Completed)
- ✅ Basic bash script (`hunt.sh`) that accepts a search term
- ✅ URL encoding using Python's `urllib.parse`
- ✅ Support for 8 search engines (initial MVP scope)
- ✅ Opens URLs sequentially with delays to ensure separate browser tabs
- ✅ Bash 3.2 compatibility (macOS default)
- ✅ Interactive mode (`-i`/`--interactive`) for selecting search engines
- ✅ Services flag mode (`-s`/`--services`) for command-line service selection
- ✅ Support for service selection by number (1-8, 9 for all) or name (case-insensitive)
- ✅ Automatic detection of search term when using services flag
- ✅ Duplicate service selection handling

### Search Engines Currently Supported
1. Bing
2. DuckDuckGo
3. Google
4. Kagi
5. Mojeek
6. StartPage
7. Yahoo
8. YouTube

## Technical Decisions & Constraints

### Bash Version Compatibility
- **Critical Decision**: macOS ships with bash 3.2.57 by default, which does NOT support associative arrays (requires bash 4.0+)
- **Solution**: Use parallel arrays (`SEARCH_ENGINE_NAMES` and `SEARCH_ENGINE_URLS`) instead of associative arrays
- **Impact**: All array operations must use index-based iteration

### URL Encoding
- Uses Python 3's `urllib.parse.quote()` for robust URL encoding
- Handles spaces, special characters, and Unicode properly
- Requires Python 3 to be installed (standard on macOS)

### Browser Opening Strategy
- Uses macOS `open` command (native, works with default browser)
- Sequential opening with 0.3 second delays between each URL
- Delays help ensure browser processes each URL as a separate tab
- **Known Limitation**: If browser isn't running or has issues, some tabs might not open

## Architecture

### File Structure
```
hunt/
├── hunt.sh                 # Main executable script
├── README.md               # User-facing documentation
├── initial-sketch.md       # Original project specification with all service examples
└── PROJECT_CONTEXT.md      # This file - project documentation
```

### Script Flow
1. **Argument Parsing**: Parse command-line flags (`-i`, `-s`) and collect service selections
2. **Service Selection**:
   - If `-i` flag: Display interactive menu and collect user selections
   - If `-s` flag: Parse service selections (numbers/names) from command line
   - Otherwise: Select all engines by default
3. **Validation**: Ensure search term is provided and validate service selections
4. **URL Encoding**: Encode the search term using Python's `urllib.parse`
5. **URL Construction**: For each selected engine, construct full URL with encoded query
6. **Browser Opening**: Open each URL sequentially with 0.3s delays
7. **Summary**: Display confirmation of opened searches

### Key Implementation Details

**Parallel Arrays Pattern:**
```bash
SEARCH_ENGINE_NAMES=(...)
SEARCH_ENGINE_URLS=(...)
# Iterate using: for i in "${!SEARCH_ENGINE_NAMES[@]}"
```

**URL Construction:**
- Base URL from `SEARCH_ENGINE_URLS[$i]`
- Append encoded search term: `url="${url_base}${ENCODED_TERM}"`
- Note: Different engines use different query parameter names (`q`, `p`, `search_query`)

**Service Selection Logic:**
- Service names defined early in script for validation during argument parsing
- `is_service_selection()` helper function validates if argument is a valid service
- Supports numbers (1-8, 9 for all), service names (case-insensitive), or "all"
- Automatic detection: stops collecting services when encountering non-service argument
- Explicit separator: `--` can be used to explicitly separate services from search term
- Duplicate removal: automatically removes duplicate service selections

## Known Issues & Limitations

1. **Browser Tab Opening**: Sequential opening with delays works, but may not be 100% reliable if browser is slow to respond
2. **No Browser Detection**: Script doesn't detect which browser is being used
3. **No Error Handling**: If a URL fails to open, script continues silently
4. **Fixed Delay**: 0.3 second delay is hardcoded - may need adjustment for different systems
5. **Service Name Ambiguity**: If a search term happens to match a service name exactly, it could be misinterpreted (rare edge case)

## Future Enhancements (From initial-sketch.md)

### Additional Service Categories (Not Yet Implemented)
- **Crowd Source**: Reddit, StackOverflow, Wikipedia
- **Tech News**: Hacker News, Lobste.rs, Engadget, The Verge
- **News**: NPR, NYT, WSJ
- **Shopping**: Amazon, eBay, Gazelle, Slick Deals, Swappa

### Potential Improvements
1. **Additional Service Categories**: Add other service categories from `initial-sketch.md` (Reddit, StackOverflow, Wikipedia, etc.)
2. **Configuration File**: Store service definitions in external config file
3. **Browser Detection**: Detect and use browser-specific opening methods
4. **Error Handling**: Better feedback when URLs fail to open
5. **Parallel Opening**: Investigate if background processes with staggered delays work better
6. **Service Categories**: Group services by category and allow category-based selection
7. **Custom Delays**: Make delay configurable or adaptive
8. **Service Aliases**: Support shorter aliases for service names (e.g., `ddg` for DuckDuckGo)

## Development History

### Initial Implementation Session
- Created MVP bash script
- Discovered bash 3.2 associative array limitation
- Switched to parallel arrays pattern
- Implemented sequential URL opening with delays
- Fixed loop iteration issue that was causing only last URL to open

### Interactive Mode Implementation
- Added `-i`/`--interactive` flag for user-friendly service selection
- Implemented numbered menu system (1-8 for engines, 9 for all)
- Added input validation and error handling for invalid selections

### Services Flag Implementation
- Added `-s`/`--services` flag for command-line service selection
- Implemented support for both numbers and service names
- Added case-insensitive service name matching
- Implemented automatic detection of search term (stops collecting services when non-service argument encountered)
- Added support for explicit `--` separator
- Implemented duplicate removal for service selections
- Moved service name definitions early in script for validation during argument parsing

### Key Debugging Moments
- **Issue**: Only YouTube (last in array) was opening
- **Root Cause**: Associative arrays not supported in bash 3.2
- **Solution**: Converted to parallel arrays with index-based iteration

- **Issue**: Services flag was consuming search term as service selection
- **Root Cause**: Argument parser collected all non-flag arguments after `-s` as services
- **Solution**: Implemented `is_service_selection()` helper and automatic detection to stop collecting services when encountering non-service argument

## Usage

### Default Mode (All Engines)
```bash
./hunt.sh "search term"
```
Opens all 8 search engines.

### Interactive Mode
```bash
./hunt.sh -i "search term"
# or
./hunt.sh --interactive "search term"
```
Displays numbered menu for selecting specific engines.

### Services Flag Mode
```bash
# By numbers
./hunt.sh -s 1 3 5 "search term"

# By names
./hunt.sh -s Bing Google "search term"

# Mix numbers and names
./hunt.sh -s 1 Google 5 "search term"

# Select all
./hunt.sh -s all "search term"
# or
./hunt.sh -s 9 "search term"
```

Examples:
```bash
./hunt.sh "machine learning"                    # All engines
./hunt.sh -i "machine learning"                 # Interactive selection
./hunt.sh -s Bing Google "machine learning"     # Bing and Google only
./hunt.sh -s 1 3 5 "machine learning"          # Bing, Google, Mojeek
```

## Dependencies

- **Bash**: 3.2+ (macOS default is sufficient)
- **Python 3**: Required for URL encoding (standard on macOS)
- **macOS `open` command**: Native command for opening URLs

## Testing Notes

- Tested on macOS (darwin 24.6.0)
- Default browser behavior: Opens URLs in new tabs when browser is already running
- If browser is not running, first URL opens browser, subsequent URLs open in new tabs

## Next Steps

1. ✅ ~~Test with all 8 search engines to verify all tabs open correctly~~ (Completed)
2. ✅ ~~Add configuration support for selecting which services to use~~ (Completed - via `-i` and `-s` flags)
3. Consider adding other service categories from `initial-sketch.md` (Reddit, StackOverflow, Wikipedia, etc.)
4. Improve error handling and user feedback
5. Consider making the script more portable (not just macOS)
6. Add service aliases for shorter names (e.g., `ddg` for DuckDuckGo)
7. Consider service category grouping and category-based selection

