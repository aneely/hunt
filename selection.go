package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

// ResolveSelection resolves a service selection (number or name) to an engine index
// Returns the index, or -1 if not found, or -2 if "all" is selected
func ResolveSelection(selection string, engines []SearchEngine) int {
	selection = strings.TrimSpace(selection)
	selectionLower := strings.ToLower(selection)

	// Check for "all" option
	if selectionLower == "all" || selection == "0" {
		return -2 // Special marker for "all"
	}

	// Check if it's a number
	if num, err := strconv.Atoi(selection); err == nil {
		if num == 0 {
			return -2 // "all" option
		}
		// Convert 1-indexed to 0-indexed
		idx := num - 1
		if idx >= 0 && idx < len(engines) {
			return idx
		}
		return -1 // Invalid number
	}

	// Try to match by name (case-insensitive)
	for i, engine := range engines {
		if strings.EqualFold(engine.Name, selection) {
			return i
		}
	}

	return -1 // Not found
}

// ParseSelections parses service selections and returns a list of engine indices
// Removes duplicates and handles "all" selection
func ParseSelections(selections []string, engines []SearchEngine) ([]int, error) {
	var indices []int
	seen := make(map[int]bool)

	for _, selection := range selections {
		resolved := ResolveSelection(selection, engines)

		if resolved == -2 {
			// "all" selected - return all indices
			allIndices := make([]int, len(engines))
			for i := range engines {
				allIndices[i] = i
			}
			return allIndices, nil
		}

		if resolved == -1 {
			fmt.Fprintf(os.Stderr, "Warning: Invalid selection '%s', skipping...\n", selection)
			continue
		}

		// Add to list if not already seen (remove duplicates)
		if !seen[resolved] {
			indices = append(indices, resolved)
			seen[resolved] = true
		}
	}

	if len(indices) == 0 {
		return nil, fmt.Errorf("no valid search engines selected")
	}

	return indices, nil
}

