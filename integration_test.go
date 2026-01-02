package main

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

// TestIntegration_URLConstructionAndEncoding tests the integration of
// config loading, URL encoding, and URL construction
func TestIntegration_URLConstructionAndEncoding(t *testing.T) {
	// Create a temporary JSON file
	tmpDir := t.TempDir()
	jsonPath := filepath.Join(tmpDir, "search_engines.json")

	testJSON := `{
		"search": [
			{"name": "Bing", "url": "https://www.bing.com/search?q=", "space_delimiter": "+"},
			{"name": "Yahoo", "url": "https://search.yahoo.com/search?p=", "space_delimiter": "+"},
			{"name": "Custom", "url": "https://custom.com/search?q=", "space_delimiter": "%20"}
		]
	}`

	if err := os.WriteFile(jsonPath, []byte(testJSON), 0644); err != nil {
		t.Fatalf("Failed to create test JSON file: %v", err)
	}

	oldDir, err := os.Getwd()
	if err != nil {
		t.Fatalf("Failed to get current directory: %v", err)
	}
	defer os.Chdir(oldDir)

	if err := os.Chdir(tmpDir); err != nil {
		t.Fatalf("Failed to change to temp directory: %v", err)
	}

	// Load config
	config, err := LoadConfig()
	if err != nil {
		t.Fatalf("LoadConfig() error = %v", err)
	}

	// Test URL construction for each engine
	searchTerm := "test query"
	expectedURLs := []string{
		"https://www.bing.com/search?q=test+query",
		"https://search.yahoo.com/search?p=test+query",
		"https://custom.com/search?q=test%20query",
	}

	engines := config.GetEnginesByCategory("search")
	for i, engine := range engines {
		url := BuildSearchURL(engine, searchTerm)
		if url != expectedURLs[i] {
			t.Errorf("BuildSearchURL(engine[%d], %q) = %q, want %q", i, searchTerm, url, expectedURLs[i])
		}
	}
}

// TestIntegration_ServiceSelectionAndURLBuilding tests the integration of
// service selection parsing and URL building for multiple engines
func TestIntegration_ServiceSelectionAndURLBuilding(t *testing.T) {
	engines := []SearchEngine{
		{Name: "Bing", URL: "https://www.bing.com/search?q=", SpaceDelimiter: "+"},
		{Name: "Google", URL: "https://www.google.com/search?q=", SpaceDelimiter: "+"},
		{Name: "DuckDuckGo", URL: "https://duckduckgo.com/?q=", SpaceDelimiter: "+"},
	}

	tests := []struct {
		name        string
		selections  []string
		searchTerm  string
		wantURLs    []string
		wantEngines []string
	}{
		{
			name:        "select by numbers",
			selections:  []string{"1", "2"},
			searchTerm:  "test",
			wantURLs:    []string{"https://www.bing.com/search?q=test", "https://www.google.com/search?q=test"},
			wantEngines: []string{"Bing", "Google"},
		},
		{
			name:        "select by names",
			selections:  []string{"Bing", "DuckDuckGo"},
			searchTerm:  "hello world",
			wantURLs:    []string{"https://www.bing.com/search?q=hello+world", "https://duckduckgo.com/?q=hello+world"},
			wantEngines: []string{"Bing", "DuckDuckGo"},
		},
		{
			name:        "select all",
			selections:  []string{"all"},
			searchTerm:  "test",
			wantURLs:    []string{"https://www.bing.com/search?q=test", "https://www.google.com/search?q=test", "https://duckduckgo.com/?q=test"},
			wantEngines: []string{"Bing", "Google", "DuckDuckGo"},
		},
		{
			name:        "mixed selection",
			selections:  []string{"1", "Google", "3"},
			searchTerm:  "mixed test",
			wantURLs:    []string{"https://www.bing.com/search?q=mixed+test", "https://www.google.com/search?q=mixed+test", "https://duckduckgo.com/?q=mixed+test"},
			wantEngines: []string{"Bing", "Google", "DuckDuckGo"},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Parse selections
			indices, err := ParseSelections(tt.selections, engines)
			if err != nil {
				t.Fatalf("ParseSelections() error = %v", err)
			}

			if len(indices) != len(tt.wantURLs) {
				t.Fatalf("ParseSelections() returned %d indices, want %d", len(indices), len(tt.wantURLs))
			}

			// Build URLs
			urls := make([]string, len(indices))
			engineNames := make([]string, len(indices))
			for i, idx := range indices {
				urls[i] = BuildSearchURL(engines[idx], tt.searchTerm)
				engineNames[i] = engines[idx].Name
			}

			// Verify URLs
			for i, wantURL := range tt.wantURLs {
				if urls[i] != wantURL {
					t.Errorf("URL[%d] = %q, want %q", i, urls[i], wantURL)
				}
			}

			// Verify engine names
			for i, wantEngine := range tt.wantEngines {
				if engineNames[i] != wantEngine {
					t.Errorf("Engine[%d] = %q, want %q", i, engineNames[i], wantEngine)
				}
			}
		})
	}
}

// TestIntegration_DuplicateRemovalAndURLBuilding tests that duplicate
// selections are properly removed and URLs are built correctly
func TestIntegration_DuplicateRemovalAndURLBuilding(t *testing.T) {
	engines := []SearchEngine{
		{Name: "Bing", URL: "https://www.bing.com/search?q=", SpaceDelimiter: "+"},
		{Name: "Google", URL: "https://www.google.com/search?q=", SpaceDelimiter: "+"},
	}

	// Select same engine multiple times (by number and name)
	selections := []string{"1", "Bing", "1"}
	indices, err := ParseSelections(selections, engines)
	if err != nil {
		t.Fatalf("ParseSelections() error = %v", err)
	}

	// Should only have one index (Bing = 0)
	if len(indices) != 1 {
		t.Errorf("ParseSelections() with duplicates returned %d indices, want 1", len(indices))
	}

	if indices[0] != 0 {
		t.Errorf("ParseSelections() returned index %d, want 0 (Bing)", indices[0])
	}

	// Build URL - should only build one
	url := BuildSearchURL(engines[indices[0]], "test")
	expectedURL := "https://www.bing.com/search?q=test"
	if url != expectedURL {
		t.Errorf("BuildSearchURL() = %q, want %q", url, expectedURL)
	}
}

// TestIntegration_SpecialCharactersInSearchTerm tests that special characters
// are properly encoded through the full pipeline
func TestIntegration_SpecialCharactersInSearchTerm(t *testing.T) {
	engines := []SearchEngine{
		{Name: "Test", URL: "https://test.com/search?q=", SpaceDelimiter: "+"},
	}

	testCases := []struct {
		name       string
		searchTerm string
		wantSuffix string // What the encoded search term should end with
	}{
		{
			name:       "C++",
			searchTerm: "C++ programming",
			wantSuffix: "C%2B%2B+programming",
		},
		{
			name:       "ampersand",
			searchTerm: "test & query",
			wantSuffix: "test+%26+query",
		},
		{
			name:       "unicode",
			searchTerm: "café",
			wantSuffix: "caf%C3%A9",
		},
		{
			name:       "query parameters",
			searchTerm: "python 3.10",
			wantSuffix: "python+3.10",
		},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			url := BuildSearchURL(engines[0], tc.searchTerm)
			if !strings.HasSuffix(url, tc.wantSuffix) {
				t.Errorf("BuildSearchURL() = %q, want suffix %q", url, tc.wantSuffix)
			}
		})
	}
}

// TestIntegration_AllSelectionWithMultipleEngines tests that selecting "all"
// works correctly with multiple engines and builds all URLs
func TestIntegration_AllSelectionWithMultipleEngines(t *testing.T) {
	engines := []SearchEngine{
		{Name: "Bing", URL: "https://www.bing.com/search?q=", SpaceDelimiter: "+"},
		{Name: "Google", URL: "https://www.google.com/search?q=", SpaceDelimiter: "+"},
		{Name: "DuckDuckGo", URL: "https://duckduckgo.com/?q=", SpaceDelimiter: "+"},
		{Name: "YouTube", URL: "https://www.youtube.com/results?search_query=", SpaceDelimiter: "+"},
	}

	selections := []string{"all"}
	indices, err := ParseSelections(selections, engines)
	if err != nil {
		t.Fatalf("ParseSelections() error = %v", err)
	}

	if len(indices) != len(engines) {
		t.Errorf("ParseSelections() with 'all' returned %d indices, want %d", len(indices), len(engines))
	}

	// Verify all engines are included
	searchTerm := "test"
	urls := make([]string, len(indices))
	for i, idx := range indices {
		urls[i] = BuildSearchURL(engines[idx], searchTerm)
		// Verify URL contains the engine's base URL
		if !strings.HasPrefix(urls[i], engines[idx].URL) {
			t.Errorf("URL[%d] = %q, should start with %q", i, urls[i], engines[idx].URL)
		}
	}

	// Verify we have URLs for all engines
	if len(urls) != len(engines) {
		t.Errorf("Built %d URLs, want %d", len(urls), len(engines))
	}
}
