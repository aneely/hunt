#!/bin/bash

# hunt.sh - Meta-search CLI tool
# Opens a search term across multiple search engines simultaneously

# Define search engines early (needed for service name validation during parsing)
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

# Helper function to check if an argument looks like a service selection
is_service_selection() {
    local arg="$1"
    # Check if it's "all" (case-insensitive)
    if [ "$(echo "$arg" | tr '[:upper:]' '[:lower:]')" = "all" ]; then
        return 0
    fi
    # Check if it's a number 1-9
    if [[ "$arg" =~ ^[0-9]+$ ]]; then
        local num=$((arg))
        if [ "$num" -ge 1 ] && [ "$num" -le 9 ]; then
            return 0
        fi
    fi
    # Check if it matches a service name (case-insensitive)
    for name in "${SEARCH_ENGINE_NAMES[@]}"; do
        if [ "$(echo "$name" | tr '[:upper:]' '[:lower:]')" = "$(echo "$arg" | tr '[:upper:]' '[:lower:]')" ]; then
            return 0
        fi
    done
    return 1
}

# Parse command-line arguments
INTERACTIVE=false
SERVICES_FLAG=false
SERVICE_NUMBERS=()
SEARCH_TERM=""
REMAINING_ARGS=()

# First pass: collect flags and service selections
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interactive)
            INTERACTIVE=true
            shift
            ;;
        -s|--services)
            SERVICES_FLAG=true
            shift
            # Collect service selections until we hit '--', another flag, or something that doesn't look like a service
            while [[ $# -gt 0 ]] && [[ "$1" != "--" ]] && [[ "$1" != -* ]]; do
                if is_service_selection "$1"; then
                    SERVICE_NUMBERS+=("$1")
                    shift
                else
                    # This doesn't look like a service, so it's the start of the search term
                    break
                fi
            done
            # If we hit '--', skip it
            if [[ "$1" == "--" ]]; then
                shift
            fi
            ;;
        --)
            # Explicit separator: everything after this is the search term
            shift
            while [[ $# -gt 0 ]]; do
                REMAINING_ARGS+=("$1")
                shift
            done
            break
            ;;
        *)
            # Collect remaining arguments for second pass
            REMAINING_ARGS+=("$1")
            shift
            ;;
    esac
done

# Second pass: remaining args (after flags and services) are the search term
for arg in "${REMAINING_ARGS[@]}"; do
    if [ -z "$SEARCH_TERM" ]; then
        SEARCH_TERM="$arg"
    else
        SEARCH_TERM="$SEARCH_TERM $arg"
    fi
done

# Check if search term is provided
if [ -z "$SEARCH_TERM" ]; then
    echo "Usage: $0 [-i|--interactive] [-s|--services SELECTION ...] <search term>"
    echo "Example: $0 'machine learning'"
    echo "Example: $0 -i 'machine learning'"
    echo "Example: $0 -s 1 3 5 'machine learning'"
    echo "Example: $0 -s Bing Google Mojeek 'machine learning'"
    echo "Example: $0 -s 1 Google 5 'machine learning'"
    echo ""
    echo "Options:"
    echo "  -i, --interactive         Interactive mode to select search engines"
    echo "  -s, --services SELECTION Specify search engines by number (1-8, 9 for all) or name"
    exit 1
fi

# Validate that interactive and services flags are not both used
if [ "$INTERACTIVE" = true ] && [ "$SERVICES_FLAG" = true ]; then
    echo "Error: Cannot use both -i/--interactive and -s/--services flags together."
    exit 1
fi

# URL encode the search term using Python for robust encoding
url_encode() {
    python3 -c "import urllib.parse; print(urllib.parse.quote('$1'))"
}

ENCODED_TERM=$(url_encode "$SEARCH_TERM")

# Search engine names already defined above for parsing
# Define search engine URLs

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

# Function to resolve a service name or number to an index
# Returns -1 if not found
resolve_service_selection() {
    local selection="$1"
    local all_option=$((${#SEARCH_ENGINE_NAMES[@]} + 1))
    
    # Check if it's "all" option
    if [ "$selection" = "all" ] || [ "$selection" = "All" ] || [ "$selection" = "ALL" ]; then
        # Return special marker for "all"
        echo "all"
        return
    fi
    
    # Check if it's a number (for "all" option)
    if [[ "$selection" =~ ^[0-9]+$ ]]; then
        if [ "$selection" -eq "$all_option" ]; then
            echo "all"
            return
        fi
        # Convert 1-indexed to 0-indexed
        local idx=$((selection - 1))
        if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#SEARCH_ENGINE_NAMES[@]}" ]; then
            echo "$idx"
            return
        fi
    fi
    
    # Try to match by name (case-insensitive)
    for i in "${!SEARCH_ENGINE_NAMES[@]}"; do
        local name="${SEARCH_ENGINE_NAMES[$i]}"
        # Case-insensitive comparison
        if [ "$(echo "$name" | tr '[:upper:]' '[:lower:]')" = "$(echo "$selection" | tr '[:upper:]' '[:lower:]')" ]; then
            echo "$i"
            return
        fi
    done
    
    # Not found
    echo "-1"
}

# Function to parse service selections (numbers or names) and populate SELECTED_INDICES
parse_service_selections() {
    local selections=("$@")
    SELECTED_INDICES=()
    
    for selection in "${selections[@]}"; do
        local resolved=$(resolve_service_selection "$selection")
        
        if [ "$resolved" = "all" ]; then
            # Select all indices
            SELECTED_INDICES=()
            for i in "${!SEARCH_ENGINE_NAMES[@]}"; do
                SELECTED_INDICES+=($i)
            done
            break
        elif [ "$resolved" != "-1" ]; then
            SELECTED_INDICES+=($resolved)
        else
            echo "Warning: Invalid selection '$selection', skipping..."
        fi
    done
    
    # Remove duplicates (in case user specified same number twice)
    # Simple approach: create new array with unique values
    local unique_indices=()
    for idx in "${SELECTED_INDICES[@]}"; do
        local found=0
        for uidx in "${unique_indices[@]}"; do
            if [ "$idx" -eq "$uidx" ]; then
                found=1
                break
            fi
        done
        if [ $found -eq 0 ]; then
            unique_indices+=($idx)
        fi
    done
    SELECTED_INDICES=("${unique_indices[@]}")
}

# Main function to orchestrate the search process
main() {
    # Determine which engines to use
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
        
        # Parse user input (split by spaces)
        local user_selections=($user_input)
        parse_service_selections "${user_selections[@]}"
        
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
    elif [ "$SERVICES_FLAG" = true ]; then
        # Services flag mode: use provided service numbers
        if [ ${#SERVICE_NUMBERS[@]} -eq 0 ]; then
            echo "Error: -s/--services flag requires at least one service number."
            echo "Usage: $0 -s 1 3 5 'search term'"
            exit 1
        fi
        
        parse_service_selections "${SERVICE_NUMBERS[@]}"
        
        # If no valid selections, exit
        if [ ${#SELECTED_INDICES[@]} -eq 0 ]; then
            echo "No valid search engines selected. Exiting."
            exit 1
        fi
        
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
}

# Invoke main function
main

