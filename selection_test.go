package main

import "testing"

func TestResolveSelection(t *testing.T) {
	engines := []SearchEngine{
		{Name: "Bing"},
		{Name: "Google"},
		{Name: "DuckDuckGo"},
		{Name: "YouTube"},
	}

	tests := []struct {
		name     string
		selection string
		want     int // -2 = all, -1 = not found, >= 0 = index
	}{
		{
			name:     "all lowercase",
			selection: "all",
			want:     -2,
		},
		{
			name:     "all uppercase",
			selection: "ALL",
			want:     -2,
		},
		{
			name:     "all mixed case",
			selection: "All",
			want:     -2,
		},
		{
			name:     "zero",
			selection: "0",
			want:     -2,
		},
		{
			name:     "number 1",
			selection: "1",
			want:     0, // Bing
		},
		{
			name:     "number 2",
			selection: "2",
			want:     1, // Google
		},
		{
			name:     "number 4",
			selection: "4",
			want:     3, // YouTube
		},
		{
			name:     "invalid number too high",
			selection: "10",
			want:     -1,
		},
		{
			name:     "invalid number negative",
			selection: "-1",
			want:     -1,
		},
		{
			name:     "engine name exact match",
			selection: "Bing",
			want:     0,
		},
		{
			name:     "engine name lowercase",
			selection: "bing",
			want:     0,
		},
		{
			name:     "engine name uppercase",
			selection: "GOOGLE",
			want:     1,
		},
		{
			name:     "engine name mixed case",
			selection: "DuCkDuCkGo",
			want:     2,
		},
		{
			name:     "engine name with spaces",
			selection: "  Bing  ",
			want:     0,
		},
		{
			name:     "invalid engine name",
			selection: "InvalidEngine",
			want:     -1,
		},
		{
			name:     "empty string",
			selection: "",
			want:     -1,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := ResolveSelection(tt.selection, engines)
			if got != tt.want {
				t.Errorf("ResolveSelection(%q, engines) = %d, want %d", tt.selection, got, tt.want)
			}
		})
	}
}

func TestParseSelections(t *testing.T) {
	engines := []SearchEngine{
		{Name: "Bing"},
		{Name: "Google"},
		{Name: "DuckDuckGo"},
		{Name: "YouTube"},
	}

	tests := []struct {
		name      string
		selections []string
		want      []int
		wantErr   bool
	}{
		{
			name:      "single number",
			selections: []string{"1"},
			want:      []int{0},
			wantErr:   false,
		},
		{
			name:      "multiple numbers",
			selections: []string{"1", "2", "3"},
			want:      []int{0, 1, 2},
			wantErr:   false,
		},
		{
			name:      "all keyword",
			selections: []string{"all"},
			want:      []int{0, 1, 2, 3},
			wantErr:   false,
		},
		{
			name:      "zero for all",
			selections: []string{"0"},
			want:      []int{0, 1, 2, 3},
			wantErr:   false,
		},
		{
			name:      "all stops at first",
			selections: []string{"1", "all", "2"},
			want:      []int{0, 1, 2, 3},
			wantErr:   false,
		},
		{
			name:      "engine names",
			selections: []string{"Bing", "Google"},
			want:      []int{0, 1},
			wantErr:   false,
		},
		{
			name:      "mixed numbers and names",
			selections: []string{"1", "Google", "3"},
			want:      []int{0, 1, 2},
			wantErr:   false,
		},
		{
			name:      "case insensitive names",
			selections: []string{"bing", "GOOGLE", "DuckDuckGo"},
			want:      []int{0, 1, 2},
			wantErr:   false,
		},
		{
			name:      "duplicate removal",
			selections: []string{"1", "1", "1"},
			want:      []int{0},
			wantErr:   false,
		},
		{
			name:      "duplicate removal mixed",
			selections: []string{"1", "Bing", "1"},
			want:      []int{0},
			wantErr:   false,
		},
		{
			name:      "invalid selection skipped",
			selections: []string{"1", "Invalid", "2"},
			want:      []int{0, 1},
			wantErr:   false,
		},
		{
			name:      "all invalid selections",
			selections: []string{"Invalid1", "Invalid2"},
			want:      nil,
			wantErr:   true,
		},
		{
			name:      "empty selections",
			selections: []string{},
			want:      nil,
			wantErr:   true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := ParseSelections(tt.selections, engines)
			if (err != nil) != tt.wantErr {
				t.Errorf("ParseSelections(%v, engines) error = %v, wantErr %v", tt.selections, err, tt.wantErr)
				return
			}
			if !equalIntSlices(got, tt.want) {
				t.Errorf("ParseSelections(%v, engines) = %v, want %v", tt.selections, got, tt.want)
			}
		})
	}
}

// equalIntSlices compares two int slices for equality
func equalIntSlices(a, b []int) bool {
	if len(a) != len(b) {
		return false
	}
	for i := range a {
		if a[i] != b[i] {
			return false
		}
	}
	return true
}

