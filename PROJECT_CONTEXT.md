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
├── initial-sketch.md       # Original project specification with all service examples
└── PROJECT_CONTEXT.md      # This file - project documentation
```

### Script Flow
1. Validate command-line arguments (require search term)
2. URL encode the search term using Python
3. Loop through parallel arrays of engine names and URLs
4. Construct full URL for each engine
5. Open each URL sequentially with delays
6. Print summary

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

## Known Issues & Limitations

1. **Browser Tab Opening**: Sequential opening with delays works, but may not be 100% reliable if browser is slow to respond
2. **No Browser Detection**: Script doesn't detect which browser is being used
3. **No Error Handling**: If a URL fails to open, script continues silently
4. **Fixed Delay**: 0.3 second delay is hardcoded - may need adjustment for different systems

## Future Enhancements (From initial-sketch.md)

### Additional Service Categories (Not Yet Implemented)
- **Crowd Source**: Reddit, StackOverflow, Wikipedia
- **Tech News**: Hacker News, Lobste.rs, Engadget, The Verge
- **News**: NPR, NYT, WSJ
- **Shopping**: Amazon, eBay, Gazelle, Slick Deals, Swappa

### Potential Improvements
1. **Service Selection**: Allow users to select which services to search (not just search engines)
2. **Configuration File**: Store service definitions in external config
3. **Browser Detection**: Detect and use browser-specific opening methods
4. **Error Handling**: Better feedback when URLs fail to open
5. **Parallel Opening**: Investigate if background processes with staggered delays work better
6. **Service Categories**: Group services by category and allow category-based selection
7. **Custom Delays**: Make delay configurable or adaptive

## Development History

### Initial Implementation Session
- Created MVP bash script
- Discovered bash 3.2 associative array limitation
- Switched to parallel arrays pattern
- Implemented sequential URL opening with delays
- Fixed loop iteration issue that was causing only last URL to open

### Key Debugging Moments
- Issue: Only YouTube (last in array) was opening
- Root Cause: Associative arrays not supported in bash 3.2
- Solution: Converted to parallel arrays with index-based iteration

## Usage

```bash
./hunt.sh "search term"
```

Example:
```bash
./hunt.sh "machine learning"
```

This will open 8 browser tabs, one for each search engine with the encoded search term.

## Dependencies

- **Bash**: 3.2+ (macOS default is sufficient)
- **Python 3**: Required for URL encoding (standard on macOS)
- **macOS `open` command**: Native command for opening URLs

## Testing Notes

- Tested on macOS (darwin 24.6.0)
- Default browser behavior: Opens URLs in new tabs when browser is already running
- If browser is not running, first URL opens browser, subsequent URLs open in new tabs

## Next Steps

1. Test with all 8 search engines to verify all tabs open correctly
2. Consider adding other service categories from `initial-sketch.md`
3. Add configuration support for selecting which services to use
4. Improve error handling and user feedback
5. Consider making the script more portable (not just macOS)

