#!/bin/bash
# GhosttySetup installer - sets up theme-aware Ghostty configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/ghostty"
LAUNCHAGENTS_DIR="$HOME/Library/LaunchAgents"

echo "Installing GhosttySetup..."

# Create config directory
mkdir -p "$CONFIG_DIR"

# Copy config file
echo "Installing Ghostty config..."
cp "$SCRIPT_DIR/config/config" "$CONFIG_DIR/config"
echo "  ✓ Config installed to $CONFIG_DIR/config"

# Install LaunchAgent
echo "Installing theme watcher LaunchAgent..."
mkdir -p "$LAUNCHAGENTS_DIR"

# Replace $HOME placeholder with actual home directory
sed "s|\$HOME|$HOME|g" "$SCRIPT_DIR/config/com.ghostty.theme-watcher.plist" > "$LAUNCHAGENTS_DIR/com.ghostty.theme-watcher.plist"
echo "  ✓ LaunchAgent installed to $LAUNCHAGENTS_DIR/com.ghostty.theme-watcher.plist"

# Unload existing LaunchAgent if running
if launchctl list | grep -q com.ghostty.theme-watcher; then
    echo "Stopping existing theme watcher..."
    launchctl unload "$LAUNCHAGENTS_DIR/com.ghostty.theme-watcher.plist" 2>/dev/null || true
fi

# Load LaunchAgent
echo "Starting theme watcher..."
launchctl load -w "$LAUNCHAGENTS_DIR/com.ghostty.theme-watcher.plist"
echo "  ✓ Theme watcher started"

# Create cache directory
mkdir -p "$HOME/.cache/ghostty-theme-watcher"

echo ""
echo "Installation complete!"
echo ""
echo "The theme watcher is now running and will:"
echo "  • Detect system appearance changes (dark/light mode)"
echo "  • Update split-divider-color and unfocused-split-fill automatically"
echo "  • Reload Ghostty configuration via Cmd+Shift+,"
echo ""
echo "Logs are available at:"
echo "  /tmp/ghostty-theme-watcher.log"
echo "  /tmp/ghostty-theme-watcher.error.log"
echo ""
echo "To manually control the theme watcher:"
echo "  launchctl unload ~/Library/LaunchAgents/com.ghostty.theme-watcher.plist  # Stop"
echo "  launchctl load ~/Library/LaunchAgents/com.ghostty.theme-watcher.plist    # Start"
