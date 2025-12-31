#!/bin/bash

# hunt.sh - Meta-search CLI tool
# Opens a search term across multiple search engines simultaneously

# Parse command-line arguments
INTERACTIVE=false
SEARCH_TERM=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interactive)
            INTERACTIVE=true
            shift
            ;;
        *)
            # Everything else is part of the search term
            if [ -z "$SEARCH_TERM" ]; then
                SEARCH_TERM="$1"
            else
                SEARCH_TERM="$SEARCH_TERM $1"
            fi
            shift
            ;;
    esac
done

# Check if search term is provided
if [ -z "$SEARCH_TERM" ]; then
    echo "Usage: $0 [-i|--interactive] <search term>"
    echo "Example: $0 'machine learning'"
    echo "Example: $0 -i 'machine learning'"
    exit 1
fi

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

# Interactive mode: let user select which engines to use
SELECTED_INDICES=()
if [ "$INTERACTIVE" = true ]; then
    echo "Select search engines to use (enter numbers, separated by spaces):"
    echo ""
    
    # Display list of engines with numbers (1-indexed for user)
    for i in "${!SEARCH_ENGINE_NAMES[@]}"; do
        num=$((i + 1))
        echo "  $num) ${SEARCH_ENGINE_NAMES[$i]}"
    done
    
    # Display "all" option (0-indexed would be array length + 1)
    all_option=$((${#SEARCH_ENGINE_NAMES[@]} + 1))
    echo "  $all_option) All search engines"
    echo ""
    echo -n "Enter selection(s): "
    read -r user_input
    
    # Parse user input
    for selection in $user_input; do
        # Check if user selected "all"
        if [ "$selection" -eq "$all_option" ]; then
            # Select all indices
            for i in "${!SEARCH_ENGINE_NAMES[@]}"; do
                SELECTED_INDICES+=($i)
            done
            break
        else
            # Convert 1-indexed user input to 0-indexed array index
            idx=$((selection - 1))
            # Validate index is in range
            if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#SEARCH_ENGINE_NAMES[@]}" ]; then
                SELECTED_INDICES+=($idx)
            else
                echo "Warning: Invalid selection $selection, skipping..."
            fi
        fi
    done
    
    # If no valid selections, exit
    if [ ${#SELECTED_INDICES[@]} -eq 0 ]; then
        echo "No valid search engines selected. Exiting."
        exit 1
    fi
    
    echo ""
    echo "Selected search engines:"
    for idx in "${SELECTED_INDICES[@]}"; do
        echo "  - ${SEARCH_ENGINE_NAMES[$idx]}"
    done
    echo ""
else
    # Non-interactive mode: select all engines
    for i in "${!SEARCH_ENGINE_NAMES[@]}"; do
        SELECTED_INDICES+=($i)
    done
fi

# Loop over selected search engines and open each URL
for idx in "${SELECTED_INDICES[@]}"; do
    engine="${SEARCH_ENGINE_NAMES[$idx]}"
    url_base="${SEARCH_ENGINE_URLS[$idx]}"
    url="${url_base}${ENCODED_TERM}"
    
    echo "Opening $engine..."
    open "$url" 2>/dev/null
    # Small delay to ensure browser processes each URL as a separate tab
    sleep 0.3
done

echo ""
echo "Opened searches for: $SEARCH_TERM"
echo "Total search engines used: ${#SELECTED_INDICES[@]}"

