#!/bin/bash
# GhosttySetup installer - sets up theme-aware Ghostty configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/ghostty"
LAUNCHAGENTS_DIR="$HOME/Library/LaunchAgents"
BIN_DIR="$HOME/.local/bin"

echo "Installing GhosttySetup..."

# Create directories
mkdir -p "$CONFIG_DIR"
mkdir -p "$BIN_DIR"

# Copy config file
echo "Installing Ghostty config..."
cp "$SCRIPT_DIR/config/config" "$CONFIG_DIR/config"
echo "  ✓ Config installed to $CONFIG_DIR/config"

# Copy theme watcher script
echo "Installing theme watcher script..."
cp "$SCRIPT_DIR/bin/ghostty-theme-watcher" "$BIN_DIR/ghostty-theme-watcher"
chmod +x "$BIN_DIR/ghostty-theme-watcher"
# Clear extended attributes to avoid permission issues
xattr -c "$BIN_DIR/ghostty-theme-watcher" 2>/dev/null || true
echo "  ✓ Theme watcher installed to $BIN_DIR/ghostty-theme-watcher"

# Create reload helper app
echo "Creating Ghostty Reload Helper app..."
bash "$SCRIPT_DIR/bin/create-reload-app.sh" >/dev/null 2>&1 || true
echo "  ✓ Reload helper app created at ~/Applications/Ghostty Reload Helper.app"

# Install LaunchAgent
echo "Installing theme watcher LaunchAgent..."
mkdir -p "$LAUNCHAGENTS_DIR"

# Create plist with correct path to script
cat > "$LAUNCHAGENTS_DIR/com.ghostty.theme-watcher.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ghostty.theme-watcher</string>
    <key>ProgramArguments</key>
    <array>
        <string>$BIN_DIR/ghostty-theme-watcher</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
    <key>StandardOutPath</key>
    <string>/tmp/ghostty-theme-watcher.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/ghostty-theme-watcher.error.log</string>
</dict>
</plist>
EOF
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
echo "IMPORTANT: Grant Accessibility permissions for automatic config reload:"
echo "  1. Open System Settings > Privacy & Security > Accessibility"
echo "  2. Click the lock icon to make changes"
echo "  3. Click the + button"
echo "  4. Press Cmd+Shift+G and paste: $HOME/Applications/Ghostty Reload Helper.app"
echo "  5. Select the app and click 'Open'"
echo ""
echo "Without Accessibility permissions, you'll need to manually reload Ghostty"
echo "with Cmd+Shift+, after switching between light/dark mode."
echo ""
echo "The theme watcher is now running and will:"
echo "  • Detect system appearance changes (dark/light mode)"
echo "  • Update split-divider-color and unfocused-split-fill automatically"
echo "  • Reload Ghostty configuration via Cmd+Shift+, (requires Accessibility permission)"
echo ""
echo "Logs are available at:"
echo "  /tmp/ghostty-theme-watcher.log"
echo "  /tmp/ghostty-theme-watcher.error.log"
echo ""
echo "To manually control the theme watcher:"
echo "  launchctl unload ~/Library/LaunchAgents/com.ghostty.theme-watcher.plist  # Stop"
echo "  launchctl load ~/Library/LaunchAgents/com.ghostty.theme-watcher.plist    # Start"
