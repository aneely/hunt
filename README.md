# Hunt - Meta-Search CLI Tool

**Hunt** is a command-line tool that opens a search query across multiple search engines simultaneously in your default browser. Search once, get results from multiple engines in separate browser tabs.

## Features

- 🔍 Search across 8 popular search engines with a single command
- 🛒 **Subcommands**: Search shopping sites with `shop` subcommand (Go version)
- 🎯 Interactive mode to select specific services
- 🎛️ Command-line service selection with `-s`/`--services` flag
- 📝 Support for service names or numbers (mix and match)
- 🌐 Opens results in separate browser tabs
- 🚀 **Two implementations available**: Bash script and Go binary
- 🍎 Cross-platform support (macOS, Linux, Windows) via Go port
- ✅ Comprehensive test suite for both implementations

## Supported Services

### Search Engines (Default)
1. Bing
2. DuckDuckGo
3. Google
4. Kagi
5. Mojeek
6. StartPage
7. Yahoo
8. YouTube

### Shopping Sites (Go version - use `shop` subcommand)
1. Amazon
2. eBay
3. Gazelle
4. Slick Deals
5. Swappa

### Tech News Sites (Go version - use `technews` subcommand)
1. Hacker News
2. Lobste.rs
3. Engadget
4. The Verge

### News Sites (Go version - use `news` subcommand)
1. NPR
2. NYT
3. WSJ

## Requirements

### Bash Version
- macOS (uses `open` command)
- Bash 3.2+ (default on macOS)

### Go Version
- Go 1.24+ (for building from source)
- Cross-platform: macOS, Linux, Windows
- Single binary - no runtime dependencies

## Installation

### Bash Version

1. Clone or download this repository
2. Make the script executable:
   ```bash
   chmod +x hunt.sh
   ```

### Go Version

**Option 1: Build from source**
```bash
go build -o hunt .
```

**Option 2: Run directly (development)**
```bash
go run . "your search term"
```

The Go version provides the same functionality as the bash version with:
- Cross-platform support (macOS, Linux, Windows)
- Single portable binary
- Better error handling
- Comprehensive test suite

## Usage

Both the bash and Go versions support the same command-line interface. The Go version also supports subcommands for different service categories.

### Basic Usage

**Bash version:**
```bash
./hunt.sh "your search term"
```

**Go version:**
```bash
./hunt "your search term"
# or
go run . "your search term"
```

Example:
```bash
./hunt "machine learning algorithms"
```

This will open 8 browser tabs, one for each search engine with your search query.

### Subcommands (Go version)

The Go version supports subcommands to search different categories of services. Subcommands come **before** flags for backward compatibility.

**Default (Search Engines):**
```bash
./hunt "your search term"
# Searches across all search engines (default behavior)
```

**Shopping Sites:**
```bash
./hunt shop "laptop"
# or
./hunt shopping "laptop"
# Searches across all shopping sites
```

**Tech News Sites:**
```bash
./hunt technews "AI"
# or
./hunt tech-news "AI"
# or
./hunt tech "AI"
# Searches across all tech news sites
```

**News Sites:**
```bash
./hunt news "election"
# Searches across all news sites
```

Subcommands work with all existing flags:
```bash
# Interactive mode with shopping sites
./hunt shop -i "laptop"

# Select specific shopping sites
./hunt shop -s 1 3 "laptop"
# Selects Amazon (1) and Gazelle (3)

# Select by name
./hunt shop -s Amazon eBay "laptop"
```

### Interactive Mode

Select specific services to use:

```bash
# Bash version
./hunt.sh -i "your search term"
# or
./hunt.sh --interactive "your search term"

# Go version (search engines)
./hunt -i "your search term"
# or
./hunt --interactive "your search term"

# Go version (shopping sites)
./hunt shop -i "laptop"

# Go version (tech news sites)
./hunt technews -i "AI"

# Go version (news sites)
./hunt news -i "election"
```

**Go version interactive mode flow:**

When you run `./hunt -i` (no subcommand), you'll first see a category selection menu:

```
Select category:

  1) Search Engines
  2) Shopping Sites
  3) Tech News
  4) News

Enter category number:
```

After selecting a category, you'll see the service selection menu for that category.

When you run `./hunt shop -i` (with subcommand), it skips category selection and goes directly to the service menu for that category.

**Service selection menu:**

When you run in interactive mode, you'll see a numbered list of services for the selected category:

**Search Engines (default):**
```
Select services to use (enter numbers, separated by spaces):

  0) All services
  1) Bing
  2) DuckDuckGo
  3) Google
  4) Kagi
  5) Mojeek
  6) StartPage
  7) Yahoo
  8) YouTube

Enter selection(s):
```

**Shopping Sites (with `shop` subcommand):**
```
Select services to use (enter numbers, separated by spaces):

  0) All services
  1) Amazon
  2) eBay
  3) Gazelle
  4) Slick Deals
  5) Swappa

Enter selection(s):
```

**Tech News Sites (with `technews` subcommand):**
```
Select services to use (enter numbers, separated by spaces):

  0) All services
  1) Hacker News
  2) Lobste.rs
  3) Engadget
  4) The Verge

Enter selection(s):
```

**News Sites (with `news` subcommand):**
```
Select services to use (enter numbers, separated by spaces):

  0) All services
  1) NPR
  2) NYT
  3) WSJ

Enter selection(s):
```

You can:
- Enter a single number: `3` (searches only Google or Gazelle, depending on category)
- Enter multiple numbers: `1 3 5` (searches multiple services)
- Enter `0` to select all services in the category

### Services Flag Mode

Select specific services directly from the command line without interactive prompts:

```bash
# Bash version
./hunt.sh -s SELECTION ... "your search term"
# or
./hunt.sh --services SELECTION ... "your search term"

# Go version (search engines)
./hunt -s SELECTION ... "your search term"
# or
./hunt --services SELECTION ... "your search term"

# Go version (shopping sites)
./hunt shop -s SELECTION ... "laptop"
```

You can specify services by:
- **Number**: `0` for all, or `1` through `N` (corresponds to the numbered list for the selected category)
- **Name**: The exact service name (case-insensitive), e.g., `Bing`, `Google`, `Amazon`, `eBay`
- **"all"**: Select all services in the category

**Examples:**

```bash
# Search engines - select by numbers
./hunt -s 1 3 5 "machine learning"
# Searches: Bing (1), Google (3), Mojeek (5)

# Search engines - select by names
./hunt -s Bing Google "machine learning"
# Searches: Bing and Google

# Shopping sites - select by numbers
./hunt shop -s 1 3 "laptop"
# Searches: Amazon (1), Gazelle (3)

# Shopping sites - select by names
./hunt shop -s Amazon eBay "laptop"
# Searches: Amazon and eBay

# Tech news sites - select by numbers
./hunt technews -s 1 3 "AI"
# Searches: Hacker News (1), Engadget (3)

# Tech news sites - select by names
./hunt technews -s "Hacker News" "The Verge" "AI"
# Searches: Hacker News and The Verge

# News sites - select by numbers
./hunt news -s 1 2 "election"
# Searches: NPR (1), NYT (2)

# News sites - select by names
./hunt news -s NPR WSJ "election"
# Searches: NPR and WSJ

# Mix numbers and names
./hunt -s 1 Google 5 "machine learning"
# Searches: Bing (1), Google, Mojeek (5)

# Select all services in category
./hunt -s all "machine learning"
# or
./hunt -s 0 "machine learning"
```

**Note**: The script automatically detects when service selections end and the search term begins. If you need to be explicit, you can use `--` as a separator:
```bash
./hunt -s Bing Google -- "test search"
```

### Examples

**Search Engines (Default):**
```bash
# Search all engines for "python tutorials"
./hunt "python tutorials"

# Interactive mode - select specific engines
./hunt -i "bash scripting"

# Services flag - select by numbers
./hunt -s 1 3 5 "python tutorials"

# Services flag - select by names
./hunt -s Bing Google YouTube "python tutorials"

# Services flag - mix numbers and names
./hunt -s 1 Google 5 "python tutorials"

# Search with special characters (automatically URL-encoded)
./hunt "C++ programming"
```

**Shopping Sites (Go version):**
```bash
# Search all shopping sites
./hunt shop "laptop"

# Interactive mode - select specific shopping sites
./hunt shop -i "laptop"

# Services flag - select by numbers
./hunt shop -s 1 3 "laptop"
# Searches: Amazon (1), Gazelle (3)

# Services flag - select by names
./hunt shop -s Amazon eBay "laptop"

# Mix numbers and names
./hunt shop -s 1 eBay 3 "laptop"
```

**Tech News Sites (Go version):**
```bash
# Search all tech news sites
./hunt technews "AI"

# Interactive mode - select specific tech news sites
./hunt technews -i "machine learning"

# Services flag - select by numbers
./hunt technews -s 1 3 "AI"
# Searches: Hacker News (1), Engadget (3)

# Services flag - select by names
./hunt technews -s "Hacker News" "The Verge" "AI"

# Mix numbers and names
./hunt technews -s 1 "The Verge" 3 "AI"
```

**News Sites (Go version):**
```bash
# Search all news sites
./hunt news "election"

# Interactive mode - select specific news sites
./hunt news -i "politics"

# Services flag - select by numbers
./hunt news -s 1 2 "election"
# Searches: NPR (1), NYT (2)

# Services flag - select by names
./hunt news -s NPR WSJ "election"

# Mix numbers and names
./hunt news -s 1 WSJ "election"
```

## How It Works

1. **Subcommand Parsing** (Go version): Detects subcommands (e.g., `shop`) before parsing flags for backward compatibility
2. **Category Selection**: Filters services by category (default: `search`, or `shop` with subcommand)
3. **Argument Parsing**: The script parses command-line flags (`-i`, `-s`) and service selections
4. **Service Selection**: In interactive mode, prompts for selection. With `-s` flag, validates service names/numbers automatically
5. **Input Processing**: The script takes your search term and URL-encodes it appropriately
6. **URL Construction**: For each selected service, it constructs the appropriate search URL with your encoded query
7. **Browser Opening**: Uses platform-specific commands (`open` on macOS, `xdg-open` on Linux, `cmd /c start` on Windows) to open each URL
8. **Tab Management**: Opens URLs sequentially with small delays to ensure each opens in a separate tab

## Technical Details

- **Bash Compatibility**: Uses parallel arrays instead of associative arrays for compatibility with bash 3.2 (macOS default)
- **Category-Based Configuration** (Go version): Services organized by category in JSON (e.g., `search`, `shop`)
- **Subcommand Parsing** (Go version): Subcommands parsed before flags to maintain backward compatibility
- **Service Name Matching**: Case-insensitive matching for service names (e.g., `bing`, `Bing`, `BING` all work)
- **Automatic Detection**: The `-s` flag automatically detects when service selections end and the search term begins
- **URL Encoding**: Handles spaces, special characters, and Unicode properly
- **Sequential Opening**: Opens URLs one at a time with 0.3 second delays to ensure reliable tab creation
- **Duplicate Handling**: Automatically removes duplicate service selections
- **Test Mode**: Supports `HUNT_TEST_MODE` environment variable to skip delays during automated testing
- **Modular Functions**: Code organized into testable functions (URL encoding, service selection, URL construction)

## Project Structure

```
hunt/
├── hunt.sh              # Bash implementation
├── search_engines.json  # Search engine definitions
├── README.md            # This file
├── PROJECT_CONTEXT.md   # Detailed project documentation
├── CLAUDE.md            # AI assistant instructions
├── initial-sketch.md   # Original project specification
├── LICENSE              # MIT License
├── .gitignore          # Git ignore patterns
├── go.mod              # Go module definition
├── main.go             # Go implementation - main entry point
├── config.go           # Go - JSON configuration loading
├── url.go              # Go - URL encoding and construction
├── selection.go        # Go - Service selection logic
├── browser.go          # Go - Cross-platform browser opening
├── *_test.go           # Go test files (unit and integration tests)
└── tests/               # Bash test suite
    ├── README.md        # Test documentation
    ├── run_tests.sh     # Test runner script
    ├── test_helpers.sh  # Test helper functions
    ├── test_url_encode.sh  # URL encoding unit tests
    ├── test_service_selection.sh  # Service selection unit tests
    ├── test_url_construction.sh   # URL construction unit tests
    └── test_acceptance.sh  # End-to-end acceptance tests
```

## Testing

### Bash Test Suite

The bash implementation includes a comprehensive test suite:

```bash
# Run all bash tests
./tests/run_tests.sh
```

### Go Test Suite

The Go implementation includes unit and integration tests:

```bash
# Run all Go tests
go test ./...

# Run with coverage
go test -cover ./...

# Run with verbose output
go test -v ./...
```

**Test Coverage:**
- URL encoding: 100% coverage
- URL construction: 100% coverage
- Service selection: 100% coverage
- Configuration loading: 88.9% coverage
- Integration tests for full pipeline

See `tests/README.md` for detailed bash testing documentation.

## Future Enhancements

Planned features (see `PROJECT_CONTEXT.md` for details):

- ✅ **Subcommands**: Completed! Go version now supports subcommands for different service categories
- ✅ **Help Flag**: Completed! `--help`/`-h` flag displays usage information and exits with code 0
- Additional service categories (Reddit, StackOverflow, Wikipedia)
- Subcommand support in bash version
- Configuration file for custom service definitions
- Browser detection and optimization
- Better error handling
- **Browser Extension**: Create a browser extension for quick access from the browser toolbar
- **System Path Integration**: Package the script for easy installation as a system command (e.g., `hunt` instead of `./hunt.sh`)
- **Homebrew Distribution**: Create a Homebrew formula for easy installation via `brew install hunt`
- ✅ **Go Port**: Completed! Cross-platform Go implementation with comprehensive tests
- **Multi-Platform Testing**: Expand GitHub Actions workflow to test Go implementation on multiple platforms (macOS, Linux, Windows) to ensure cross-platform compatibility

## Troubleshooting

**Only some tabs are opening:**
- Make sure your browser is running before executing the script
- The script uses sequential opening with delays - if your browser is slow, you may need to increase the delay

**Script doesn't work:**
- **Bash version**: Ensure the script is executable: `chmod +x hunt.sh`
- **Bash version**: Verify you're on macOS (the `open` command is macOS-specific)
- **Bash version**: Check that standard Unix utilities are available (`od` command for URL encoding)
- **Go version**: Ensure Go is installed (1.24+) if building from source
- **Go version**: Verify `search_engines.json` is in the same directory as the binary

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! See `PROJECT_CONTEXT.md` for technical details and development notes.

