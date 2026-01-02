package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

// SearchEngine represents a single search engine configuration
type SearchEngine struct {
	Name           string `json:"name"`
	URL            string `json:"url"`
	SpaceDelimiter string `json:"space_delimiter"`
}

// Config holds the application configuration
type Config struct {
	Categories map[string][]SearchEngine `json:"-"`
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

	// Parse JSON - new structure with category keys
	var categoriesData map[string][]SearchEngine
	if err := json.Unmarshal(data, &categoriesData); err != nil {
		return nil, fmt.Errorf("failed to parse JSON: %w", err)
	}

	// Validate and set defaults
	if len(categoriesData) == 0 {
		return nil, fmt.Errorf("no categories found in JSON file")
	}

	categories := make(map[string][]SearchEngine)
	for category, engines := range categoriesData {
		if len(engines) == 0 {
			continue // Skip empty categories
		}

		validatedEngines := make([]SearchEngine, 0, len(engines))
		for i := range engines {
			// Default space delimiter to "+" if not specified
			if engines[i].SpaceDelimiter == "" {
				engines[i].SpaceDelimiter = "+"
			}

			// Validate required fields
			if engines[i].Name == "" {
				return nil, fmt.Errorf("engine in category %q at index %d has no name", category, i)
			}
			if engines[i].URL == "" {
				return nil, fmt.Errorf("engine in category %q at index %d has no URL", category, i)
			}

			validatedEngines = append(validatedEngines, engines[i])
		}

		if len(validatedEngines) > 0 {
			categories[category] = validatedEngines
		}
	}

	if len(categories) == 0 {
		return nil, fmt.Errorf("no valid engines found in any category")
	}

	return &Config{Categories: categories}, nil
}

// GetEnginesByCategory returns engines for a specific category
// Returns empty slice if category doesn't exist
func (c *Config) GetEnginesByCategory(category string) []SearchEngine {
	if engines, ok := c.Categories[category]; ok {
		return engines
	}
	return []SearchEngine{}
}
