package main

import (
	"bufio"
	"flag"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	// Parse flags
	interactive := flag.Bool("i", false, "Interactive mode to select search engines")
	interactiveLong := flag.Bool("interactive", false, "Interactive mode to select search engines")
	servicesFlag := flag.Bool("s", false, "Specify search engines by number or name")
	servicesFlagLong := flag.Bool("services", false, "Specify search engines by number or name")
	flag.Parse()

	// Combine short and long flags
	*interactive = *interactive || *interactiveLong
	*servicesFlag = *servicesFlag || *servicesFlagLong

	// Check for test mode
	testMode := os.Getenv("HUNT_TEST_MODE") != ""

	// Load configuration
	config, err := LoadConfig()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	// Parse arguments manually to handle -s flag with multiple selections
	args := flag.Args()
	var serviceSelections []string
	var searchTermParts []string

	if *servicesFlag {
		// In services mode, collect service selections until we hit something that doesn't look like a service
		for i := 0; i < len(args); i++ {
			arg := args[i]

			if arg == "--" {
				// Explicit separator - everything after is search term
				searchTermParts = args[i+1:]
				break
			}

			// Check if this looks like a service selection
			if isServiceSelection(arg, config.Engines) {
				serviceSelections = append(serviceSelections, arg)
			} else {
				// This doesn't look like a service, so it's the start of the search term
				searchTermParts = args[i:]
				break
			}
		}
	} else {
		// Not in services mode, all remaining args are the search term
		searchTermParts = args
	}

	// Join search term parts
	searchTerm := strings.Join(searchTermParts, " ")

	// Validate search term
	if searchTerm == "" {
		printUsage()
		os.Exit(1)
	}

	// Validate flags
	if *interactive && *servicesFlag {
		fmt.Fprintf(os.Stderr, "Error: Cannot use both -i/--interactive and -s/--services flags together.\n")
		os.Exit(1)
	}

	// Determine which engines to use
	var selectedIndices []int

	if *interactive {
		selectedIndices, err = handleInteractiveMode(config.Engines)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
	} else if *servicesFlag {
		if len(serviceSelections) == 0 {
			fmt.Fprintf(os.Stderr, "Error: -s/--services flag requires at least one service selection.\n")
			fmt.Fprintf(os.Stderr, "Usage: %s -s 1 3 5 'search term'\n", os.Args[0])
			os.Exit(1)
		}

		selectedIndices, err = ParseSelections(serviceSelections, config.Engines)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}

		fmt.Println("Selected search engines:")
		for _, idx := range selectedIndices {
			fmt.Printf("  - %s\n", config.Engines[idx].Name)
		}
		fmt.Println()
	} else {
		// Default: select all engines
		selectedIndices = make([]int, len(config.Engines))
		for i := range config.Engines {
			selectedIndices[i] = i
		}
	}

	// Build URLs
	urls := make([]string, len(selectedIndices))
	engineNames := make([]string, len(selectedIndices))
	for i, idx := range selectedIndices {
		urls[i] = BuildSearchURL(config.Engines[idx], searchTerm)
		engineNames[i] = config.Engines[idx].Name
	}

	// Open URLs
	if err := OpenURLs(urls, engineNames, testMode); err != nil {
		fmt.Fprintf(os.Stderr, "Error opening URLs: %v\n", err)
		os.Exit(1)
	}

	// Summary
	fmt.Println()
	fmt.Printf("Opened searches for: %s\n", searchTerm)
	fmt.Printf("Total search engines used: %d\n", len(selectedIndices))
}

// isServiceSelection checks if an argument looks like a service selection
func isServiceSelection(arg string, engines []SearchEngine) bool {
	argLower := strings.ToLower(strings.TrimSpace(arg))

	// Check for "all"
	if argLower == "all" {
		return true
	}

	// Check if it's a number (0-N where N is the number of engines)
	if num, err := strconv.Atoi(arg); err == nil {
		return num >= 0 && num <= len(engines)
	}

	// Check if it matches an engine name (case-insensitive)
	for _, engine := range engines {
		if strings.EqualFold(engine.Name, arg) {
			return true
		}
	}

	return false
}

// handleInteractiveMode displays the menu and collects user selections
func handleInteractiveMode(engines []SearchEngine) ([]int, error) {
	fmt.Println("Select search engines to use (enter numbers, separated by spaces):")
	fmt.Println()

	// Display "all" option
	fmt.Println("  0) All search engines")

	// Display engines (1-indexed for user)
	for i, engine := range engines {
		fmt.Printf("  %d) %s\n", i+1, engine.Name)
	}

	fmt.Println()
	fmt.Print("Enter selection(s): ")

	// Read user input
	reader := bufio.NewReader(os.Stdin)
	input, err := reader.ReadString('\n')
	if err != nil {
		return nil, fmt.Errorf("failed to read input: %w", err)
	}

	// Parse input (split by spaces)
	input = strings.TrimSpace(input)
	selections := strings.Fields(input)

	indices, err := ParseSelections(selections, engines)
	if err != nil {
		return nil, err
	}

	fmt.Println()
	fmt.Println("Selected search engines:")
	for _, idx := range indices {
		fmt.Printf("  - %s\n", engines[idx].Name)
	}
	fmt.Println()

	return indices, nil
}

func printUsage() {
	fmt.Fprintf(os.Stderr, "Usage: %s [-i|--interactive] [-s|--services SELECTION ...] <search term>\n", os.Args[0])
	fmt.Fprintf(os.Stderr, "Example: %s 'machine learning'\n", os.Args[0])
	fmt.Fprintf(os.Stderr, "Example: %s -i 'machine learning'\n", os.Args[0])
	fmt.Fprintf(os.Stderr, "Example: %s -s 1 3 5 'machine learning'\n", os.Args[0])
	fmt.Fprintf(os.Stderr, "Example: %s -s Bing Google Mojeek 'machine learning'\n", os.Args[0])
	fmt.Fprintf(os.Stderr, "Example: %s -s 1 Google 5 'machine learning'\n", os.Args[0])
	fmt.Fprintf(os.Stderr, "\n")
	fmt.Fprintf(os.Stderr, "Options:\n")
	fmt.Fprintf(os.Stderr, "  -i, --interactive         Interactive mode to select search engines\n")
	fmt.Fprintf(os.Stderr, "  -s, --services SELECTION Specify search engines by number (0 for all, 1-N for engines) or name\n")
}

