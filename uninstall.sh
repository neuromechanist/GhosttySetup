#!/bin/bash
# GhosttySetup uninstaller - removes theme-aware configuration

set -e

CONFIG_DIR="$HOME/.config/ghostty"
LAUNCHAGENTS_DIR="$HOME/Library/LaunchAgents"
CACHE_DIR="$HOME/.cache/ghostty-theme-watcher"
BIN_DIR="$HOME/.local/bin"

echo "Uninstalling GhosttySetup..."

# Stop and remove LaunchAgent
if [ -f "$LAUNCHAGENTS_DIR/com.ghostty.theme-watcher.plist" ]; then
    echo "Stopping theme watcher..."
    launchctl unload "$LAUNCHAGENTS_DIR/com.ghostty.theme-watcher.plist" 2>/dev/null || true
    rm "$LAUNCHAGENTS_DIR/com.ghostty.theme-watcher.plist"
    echo "  LaunchAgent removed"
fi

# Remove theme watcher script
if [ -f "$BIN_DIR/ghostty-theme-watcher" ]; then
    echo "Removing theme watcher script..."
    rm "$BIN_DIR/ghostty-theme-watcher"
    echo "  Theme watcher script removed"
fi

# Remove config file
if [ -f "$CONFIG_DIR/config" ]; then
    echo "Removing Ghostty config..."
    rm "$CONFIG_DIR/config"
    echo "  Config removed"
fi

# Remove shell appearance helper
if [ -f "$CONFIG_DIR/appearance.zsh" ]; then
    echo "Removing shell appearance helper..."
    rm "$CONFIG_DIR/appearance.zsh"
    echo "  Shell appearance helper removed"
fi

# Remove cache directory
if [ -d "$CACHE_DIR" ]; then
    echo "Removing cache directory..."
    rm -rf "$CACHE_DIR"
    echo "  Cache removed"
fi

# Remove log files
if [ -f "/tmp/ghostty-theme-watcher.log" ]; then
    rm "/tmp/ghostty-theme-watcher.log"
fi
if [ -f "/tmp/ghostty-theme-watcher.error.log" ]; then
    rm "/tmp/ghostty-theme-watcher.error.log"
fi

echo ""
echo "Uninstallation complete!"
echo ""
echo "Note: ~/.config/ghostty directory is preserved (may contain other files)"
