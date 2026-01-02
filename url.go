package main

import (
	"net/url"
	"strings"
)

// URLEncode encodes a search term for use in URLs with a configurable space delimiter
// The spaceDelimiter can be "+" or "%20" (or any other string)
func URLEncode(searchTerm string, spaceDelimiter string) string {
	if spaceDelimiter == "" {
		spaceDelimiter = "+"
	}

	// Use Go's standard URL encoding (url.QueryEscape uses + for spaces)
	encoded := url.QueryEscape(searchTerm)

	// Replace + (which url.QueryEscape uses for spaces) with the desired delimiter
	if spaceDelimiter != "+" {
		encoded = strings.ReplaceAll(encoded, "+", spaceDelimiter)
	}

	return encoded
}

// BuildSearchURL constructs a complete search URL for a given engine and search term
func BuildSearchURL(engine SearchEngine, searchTerm string) string {
	encoded := URLEncode(searchTerm, engine.SpaceDelimiter)
	return engine.URL + encoded
}

