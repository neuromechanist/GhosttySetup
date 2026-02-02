#!/bin/bash
# Creates a standalone app for reloading Ghostty that can be added to Accessibility

set -e

APP_DIR="$HOME/Applications/Ghostty Reload Helper.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "Creating Ghostty Reload Helper app..."

# Create app bundle structure
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Create the executable script
cat > "$MACOS_DIR/ghostty-reload-helper" <<'EOF'
#!/bin/bash
osascript -e 'tell application "System Events"
    tell process "ghostty"
        keystroke "," using {command down, shift down}
    end tell
end tell' 2>/dev/null || true
EOF

chmod +x "$MACOS_DIR/ghostty-reload-helper"

# Create Info.plist
cat > "$CONTENTS_DIR/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>ghostty-reload-helper</string>
    <key>CFBundleIdentifier</key>
    <string>com.ghostty.reload-helper</string>
    <key>CFBundleName</key>
    <string>Ghostty Reload Helper</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

echo "✓ App created at: $APP_DIR"
echo ""
echo "Now follow these steps:"
echo "1. Open System Settings > Privacy & Security > Accessibility"
echo "2. Click the lock to make changes"
echo "3. Click the + button"
echo "4. Press Cmd+Shift+G and paste: $APP_DIR"
echo "5. Select the app and click 'Open'"
echo ""
echo "After granting permissions, reinstall GhosttySetup:"
echo "  ./install.sh"
