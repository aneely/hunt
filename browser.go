package main

import (
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"time"
)

// OpenURL opens a URL in the default browser (cross-platform)
func OpenURL(url string) error {
	var cmd *exec.Cmd

	switch runtime.GOOS {
	case "darwin":
		// macOS
		cmd = exec.Command("open", url)
	case "linux":
		// Linux
		cmd = exec.Command("xdg-open", url)
	case "windows":
		// Windows
		cmd = exec.Command("cmd", "/c", "start", url)
	default:
		return fmt.Errorf("unsupported operating system: %s", runtime.GOOS)
	}

	// Suppress error output (similar to bash version's 2>/dev/null)
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

// OpenURLs opens multiple URLs sequentially with delays
// If testMode is true, delays are skipped
func OpenURLs(urls []string, engineNames []string, testMode bool) error {
	for i, url := range urls {
		if i < len(engineNames) {
			fmt.Printf("Opening %s...\n", engineNames[i])
		} else {
			fmt.Printf("Opening URL %d...\n", i+1)
		}

		if err := OpenURL(url); err != nil {
			// Continue on error (similar to bash version)
			fmt.Fprintf(os.Stderr, "Warning: Failed to open URL: %v\n", err)
		}

		// Small delay to ensure browser processes each URL as a separate tab
		// Skip delay in test mode
		if !testMode && i < len(urls)-1 {
			time.Sleep(300 * time.Millisecond)
		}
	}

	return nil
}

