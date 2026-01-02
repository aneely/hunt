package main

import "testing"

func TestURLEncode(t *testing.T) {
	tests := []struct {
		name           string
		searchTerm     string
		spaceDelimiter string
		want           string
	}{
		{
			name:           "simple text with spaces, plus delimiter",
			searchTerm:     "hello world",
			spaceDelimiter: "+",
			want:           "hello+world",
		},
		{
			name:           "simple text with spaces, percent20 delimiter",
			searchTerm:     "hello world",
			spaceDelimiter: "%20",
			want:           "hello%20world",
		},
		{
			name:           "default delimiter (empty string)",
			searchTerm:     "hello world",
			spaceDelimiter: "",
			want:           "hello+world",
		},
		{
			name:           "special characters",
			searchTerm:     "C++ programming",
			spaceDelimiter: "+",
			want:           "C%2B%2B+programming",
		},
		{
			name:           "ampersand",
			searchTerm:     "test & query",
			spaceDelimiter: "+",
			want:           "test+%26+query",
		},
		{
			name:           "unicode characters",
			searchTerm:     "café résumé",
			spaceDelimiter: "+",
			want:           "caf%C3%A9+r%C3%A9sum%C3%A9",
		},
		{
			name:           "multiple spaces",
			searchTerm:     "hello   world",
			spaceDelimiter: "+",
			want:           "hello+++world",
		},
		{
			name:           "no spaces",
			searchTerm:     "helloworld",
			spaceDelimiter: "+",
			want:           "helloworld",
		},
		{
			name:           "query parameters",
			searchTerm:     "python 3.10",
			spaceDelimiter: "+",
			want:           "python+3.10",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := URLEncode(tt.searchTerm, tt.spaceDelimiter)
			if got != tt.want {
				t.Errorf("URLEncode(%q, %q) = %q, want %q", tt.searchTerm, tt.spaceDelimiter, got, tt.want)
			}
		})
	}
}

func TestBuildSearchURL(t *testing.T) {
	tests := []struct {
		name       string
		engine     SearchEngine
		searchTerm string
		want       string
	}{
		{
			name: "Google with plus delimiter",
			engine: SearchEngine{
				Name:           "Google",
				URL:            "https://www.google.com/search?q=",
				SpaceDelimiter: "+",
			},
			searchTerm: "test query",
			want:       "https://www.google.com/search?q=test+query",
		},
		{
			name: "Yahoo with plus delimiter",
			engine: SearchEngine{
				Name:           "Yahoo",
				URL:            "https://search.yahoo.com/search?p=",
				SpaceDelimiter: "+",
			},
			searchTerm: "machine learning",
			want:       "https://search.yahoo.com/search?p=machine+learning",
		},
		{
			name: "YouTube with special characters",
			engine: SearchEngine{
				Name:           "YouTube",
				URL:            "https://www.youtube.com/results?search_query=",
				SpaceDelimiter: "+",
			},
			searchTerm: "C++ tutorial",
			want:       "https://www.youtube.com/results?search_query=C%2B%2B+tutorial",
		},
		{
			name: "custom delimiter",
			engine: SearchEngine{
				Name:           "Test",
				URL:            "https://test.com/search?q=",
				SpaceDelimiter: "%20",
			},
			searchTerm: "hello world",
			want:       "https://test.com/search?q=hello%20world",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := BuildSearchURL(tt.engine, tt.searchTerm)
			if got != tt.want {
				t.Errorf("BuildSearchURL(%+v, %q) = %q, want %q", tt.engine, tt.searchTerm, got, tt.want)
			}
		})
	}
}

