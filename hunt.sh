#!/bin/bash

# hunt.sh - Meta-search CLI tool
# Opens a search term across multiple search engines simultaneously

# Check if search term is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <search term>"
    echo "Example: $0 'machine learning'"
    exit 1
fi

# Get search term from command line arguments
SEARCH_TERM="$*"

# URL encode the search term using Python for robust encoding
url_encode() {
    python3 -c "import urllib.parse; print(urllib.parse.quote('$1'))"
}

ENCODED_TERM=$(url_encode "$SEARCH_TERM")

# Define search engines using parallel arrays (for bash 3.2 compatibility)
SEARCH_ENGINE_NAMES=(
    "Bing"
    "DuckDuckGo"
    "Google"
    "Kagi"
    "Mojeek"
    "StartPage"
    "Yahoo"
    "YouTube"
)

SEARCH_ENGINE_URLS=(
    "https://www.bing.com/search?q="
    "https://duckduckgo.com/?q="
    "https://www.google.com/search?q="
    "https://kagi.com/search?q="
    "https://www.mojeek.com/search?q="
    "https://www.startpage.com/sp/search?q="
    "https://search.yahoo.com/search?p="
    "https://www.youtube.com/results?search_query="
)

# Loop over search engines and open each URL
for i in "${!SEARCH_ENGINE_NAMES[@]}"; do
    engine="${SEARCH_ENGINE_NAMES[$i]}"
    url_base="${SEARCH_ENGINE_URLS[$i]}"
    url="${url_base}${ENCODED_TERM}"
    
    echo "Opening $engine..."
    open "$url" 2>/dev/null
    # Small delay to ensure browser processes each URL as a separate tab
    sleep 0.3
done

echo "Opened searches for: $SEARCH_TERM"
echo "Total search engines: ${#SEARCH_ENGINE_NAMES[@]}"

