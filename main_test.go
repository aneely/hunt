package main

import (
	"bytes"
	"strings"
	"testing"
)

func TestMapSubcommandToCategory(t *testing.T) {
	tests := []struct {
		name       string
		subcommand string
		want       string
	}{
		{
			name:       "shop subcommand",
			subcommand: "shop",
			want:       "shop",
		},
		{
			name:       "shopping subcommand",
			subcommand: "shopping",
			want:       "shop",
		},
		{
			name:       "search subcommand",
			subcommand: "search",
			want:       "search",
		},
		{
			name:       "technews subcommand",
			subcommand: "technews",
			want:       "technews",
		},
		{
			name:       "tech-news subcommand",
			subcommand: "tech-news",
			want:       "technews",
		},
		{
			name:       "tech subcommand",
			subcommand: "tech",
			want:       "technews",
		},
		{
			name:       "news subcommand",
			subcommand: "news",
			want:       "news",
		},
		{
			name:       "unknown subcommand",
			subcommand: "unknown",
			want:       "",
		},
		{
			name:       "empty subcommand",
			subcommand: "",
			want:       "",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := mapSubcommandToCategory(tt.subcommand)
			if got != tt.want {
				t.Errorf("mapSubcommandToCategory(%q) = %q, want %q", tt.subcommand, got, tt.want)
			}
		})
	}
}

func TestFormatCategoryName(t *testing.T) {
	tests := []struct {
		name     string
		category string
		want     string
	}{
		{
			name:     "search category",
			category: "search",
			want:     "Search Engines",
		},
		{
			name:     "shop category",
			category: "shop",
			want:     "Shopping Sites",
		},
		{
			name:     "technews category",
			category: "technews",
			want:     "Tech News",
		},
		{
			name:     "news category",
			category: "news",
			want:     "News",
		},
		{
			name:     "unknown category",
			category: "unknown",
			want:     "Unknown Services",
		},
		{
			name:     "empty category",
			category: "",
			want:     "",
		},
		{
			name:     "single letter category",
			category: "x",
			want:     "X Services",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := formatCategoryName(tt.category)
			if got != tt.want {
				t.Errorf("formatCategoryName(%q) = %q, want %q", tt.category, got, tt.want)
			}
		})
	}
}

func TestPrintUsage(t *testing.T) {
	tests := []struct {
		name             string
		wantContains     []string
		wantNotContains  []string
	}{
		{
			name: "contains usage information",
			wantContains: []string{
				"Usage:",
				"Subcommands:",
				"shop",
				"technews",
				"news",
				"Examples:",
				"Options:",
				"-h, --help",
				"-i, --interactive",
				"-s, --services",
			},
			wantNotContains: []string{},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Capture output using a buffer
			var buf bytes.Buffer
			printUsage(&buf)
			output := buf.String()

			// Check that all expected strings are present
			for _, want := range tt.wantContains {
				if !strings.Contains(output, want) {
					t.Errorf("printUsage() output missing %q", want)
				}
			}

			// Check that unwanted strings are not present
			for _, unwanted := range tt.wantNotContains {
				if strings.Contains(output, unwanted) {
					t.Errorf("printUsage() output contains unwanted string %q", unwanted)
				}
			}

			// Verify output is not empty
			if len(output) == 0 {
				t.Error("printUsage() produced empty output")
			}
		})
	}
}
