# Hunt - Meta-Search CLI Tool

**Hunt** is a command-line tool that opens a search query across multiple search engines simultaneously in your default browser. Search once, get results from multiple engines in separate browser tabs.

## Features

- 🔍 Search across 8 popular search engines with a single command
- 🎯 Interactive mode to select specific search engines
- 🎛️ Command-line service selection with `-s`/`--services` flag
- 📝 Support for service names or numbers (mix and match)
- 🌐 Opens results in separate browser tabs
- 🚀 Fast and lightweight - simple bash script
- 🍎 macOS optimized (uses native `open` command)

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

- macOS (uses `open` command)
- Bash 3.2+ (default on macOS)

## Installation

1. Clone or download this repository
2. Make the script executable:
   ```bash
   chmod +x hunt.sh
   ```

## Usage

### Basic Usage

Search across all search engines:

```bash
./hunt.sh "your search term"
```

Example:
```bash
./hunt.sh "machine learning algorithms"
```

This will open 8 browser tabs, one for each search engine with your search query.

### Interactive Mode

Select specific search engines to use:

```bash
./hunt.sh -i "your search term"
# or
./hunt.sh --interactive "your search term"
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
./hunt.sh -s SELECTION ... "your search term"
# or
./hunt.sh --services SELECTION ... "your search term"
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
- **URL Encoding**: Handles spaces, special characters, and Unicode properly
- **Sequential Opening**: Opens URLs one at a time with 0.3 second delays to ensure reliable tab creation
- **Duplicate Handling**: Automatically removes duplicate service selections

## Project Structure

```
hunt/
├── hunt.sh              # Main executable script
├── search_engines.json  # Search engine definitions
├── README.md            # This file
├── PROJECT_CONTEXT.md   # Detailed project documentation
├── initial-sketch.md   # Original project specification
├── LICENSE              # MIT License
└── .gitignore          # Git ignore patterns
```

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
- **Go Port**: Port the project to Go for cross-platform distribution as a single portable binary

## Troubleshooting

**Only some tabs are opening:**
- Make sure your browser is running before executing the script
- The script uses sequential opening with delays - if your browser is slow, you may need to increase the delay

**Script doesn't work:**
- Ensure the script is executable: `chmod +x hunt.sh`
- Verify you're on macOS (the `open` command is macOS-specific)
- Check that standard Unix utilities are available (`od` command for URL encoding)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! See `PROJECT_CONTEXT.md` for technical details and development notes.

