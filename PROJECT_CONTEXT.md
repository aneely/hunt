# Hunt - Meta-Search CLI Tool Project Context

## Project Overview

**Hunt** is a CLI tool that takes a search term and opens it across multiple search engines and services simultaneously in the user's default browser. The tool constructs URLs for registered services and opens them in separate browser tabs.

## Current Status

### MVP Implementation (Completed)
- ✅ Basic bash script (`hunt.sh`) that accepts a search term
- ✅ URL encoding using bash-native implementation
- ✅ Support for 8 search engines (initial MVP scope)
- ✅ Opens URLs sequentially with delays to ensure separate browser tabs
- ✅ Bash 3.2 compatibility (macOS default)
- ✅ Interactive mode (`-i`/`--interactive`) for selecting search engines
- ✅ Services flag mode (`-s`/`--services`) for command-line service selection
- ✅ Support for service selection by number (0 for all, 1-8 for engines) or name (case-insensitive)
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

### Dependency Philosophy
- **Preference**: Prefer dependency-free implementations using standard bash and Unix utilities
- **Rationale**: Reduces installation complexity, improves portability, and keeps the codebase self-contained
- **Exceptions**: Dependencies are acceptable when they provide:
  - Well-tested solutions for problems outside the application's core domain
  - Performance optimizations unlikely to be achieved through independent efforts
- **Decision Process**: When considering a dependency, evaluate:
  1. Can we solve this with standard tools (bash, sed, awk, grep, etc.)?
  2. Does the dependency solve a problem outside our domain (e.g., JSON parsing, HTTP requests)?
  3. Would the dependency provide significant performance benefits we can't achieve ourselves?
  4. What is the maintenance burden vs. benefit?
- **Examples**:
  - ✅ **No dependency**: Custom bash test framework (simple, maintainable, no external requirements)
  - ✅ **No dependency**: Bash-native URL encoding (sufficient for our needs, no external tools)
  - ⚠️ **Could use dependency**: JSON parsing (we use grep/sed, but a JSON parser library could be considered if needs grow)
  - ⚠️ **Could use dependency**: Test framework like BATS (we chose custom solution for zero dependencies)

### Bash Version Compatibility
- **Critical Decision**: macOS ships with bash 3.2.57 by default, which does NOT support associative arrays (requires bash 4.0+)
- **Solution**: Use parallel arrays (`SEARCH_ENGINE_NAMES`, `SEARCH_ENGINE_URLS`, and `SEARCH_ENGINE_DELIMITERS`) instead of associative arrays
- **Impact**: All array operations must use index-based iteration

### URL Encoding
- Uses bash-native URL encoding implementation
- Handles spaces, special characters, and multi-byte UTF-8 characters
- Uses `od` command to convert characters to hex representation
- Supports engine-specific space delimiters (`+` or `%20`) configured per search engine
- No external dependencies required (pure bash solution)

### Browser Opening Strategy
- Uses macOS `open` command (native, works with default browser)
- Sequential opening with 0.3 second delays between each URL
- Delays help ensure browser processes each URL as a separate tab
- **Test Mode**: When `HUNT_TEST_MODE` environment variable is set, sleep delays are skipped for faster test execution
- **Known Limitation**: If browser isn't running or has issues, some tabs might not open

### Code Organization & Architecture
- **Modular Function-Based Approach**: Split functionality into discrete functions to contain separate pieces of functionality as modules within the script
- **Standard Practice**: When adding new features or refactoring, extract logical units of work into well-defined functions
- **Benefits**: 
  - Improved code readability and maintainability
  - Easier testing and debugging of individual components
  - Better separation of concerns
  - Reusable code blocks
- **Current Functions**:
  - `load_search_engines_from_json()` - Loads search engine definitions from JSON file (name, url, space_delimiter)
  - `url_encode()` - Handles URL encoding using bash-native implementation with configurable space delimiter (no external dependencies)
  - `is_service_selection()` - Validates if an argument is a valid service selection
  - `resolve_service_selection()` - Resolves a service name or number to an array index
  - `parse_service_selections()` - Parses and validates service selections, populates SELECTED_INDICES
  - `build_search_urls()` - Constructs search URLs for given indices (extracted for testability, outputs URLs to stdout)

## Development Guidelines

### Git Operations - Destructive Changes Policy
- **CRITICAL**: AI assistants working on this project must NOT commit destructive git changes without explicit user confirmation
- **Destructive changes include**:
  - Force pushes (`git push --force`, `git push -f`)
  - Hard resets (`git reset --hard`)
  - Branch deletions (`git branch -D`)
  - Rewriting history (`git rebase` on shared branches, `git commit --amend` on pushed commits)
  - Any operation that could result in data loss or overwrite existing commits
- **Required workflow**: Before executing any potentially destructive git operation, the AI assistant must:
  1. Clearly explain what the operation will do
  2. Show the user what will be affected
  3. Wait for explicit user confirmation before proceeding
- **Safe operations** (can be done without confirmation):
  - Regular commits (`git commit`)
  - Creating new branches
  - Merging branches (non-destructive merges)
  - Adding/removing files in working directory
  - Viewing git status and history

### Bash Commands - Destructive Operations Policy
- **CRITICAL**: AI assistants working on this project must NOT execute potentially destructive bash commands without explicit user confirmation
- **Potentially destructive commands include**:
  - File deletion commands (`rm`, `rm -rf`, `rmdir`)
  - File overwrite operations that could lose data (`>`, `>>` to existing files without backup)
  - System modification commands (`sudo`, system configuration changes)
  - Commands that modify or delete project files outside of normal editing workflows
  - Commands that could affect system settings or installed software
  - Commands that could result in data loss or irreversible changes
- **Required workflow**: Before executing any potentially destructive bash command, the AI assistant must:
  1. Clearly explain what the command will do
  2. Show what files or system components will be affected
  3. Explain the potential consequences
  4. Wait for explicit user confirmation before proceeding
- **Safe operations** (can be done without confirmation):
  - Reading files (`cat`, `read_file`, `grep` for reading)
  - Listing directory contents (`ls`, `list_dir`)
  - Viewing git status and history
  - Creating new files (when explicitly requested)
  - Editing files using safe editing tools (when explicitly requested)
  - Running the hunt.sh script for testing (non-destructive execution)

### Security & Secrets Management Policy
- **CRITICAL**: AI assistants working on this project must NOT commit any secrets or personally identifying information (PII) to the repository
- **What NOT to commit**:
  - API tokens, API keys, or authentication credentials
  - Passwords or password hashes
  - Private keys (SSH keys, GPG keys, etc.)
  - Access tokens or session tokens
  - Database connection strings with credentials
  - Personal information (email addresses, phone numbers, addresses)
  - Any sensitive configuration data that should remain private
- **What IS acceptable to commit**:
  - Public-facing URLs (GET URLs, public endpoints)
  - Public usernames or identifiers (when they are intentionally public)
  - Example configurations without real credentials
  - Search engine URLs and query parameters (these are public-facing)
- **Required workflow**: Before committing any file that might contain sensitive information, the AI assistant must:
  1. Review the file contents for any secrets or PII
  2. If secrets are found, either:
     - Remove them and use environment variables or config files (excluded via .gitignore)
     - Use placeholder values with clear documentation
     - Ask the user how to handle the sensitive information
  3. Verify that `.gitignore` excludes any files containing secrets (e.g., `.env`, `config.local.json`)
- **Best practices**:
  - Use environment variables for secrets (documented but not committed)
  - Use `.gitignore` to exclude files containing secrets
  - Use placeholder/example values in committed configuration files
  - Document where real values should be configured (in README or setup instructions)

## Architecture

### File Structure
```
hunt/
├── hunt.sh                 # Bash implementation - main executable script
├── search_engines.json    # Search engine definitions (names and URLs)
├── README.md               # User-facing documentation
├── PROJECT_CONTEXT.md      # This file - project documentation
├── initial-sketch.md       # Original project specification with all service examples
├── LICENSE                 # MIT License
├── .gitignore             # Git ignore patterns for OS and editor files
├── go.mod                  # Go module definition
├── main.go                 # Go implementation - main entry point
├── config.go               # Go - JSON configuration loading
├── url.go                  # Go - URL encoding and construction
├── selection.go            # Go - Service selection logic
├── browser.go              # Go - Cross-platform browser opening
├── *_test.go               # Go test files (unit and integration tests)
└── tests/                  # Bash test suite
    ├── README.md           # Test documentation
    ├── test_helpers.sh     # Test helper functions and assertions
    ├── run_tests.sh        # Test runner script
    ├── test_url_encode.sh  # URL encoding unit tests
    ├── test_service_selection.sh  # Service selection unit tests
    ├── test_url_construction.sh   # URL construction unit tests (direct testing of build_search_urls)
    └── test_acceptance.sh  # End-to-end acceptance tests
```

### Script Flow
1. **Argument Parsing**: Parse command-line flags (`-i`, `-s`) and collect service selections
2. **Service Selection**:
   - If `-i` flag: Display interactive menu and collect user selections
   - If `-s` flag: Parse service selections (numbers/names) from command line
   - Otherwise: Select all engines by default
3. **Validation**: Ensure search term is provided and validate service selections
4. **URL Encoding**: Encode the search term using bash-native URL encoding
5. **URL Construction**: For each selected engine, construct full URL with encoded query
6. **Browser Opening**: Open each URL sequentially with 0.3s delays
7. **Summary**: Display confirmation of opened searches

### Key Implementation Details

**JSON-Based Configuration:**
- Search engines are defined in `search_engines.json` file
- Script automatically detects its own directory using `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` to locate the JSON file
- JSON file path: `${SCRIPT_DIR}/search_engines.json` (ensures script works regardless of current working directory)
- Script loads engines from JSON at startup using `load_search_engines_from_json()` function
- JSON structure: array of objects with `name`, `url`, and `space_delimiter` fields
  - `name`: Display name of the search engine
  - `url`: Base search URL with query parameter (e.g., `https://www.google.com/search?q=`)
  - `space_delimiter`: Character(s) to use for spaces in URLs (`+` or `%20`, defaults to `+` if not specified)
- Parsed into parallel arrays: `SEARCH_ENGINE_NAMES`, `SEARCH_ENGINE_URLS`, and `SEARCH_ENGINE_DELIMITERS`
- Iterate using: `for i in "${!SEARCH_ENGINE_NAMES[@]}"`
- Error handling: Script exits with error if JSON file is missing or malformed

**URL Construction:**
- Uses `build_search_urls()` function for testability (extracted function that outputs URLs to stdout)
- Base URL from `SEARCH_ENGINE_URLS[$i]`
- Space delimiter from `SEARCH_ENGINE_DELIMITERS[$i]` (used during URL encoding)
- Encode search term with engine-specific delimiter: `encoded_term=$(url_encode "$SEARCH_TERM" "$delimiter")`
- Append encoded search term: `url="${url_base}${encoded_term}"`
- Function outputs one URL per line, allowing for direct testing without browser opening
- Note: Different engines use different query parameter names (`q`, `p`, `search_query`) and may prefer different space delimiters

**Service Selection Logic:**
- Service names loaded from JSON file at script startup for validation during argument parsing
- `is_service_selection()` helper function validates if argument is a valid service
- Supports numbers (0 for all, 1-8 for engines), service names (case-insensitive), or "all"
- Number validation: accepts 0-8 (0 = all engines, 1-8 = specific engine indices)
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
9. **Browser Extension**: Create a browser extension (Chrome, Firefox, Safari) that provides quick access to Hunt from the browser toolbar. Users could select text on a webpage and search across engines, or use a popup interface to enter search terms. This would make Hunt accessible without opening a terminal.
10. **System Path Integration**: Package the script for easy installation as a system command. Create an installation script or Makefile that:
    - Copies `hunt.sh` to `/usr/local/bin/hunt` (or `~/.local/bin/hunt`)
    - Ensures the script is executable
    - Optionally creates a symlink
    - Allows users to run `hunt "search term"` from anywhere instead of `./hunt.sh`
11. **Homebrew Distribution**: Create a Homebrew formula for macOS users to install Hunt via `brew install hunt`. This would:
    - Provide a standard installation method for macOS users
    - Handle path setup automatically
    - Enable easy updates via `brew upgrade hunt`
    - Follow Homebrew conventions for formula structure and dependencies
12. ✅ **Go Port**: Completed! Ported the project to Go for cross-platform distribution as a single portable binary. Benefits include:
    - Single binary distribution (no dependencies)
    - Cross-platform support (macOS, Linux, Windows)
    - Better performance and error handling
    - Easier distribution and installation
    - No bash version compatibility concerns
    - Comprehensive test suite (unit and integration tests)
    - Full feature parity with bash version

## Development History

### Initial Implementation Session
- Created MVP bash script
- Discovered bash 3.2 associative array limitation
- Switched to parallel arrays pattern
- Implemented sequential URL opening with delays
- Fixed loop iteration issue that was causing only last URL to open

### Interactive Mode Implementation
- Added `-i`/`--interactive` flag for user-friendly service selection
- Implemented numbered menu system (0 for all, 1-8 for engines)
- Added input validation and error handling for invalid selections

### Services Flag Implementation
- Added `-s`/`--services` flag for command-line service selection
- Implemented support for both numbers and service names
- Added case-insensitive service name matching
- Implemented automatic detection of search term (stops collecting services when non-service argument encountered)
- Added support for explicit `--` separator
- Implemented duplicate removal for service selections
- Moved service name definitions early in script for validation during argument parsing

### JSON-Based Configuration Implementation
- Extracted search engine definitions into `search_engines.json` file
- Created `load_search_engines_from_json()` function to parse JSON and populate arrays
- Removed hardcoded search engine arrays from script
- JSON structure allows for easier maintenance and future expansion
- Script automatically loads engines from JSON at startup
- Uses simple grep/sed-based JSON parser (bash 3.2 compatible, no external dependencies)
- Added support for `space_delimiter` field in JSON to allow engine-specific space encoding (defaults to `+` if not specified)
- Populates three parallel arrays: `SEARCH_ENGINE_NAMES`, `SEARCH_ENGINE_URLS`, and `SEARCH_ENGINE_DELIMITERS`

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
./hunt.sh -s 0 "search term"
```

Examples:
```bash
./hunt.sh "machine learning"                    # All engines
./hunt.sh -i "machine learning"                 # Interactive selection
./hunt.sh -s Bing Google "machine learning"     # Bing and Google only
./hunt.sh -s 1 3 5 "machine learning"          # Bing, Google, Mojeek
```

## Dependencies

### Runtime Dependencies
- **Bash**: 3.2+ (macOS default is sufficient)
- **macOS `open` command**: Native command for opening URLs
- **od command**: Used for URL encoding (standard Unix utility, available on macOS)

### Development Dependencies
- **None required**: The test suite uses a custom, dependency-free bash framework
  - No external tools or libraries needed
  - Pure bash implementation for maximum portability

## Repository & Development Setup

### GitHub Repository
- **Repository URL**: https://github.com/aneely/hunt
- **Remote Configuration**: Uses HTTPS (configured for GitHub CLI authentication)
- **Default Branch**: `main`
- **License**: MIT License (see LICENSE file)

### Git Configuration
- Remote is configured to use HTTPS: `https://github.com/aneely/hunt.git`
- GitHub CLI (`gh`) is authenticated and configured for git operations
- Git credential helper is set up via `gh auth setup-git` to use GitHub CLI tokens
- **Note**: SSH authentication was not working, so remote was switched to HTTPS

### Development Environment
- **OS**: macOS (darwin 24.6.0)
- **Bash Version**: 3.2+ (macOS default)
- **GitHub CLI**: Installed and authenticated (account: aneely)
- **Git**: Configured with GitHub CLI credential helper

### Important Files
- `.gitignore`: Excludes macOS system files (.DS_Store), editor files (.vscode/, .idea/), temporary files, and local config files
- `LICENSE`: MIT License with copyright 2024 Andrew Neely
- All project files are tracked in git except those matching `.gitignore` patterns

## Testing

### Test Suite

The project includes comprehensive test suites for both implementations:

**Bash Test Suite:**
- **Unit Tests**: Test individual functions (URL encoding, service selection, URL construction)
  - `test_url_encode.sh` - Tests URL encoding function with various inputs
  - `test_service_selection.sh` - Tests service selection validation and resolution
  - `test_url_construction.sh` - Tests URL construction using `build_search_urls()` function
- **Acceptance Tests**: End-to-end tests with mocked browser opening
  - `test_acceptance.sh` - Full script execution tests with mocked `open` command
- **No external dependencies**: Pure bash implementation with simple assertion helpers
- **Test Mode**: Script supports `HUNT_TEST_MODE` environment variable to skip sleep delays during testing

**Go Test Suite:**
- **Unit Tests**: Test individual functions with table-driven tests
  - `url_test.go` - URL encoding and construction tests (100% coverage)
  - `selection_test.go` - Service selection resolution and parsing tests (100% coverage)
  - `config_test.go` - JSON configuration loading tests (88.9% coverage)
- **Integration Tests**: Test function interactions and full pipeline
  - `integration_test.go` - Integration tests for URL construction, service selection, and URL building
- **Test Coverage**: 33.3% overall (core functions have 88-100% coverage)
- **Standard Go testing**: Uses Go's built-in testing package, no external dependencies

### Running Tests

```bash
# Run all tests (no dependencies required)
./tests/run_tests.sh
```

### Test Coverage

- URL encoding with various inputs (spaces, special characters, unicode)
- Service selection validation (numbers, names, case-insensitivity)
- URL construction for all search engines (direct testing via `build_search_urls()`)
- JSON configuration loading and validation
- End-to-end script execution with all modes
- Argument parsing and flag handling
- Error handling (missing search term, invalid services)
- Test mode optimization (HUNT_TEST_MODE skips sleep delays for faster test execution)

See `tests/README.md` for detailed testing documentation.

### Manual Testing Notes

- Tested on macOS (darwin 24.6.0)
- Default browser behavior: Opens URLs in new tabs when browser is already running
- If browser is not running, first URL opens browser, subsequent URLs open in new tabs

## Recent Work & Session Context

### Documentation Updates (Latest Session)
- ✅ Updated PROJECT_CONTEXT.md to reflect current implementation (space_delimiter feature, numbering fixes)
- ✅ Added future enhancements: browser extension, system path integration, Homebrew distribution, Go port
- ✅ Added .gitignore file for common OS and editor files
- ✅ Added MIT License to project
- ✅ Added development guidelines for destructive git operations and bash commands
- ✅ Updated file structure documentation to include LICENSE and .gitignore
- ✅ Added repository and development setup information

### Current Repository State
- All changes are committed and pushed to `origin/main`
- Repository is in sync with remote (https://github.com/aneely/hunt)
- Working tree is clean
- Git remote configured for HTTPS with GitHub CLI authentication

### Important Context for Future Sessions
- **Git Remote**: Uses HTTPS (not SSH) due to SSH key verification issues
- **GitHub CLI**: Authenticated and configured for git operations
- **Development Guidelines**: See "Development Guidelines" section above for policies on destructive operations
- **Project Status**: MVP complete, documentation up to date, ready for enhancements

## Next Steps

1. ✅ ~~Test with all 8 search engines to verify all tabs open correctly~~ (Completed)
2. ✅ ~~Add configuration support for selecting which services to use~~ (Completed - via `-i` and `-s` flags)
3. ✅ ~~Port to Go for cross-platform support~~ (Completed - full feature parity with comprehensive tests)
4. Consider adding other service categories from `initial-sketch.md` (Reddit, StackOverflow, Wikipedia, etc.)
5. Improve error handling and user feedback
6. Add service aliases for shorter names (e.g., `ddg` for DuckDuckGo)
7. Consider service category grouping and category-based selection
8. Create Homebrew formula for Go binary distribution
9. Add system path integration for easier installation

