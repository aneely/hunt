#!/bin/bash

# hunt.sh - Meta-search CLI tool
# Opens a search term across multiple search engines simultaneously

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEARCH_ENGINES_JSON="${SCRIPT_DIR}/search_engines.json"

# Function to load search engines from JSON file
load_search_engines_from_json() {
    local json_file="$1"
    
    # Check if JSON file exists
    if [ ! -f "$json_file" ]; then
        echo "Error: Search engines JSON file not found: $json_file" >&2
        exit 1
    fi
    
    # Initialize arrays
    SEARCH_ENGINE_NAMES=()
    SEARCH_ENGINE_URLS=()
    SEARCH_ENGINE_DELIMITERS=()
    
    # Simple JSON parser for our specific structure
    # Uses sed and grep to extract name, url, and space_delimiter fields
    # Extract all name values
    local names=$(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' "$json_file" | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    # Extract all url values
    local urls=$(grep -o '"url"[[:space:]]*:[[:space:]]*"[^"]*"' "$json_file" | sed 's/.*"url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    # Extract all space_delimiter values (default to "+" if not found)
    local delimiters=$(grep -o '"space_delimiter"[[:space:]]*:[[:space:]]*"[^"]*"' "$json_file" | sed 's/.*"space_delimiter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' || echo "")
    
    # Convert to arrays (one entry per line)
    local name_count=0
    while IFS= read -r name; do
        [ -n "$name" ] && SEARCH_ENGINE_NAMES+=("$name")
        name_count=$((name_count + 1))
    done <<< "$names"
    
    local url_count=0
    while IFS= read -r url; do
        [ -n "$url" ] && SEARCH_ENGINE_URLS+=("$url")
        url_count=$((url_count + 1))
    done <<< "$urls"
    
    # Process delimiters - if fewer delimiters than engines, default to "+"
    local delimiter_count=0
    while IFS= read -r delimiter; do
        if [ -n "$delimiter" ]; then
            SEARCH_ENGINE_DELIMITERS+=("$delimiter")
        else
            # Default to "+" if delimiter not specified
            SEARCH_ENGINE_DELIMITERS+=("+")
        fi
        delimiter_count=$((delimiter_count + 1))
    done <<< "$delimiters"
    
    # Ensure we have a delimiter for each engine (default to "+" if missing)
    while [ ${#SEARCH_ENGINE_DELIMITERS[@]} -lt ${#SEARCH_ENGINE_NAMES[@]} ]; do
        SEARCH_ENGINE_DELIMITERS+=("+")
    done
    
    # Validate we loaded matching counts
    if [ ${#SEARCH_ENGINE_NAMES[@]} -eq 0 ] || [ ${#SEARCH_ENGINE_URLS[@]} -eq 0 ]; then
        echo "Error: No search engines loaded from JSON file" >&2
        exit 1
    fi
    
    if [ ${#SEARCH_ENGINE_NAMES[@]} -ne ${#SEARCH_ENGINE_URLS[@]} ]; then
        echo "Error: Mismatch between number of names and URLs in JSON file" >&2
        exit 1
    fi
    
    if [ ${#SEARCH_ENGINE_NAMES[@]} -ne ${#SEARCH_ENGINE_DELIMITERS[@]} ]; then
        echo "Error: Mismatch between number of names and delimiters in JSON file" >&2
        exit 1
    fi
}

# Load search engines from JSON file
load_search_engines_from_json "$SEARCH_ENGINES_JSON"

# Helper function to check if an argument looks like a service selection
is_service_selection() {
    local arg="$1"
    # Check if it's "all" (case-insensitive)
    if [ "$(echo "$arg" | tr '[:upper:]' '[:lower:]')" = "all" ]; then
        return 0
    fi
    # Check if it's a number 0-8 (0 for all, 1-8 for engines)
    if [[ "$arg" =~ ^[0-9]+$ ]]; then
        local num=$((arg))
        if [ "$num" -ge 0 ] && [ "$num" -le 8 ]; then
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
    echo "  -s, --services SELECTION Specify search engines by number (0 for all, 1-8 for engines) or name"
    exit 1
fi

# Validate that interactive and services flags are not both used
if [ "$INTERACTIVE" = true ] && [ "$SERVICES_FLAG" = true ]; then
    echo "Error: Cannot use both -i/--interactive and -s/--services flags together."
    exit 1
fi

# URL encode the search term using bash-native encoding
# Parameters: $1 = search term string, $2 = space delimiter ("+" or "%20")
url_encode() {
    local string="$1"
    local space_delimiter="${2:-%20}"  # Default to %20 if not specified
    local encoded=""
    local i=0
    local len=${#string}
    
    while [ $i -lt $len ]; do
        local char="${string:$i:1}"
        case "$char" in
            [a-zA-Z0-9._~-])
                # Safe characters - no encoding needed
                encoded="${encoded}${char}"
                ;;
            " ")
                # Space -> use provided delimiter (+ or %20)
                encoded="${encoded}${space_delimiter}"
                ;;
            *)
                # All other characters - encode as %XX using od
                # Convert character to its ASCII/UTF-8 hex value
                local hex=$(echo -n "$char" | od -A n -t x1 | tr -d ' \n' | tr '[:lower:]' '[:upper:]')
                # Format as %XX for each byte (handles multi-byte UTF-8)
                local j=0
                while [ $j -lt ${#hex} ]; do
                    encoded="${encoded}%${hex:$j:2}"
                    j=$((j + 2))
                done
                ;;
        esac
        i=$((i + 1))
    done
    
    echo "$encoded"
}

# Search engines are loaded from JSON file at script startup

# Function to resolve a service name or number to an index
# Returns -1 if not found
resolve_service_selection() {
    local selection="$1"
    
    # Check if it's "all" option
    if [ "$selection" = "all" ] || [ "$selection" = "All" ] || [ "$selection" = "ALL" ]; then
        # Return special marker for "all"
        echo "all"
        return
    fi
    
    # Check if it's a number
    if [[ "$selection" =~ ^[0-9]+$ ]]; then
        # Check if it's 0 (all option)
        if [ "$selection" -eq 0 ]; then
            echo "all"
            return
        fi
        # Convert 1-indexed to 0-indexed (1-8 map to array indices 0-7)
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
        
        # Display "all" option first (0)
        echo "  0) All search engines"
        
        # Display list of engines with numbers (1-indexed for user)
        for i in "${!SEARCH_ENGINE_NAMES[@]}"; do
            num=$((i + 1))
            echo "  $num) ${SEARCH_ENGINE_NAMES[$i]}"
        done
        
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
        delimiter="${SEARCH_ENGINE_DELIMITERS[$idx]}"
        
        # Encode search term with engine-specific delimiter
        encoded_term=$(url_encode "$SEARCH_TERM" "$delimiter")
        url="${url_base}${encoded_term}"
        
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

