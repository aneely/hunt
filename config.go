package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

// SearchEngine represents a single search engine configuration
type SearchEngine struct {
	Name          string `json:"name"`
	URL           string `json:"url"`
	SpaceDelimiter string `json:"space_delimiter"`
}

// Config holds the application configuration
type Config struct {
	Engines []SearchEngine `json:"-"`
}

// LoadConfig loads search engines from the JSON file
// It looks for search_engines.json in the same directory as the executable
func LoadConfig() (*Config, error) {
	// Get the directory where the executable is located
	execPath, err := os.Executable()
	if err != nil {
		return nil, fmt.Errorf("failed to get executable path: %w", err)
	}

	// Resolve symlinks to get the actual path
	execPath, err = filepath.EvalSymlinks(execPath)
	if err != nil {
		return nil, fmt.Errorf("failed to resolve executable symlinks: %w", err)
	}

	execDir := filepath.Dir(execPath)
	jsonPath := filepath.Join(execDir, "search_engines.json")

	// If running via `go run`, use the current working directory
	if _, err := os.Stat(jsonPath); os.IsNotExist(err) {
		// Try current directory (for development)
		cwd, _ := os.Getwd()
		jsonPath = filepath.Join(cwd, "search_engines.json")
	}

	// Read the JSON file
	data, err := os.ReadFile(jsonPath)
	if err != nil {
		return nil, fmt.Errorf("failed to read search_engines.json: %w", err)
	}

	// Parse JSON
	var engines []SearchEngine
	if err := json.Unmarshal(data, &engines); err != nil {
		return nil, fmt.Errorf("failed to parse JSON: %w", err)
	}

	// Validate and set defaults
	if len(engines) == 0 {
		return nil, fmt.Errorf("no search engines found in JSON file")
	}

	for i := range engines {
		// Default space delimiter to "+" if not specified
		if engines[i].SpaceDelimiter == "" {
			engines[i].SpaceDelimiter = "+"
		}

		// Validate required fields
		if engines[i].Name == "" {
			return nil, fmt.Errorf("search engine at index %d has no name", i)
		}
		if engines[i].URL == "" {
			return nil, fmt.Errorf("search engine at index %d has no URL", i)
		}
	}

	return &Config{Engines: engines}, nil
}

