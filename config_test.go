package main

import (
	"os"
	"path/filepath"
	"testing"
)

func TestLoadConfig(t *testing.T) {
	// Create a temporary JSON file for testing
	tmpDir := t.TempDir()
	jsonPath := filepath.Join(tmpDir, "search_engines.json")

	validJSON := `{
		"search": [
			{"name": "Bing", "url": "https://www.bing.com/search?q=", "space_delimiter": "+"},
			{"name": "Google", "url": "https://www.google.com/search?q=", "space_delimiter": "+"},
			{"name": "Yahoo", "url": "https://search.yahoo.com/search?p=", "space_delimiter": "+"}
		]
	}`

	if err := os.WriteFile(jsonPath, []byte(validJSON), 0644); err != nil {
		t.Fatalf("Failed to create test JSON file: %v", err)
	}

	// Temporarily change to the temp directory
	oldDir, err := os.Getwd()
	if err != nil {
		t.Fatalf("Failed to get current directory: %v", err)
	}
	defer os.Chdir(oldDir)

	if err := os.Chdir(tmpDir); err != nil {
		t.Fatalf("Failed to change to temp directory: %v", err)
	}

	// Test loading config
	config, err := LoadConfig()
	if err != nil {
		t.Fatalf("LoadConfig() error = %v, want nil", err)
	}

	engines := config.GetEnginesByCategory("search")
	if len(engines) != 3 {
		t.Errorf("LoadConfig() loaded %d engines, want 3", len(engines))
	}

	// Verify first engine
	if engines[0].Name != "Bing" {
		t.Errorf("LoadConfig() first engine name = %q, want %q", engines[0].Name, "Bing")
	}
	if engines[0].URL != "https://www.bing.com/search?q=" {
		t.Errorf("LoadConfig() first engine URL = %q, want %q", engines[0].URL, "https://www.bing.com/search?q=")
	}
	if engines[0].SpaceDelimiter != "+" {
		t.Errorf("LoadConfig() first engine delimiter = %q, want %q", engines[0].SpaceDelimiter, "+")
	}
}

func TestLoadConfig_DefaultDelimiter(t *testing.T) {
	tmpDir := t.TempDir()
	jsonPath := filepath.Join(tmpDir, "search_engines.json")

	// JSON without space_delimiter (should default to "+")
	jsonWithoutDelimiter := `{
		"search": [
			{"name": "Test", "url": "https://test.com/search?q="}
		]
	}`

	if err := os.WriteFile(jsonPath, []byte(jsonWithoutDelimiter), 0644); err != nil {
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

	config, err := LoadConfig()
	if err != nil {
		t.Fatalf("LoadConfig() error = %v, want nil", err)
	}

	engines := config.GetEnginesByCategory("search")
	if engines[0].SpaceDelimiter != "+" {
		t.Errorf("LoadConfig() default delimiter = %q, want %q", engines[0].SpaceDelimiter, "+")
	}
}

func TestLoadConfig_EmptyDelimiter(t *testing.T) {
	tmpDir := t.TempDir()
	jsonPath := filepath.Join(tmpDir, "search_engines.json")

	// JSON with empty space_delimiter (should default to "+")
	jsonWithEmptyDelimiter := `{
		"search": [
			{"name": "Test", "url": "https://test.com/search?q=", "space_delimiter": ""}
		]
	}`

	if err := os.WriteFile(jsonPath, []byte(jsonWithEmptyDelimiter), 0644); err != nil {
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

	config, err := LoadConfig()
	if err != nil {
		t.Fatalf("LoadConfig() error = %v, want nil", err)
	}

	engines := config.GetEnginesByCategory("search")
	if engines[0].SpaceDelimiter != "+" {
		t.Errorf("LoadConfig() empty delimiter default = %q, want %q", engines[0].SpaceDelimiter, "+")
	}
}

func TestLoadConfig_InvalidJSON(t *testing.T) {
	tmpDir := t.TempDir()
	jsonPath := filepath.Join(tmpDir, "search_engines.json")

	invalidJSON := `{invalid json}`

	if err := os.WriteFile(jsonPath, []byte(invalidJSON), 0644); err != nil {
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

	_, err = LoadConfig()
	if err == nil {
		t.Error("LoadConfig() error = nil, want error for invalid JSON")
	}
}

func TestLoadConfig_EmptyArray(t *testing.T) {
	tmpDir := t.TempDir()
	jsonPath := filepath.Join(tmpDir, "search_engines.json")

	emptyJSON := `{}`

	if err := os.WriteFile(jsonPath, []byte(emptyJSON), 0644); err != nil {
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

	_, err = LoadConfig()
	if err == nil {
		t.Error("LoadConfig() error = nil, want error for empty array")
	}
}

func TestLoadConfig_MissingFields(t *testing.T) {
	tmpDir := t.TempDir()
	jsonPath := filepath.Join(tmpDir, "search_engines.json")

	tests := []struct {
		name string
		json string
	}{
		{
			name: "missing name",
			json: `{"search": [{"url": "https://test.com/search?q="}]}`,
		},
		{
			name: "missing url",
			json: `{"search": [{"name": "Test"}]}`,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if err := os.WriteFile(jsonPath, []byte(tt.json), 0644); err != nil {
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

			_, err = LoadConfig()
			if err == nil {
				t.Error("LoadConfig() error = nil, want error for missing required fields")
			}
		})
	}
}

func TestLoadConfig_ValidatesJSONStructure(t *testing.T) {
	tmpDir := t.TempDir()
	jsonPath := filepath.Join(tmpDir, "search_engines.json")

	// Valid JSON structure
	validJSON := `{
		"search": [
			{"name": "Bing", "url": "https://www.bing.com/search?q=", "space_delimiter": "+"},
			{"name": "Google", "url": "https://www.google.com/search?q=", "space_delimiter": "%20"}
		]
	}`

	if err := os.WriteFile(jsonPath, []byte(validJSON), 0644); err != nil {
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

	config, err := LoadConfig()
	if err != nil {
		t.Fatalf("LoadConfig() error = %v, want nil", err)
	}

	// Verify both engines loaded correctly
	engines := config.GetEnginesByCategory("search")
	if len(engines) != 2 {
		t.Errorf("LoadConfig() loaded %d engines, want 2", len(engines))
	}

	// Verify second engine has custom delimiter
	if engines[1].SpaceDelimiter != "%20" {
		t.Errorf("LoadConfig() second engine delimiter = %q, want %q", engines[1].SpaceDelimiter, "%20")
	}
}
