# Hunt - Meta-Search CLI Tool

**Hunt** is a command-line tool that opens a search query across multiple search engines simultaneously in your default browser. Search once, get results from multiple engines in separate browser tabs.

## Features

- 🔍 Search across 8 popular search engines with a single command
- 🎯 Interactive mode to select specific search engines
- 🎛️ Command-line service selection with `-s`/`--services` flag
- 📝 Support for service names or numbers (mix and match)
- 🌐 Opens results in separate browser tabs
- 🚀 **Two implementations available**: Bash script and Go binary
- 🍎 Cross-platform support (macOS, Linux, Windows) via Go port
- ✅ Comprehensive test suite for both implementations

## Supported Search Engines

1. Bing
2. DuckDuckGo
3. Google
4. Kagi
5. Mojeek
6. StartPage
7. Yahoo
8. YouTube

## Requirements

### Bash Version
- macOS (uses `open` command)
- Bash 3.2+ (default on macOS)

### Go Version
- Go 1.21+ (for building from source)
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

Both the bash and Go versions support the same command-line interface.

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
./hunt.sh "machine learning algorithms"
```

This will open 8 browser tabs, one for each search engine with your search query.

### Interactive Mode

Select specific search engines to use:

```bash
# Bash version
./hunt.sh -i "your search term"
# or
./hunt.sh --interactive "your search term"

# Go version
./hunt -i "your search term"
# or
./hunt --interactive "your search term"
```

When you run in interactive mode, you'll see a numbered list of search engines:

```
Select search engines to use (enter numbers, separated by spaces):

  0) All search engines
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

You can:
- Enter a single number: `3` (searches only Google)
- Enter multiple numbers: `1 3 5` (searches Bing, Google, and Mojeek)
- Enter `0` to select all search engines

### Services Flag Mode

Select specific search engines directly from the command line without interactive prompts:

```bash
# Bash version
./hunt.sh -s SELECTION ... "your search term"
# or
./hunt.sh --services SELECTION ... "your search term"

# Go version
./hunt -s SELECTION ... "your search term"
# or
./hunt --services SELECTION ... "your search term"
```

You can specify engines by:
- **Number**: `0` for all, or `1` through `8` (corresponds to the numbered list above)
- **Name**: The exact service name (case-insensitive), e.g., `Bing`, `Google`, `YouTube`
- **"all"**: Select all search engines

**Examples:**

```bash
# Select by numbers
./hunt.sh -s 1 3 5 "machine learning"
# Searches: Bing (1), Google (3), Mojeek (5)

# Select by names
./hunt.sh -s Bing Google "machine learning"
# Searches: Bing and Google

# Mix numbers and names
./hunt.sh -s 1 Google 5 "machine learning"
# Searches: Bing (1), Google, Mojeek (5)

# Select all engines
./hunt.sh -s all "machine learning"
# or
./hunt.sh -s 0 "machine learning"
```

**Note**: The script automatically detects when service selections end and the search term begins. If you need to be explicit, you can use `--` as a separator:
```bash
./hunt.sh -s Bing Google -- "test search"
```

### Examples

```bash
# Search all engines for "python tutorials"
./hunt.sh "python tutorials"

# Interactive mode - select specific engines
./hunt.sh -i "bash scripting"

# Services flag - select by numbers
./hunt.sh -s 1 3 5 "python tutorials"

# Services flag - select by names
./hunt.sh -s Bing Google YouTube "python tutorials"

# Services flag - mix numbers and names
./hunt.sh -s 1 Google 5 "python tutorials"

# Search with special characters (automatically URL-encoded)
./hunt.sh "C++ programming"
```

## How It Works

1. **Argument Parsing**: The script parses command-line flags (`-i`, `-s`) and service selections
2. **Service Selection**: In interactive mode, prompts for selection. With `-s` flag, validates service names/numbers automatically
3. **Input Processing**: The script takes your search term and URL-encodes it using a bash-native implementation
4. **URL Construction**: For each selected search engine, it constructs the appropriate search URL with your encoded query
5. **Browser Opening**: Uses macOS's `open` command to open each URL in your default browser
6. **Tab Management**: Opens URLs sequentially with small delays to ensure each opens in a separate tab

## Technical Details

- **Bash Compatibility**: Uses parallel arrays instead of associative arrays for compatibility with bash 3.2 (macOS default)
- **Service Name Matching**: Case-insensitive matching for service names (e.g., `bing`, `Bing`, `BING` all work)
- **Automatic Detection**: The `-s` flag automatically detects when service selections end and the search term begins
- **URL Encoding**: Handles spaces, special characters, and Unicode properly using bash-native implementation
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

- Additional service categories (Reddit, StackOverflow, Wikipedia, etc.)
- Configuration file for custom service definitions
- Browser detection and optimization
- Service category selection
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
- **Go version**: Ensure Go is installed (1.21+) if building from source
- **Go version**: Verify `search_engines.json` is in the same directory as the binary

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! See `PROJECT_CONTEXT.md` for technical details and development notes.

