#!/usr/bin/env bash
# GhosttySetup installer
#
# Installs the Ghostty config, shell appearance helper, and the theme watcher.
# Supports macOS (LaunchAgent) and Linux/GNOME (systemd user unit). Politely
# declines on Windows-ish environments (no official Ghostty there yet; see
# https://winghostty.com/ for a community port).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"
SHELL_NAME="$(basename "${SHELL:-bash}")"

# --- Platform refusal -------------------------------------------------------

case "$OS" in
    Darwin|Linux) : ;;
    MINGW*|MSYS*|CYGWIN*)
        cat <<'EOM'
GhosttySetup: Windows is not officially supported by Ghostty yet.

If you want Ghostty on Windows, check out the community port:
  https://winghostty.com/

Re-run this installer from macOS or Linux when you have a supported environment.
EOM
        exit 0
        ;;
    *)
        echo "GhosttySetup: unsupported OS '$OS'." >&2
        echo "Officially supported: macOS, Linux (Ubuntu/GNOME tested)." >&2
        exit 1
        ;;
esac

# --- Path resolution --------------------------------------------------------

XDG_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
BIN_DIR="${GHOSTTYSETUP_BIN_DIR:-$HOME/.local/bin}"

if [ "$OS" = "Darwin" ]; then
    # macOS: the .app reads the Application Support file last and it overrides
    # XDG, so that is the file we install AND the watcher edits.
    CONFIG_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
    HELPER_DIR="$XDG_CONFIG/ghostty"
else
    CONFIG_DIR="$XDG_CONFIG/ghostty"
    HELPER_DIR="$CONFIG_DIR"
fi

CONFIG_FILE="$CONFIG_DIR/config.ghostty"

echo "GhosttySetup installer ($OS, shell: $SHELL_NAME)"
echo "  Config target: $CONFIG_FILE"
echo "  Helper dir:    $HELPER_DIR"
echo "  Bin dir:       $BIN_DIR"

mkdir -p "$CONFIG_DIR" "$HELPER_DIR" "$BIN_DIR"

# --- Config file ------------------------------------------------------------

# If a legacy `config` exists but `config.ghostty` does not, migrate it.
LEGACY_CONFIG="$CONFIG_DIR/config"
if [ -f "$LEGACY_CONFIG" ] && [ ! -f "$CONFIG_FILE" ]; then
    echo "Migrating legacy $LEGACY_CONFIG -> $CONFIG_FILE"
    mv "$LEGACY_CONFIG" "$CONFIG_FILE"
fi

if [ -f "$CONFIG_FILE" ]; then
    backup="$CONFIG_FILE.bak.$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing config to $backup"
    cp "$CONFIG_FILE" "$backup"
fi

echo "Installing Ghostty config..."
cp "$SCRIPT_DIR/config/config" "$CONFIG_FILE"
echo "  Installed to $CONFIG_FILE"

# --- Shell appearance helpers ----------------------------------------------

echo "Installing shell appearance helpers..."
cp "$SCRIPT_DIR/shell/appearance.zsh"  "$HELPER_DIR/appearance.zsh"
cp "$SCRIPT_DIR/shell/appearance.bash" "$HELPER_DIR/appearance.bash"
echo "  zsh:  $HELPER_DIR/appearance.zsh"
echo "  bash: $HELPER_DIR/appearance.bash"

case "$SHELL_NAME" in
    zsh)
        echo "  Detected zsh. Add to ~/.zshrc (after fast-syntax-highlighting):"
        echo "    source $HELPER_DIR/appearance.zsh"
        echo "  Or via zinit: zinit light neuromechanist/GhosttySetup"
        ;;
    bash)
        echo "  Detected bash. Add to ~/.bashrc:"
        echo "    source $HELPER_DIR/appearance.bash"
        ;;
    *)
        echo "  Shell '$SHELL_NAME' has no first-class helper here."
        echo "  Source the bash helper manually if your shell is POSIX-ish."
        ;;
esac

# --- Theme watcher binary --------------------------------------------------

echo "Installing theme watcher..."
cp "$SCRIPT_DIR/bin/ghostty-theme-watcher" "$BIN_DIR/ghostty-theme-watcher"
chmod +x "$BIN_DIR/ghostty-theme-watcher"
if [ "$OS" = "Darwin" ]; then
    xattr -c "$BIN_DIR/ghostty-theme-watcher" 2>/dev/null || true
fi
echo "  Theme watcher: $BIN_DIR/ghostty-theme-watcher"

# --- macOS reload helper (optional) ----------------------------------------

if [ "$OS" = "Darwin" ] && [ -f "$SCRIPT_DIR/bin/create-reload-app.sh" ]; then
    echo "Creating Ghostty Reload Helper app..."
    # Let stderr through so users can see why it failed (osacompile missing,
    # permissions issue, etc.). The reload helper is optional, so we keep
    # going on non-zero exit.
    if bash "$SCRIPT_DIR/bin/create-reload-app.sh"; then
        echo "  Reload helper: ~/Applications/Ghostty Reload Helper.app"
    else
        echo "  Skipped reload helper (create-reload-app.sh failed; see stderr above)"
    fi
fi

# --- Background service ----------------------------------------------------

if [ "$OS" = "Darwin" ]; then
    LAUNCHAGENTS_DIR="$HOME/Library/LaunchAgents"
    PLIST="$LAUNCHAGENTS_DIR/com.ghostty.theme-watcher.plist"

    mkdir -p "$LAUNCHAGENTS_DIR"
    cat > "$PLIST" <<EOF
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
    echo "Installed LaunchAgent: $PLIST"

    # Querying by label exits 0 only if the agent is registered, so we avoid
    # a `launchctl list | grep` whose left side could silently fail under
    # pipefail and leave us double-loading the LaunchAgent.
    if launchctl list com.ghostty.theme-watcher >/dev/null 2>&1; then
        echo "Stopping existing watcher..."
        launchctl unload "$PLIST" 2>/dev/null || true
    fi

    echo "Starting theme watcher..."
    launchctl load -w "$PLIST"
    echo "  Watcher running. Logs: /tmp/ghostty-theme-watcher.{log,error.log}"

elif [ "$OS" = "Linux" ]; then
    UNIT_DIR="$XDG_CONFIG/systemd/user"
    UNIT_FILE="$UNIT_DIR/ghostty-theme-watcher.service"

    mkdir -p "$UNIT_DIR"
    cat > "$UNIT_FILE" <<EOF
[Unit]
Description=GhosttySetup theme watcher
After=graphical-session.target

[Service]
Type=simple
ExecStart=$BIN_DIR/ghostty-theme-watcher
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF
    echo "Installed systemd unit: $UNIT_FILE"

    if command -v systemctl >/dev/null 2>&1; then
        systemctl --user daemon-reload
        systemctl --user enable --now ghostty-theme-watcher.service
        echo "  Watcher enabled via 'systemctl --user'."
        echo "  Logs: journalctl --user -u ghostty-theme-watcher.service -f"
    else
        echo "  systemctl not found. Start manually: $BIN_DIR/ghostty-theme-watcher"
    fi
fi

# --- Cache dir & summary ----------------------------------------------------

mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/ghostty-theme-watcher"

cat <<'EOM'

Installation complete.

The watcher will detect system appearance changes and rewrite split-divider-color
and unfocused-split-fill in your Ghostty config. Restart Ghostty (Cmd+Q on macOS,
quit and reopen on Linux) to see split-color changes take effect.

Cursor contrast and paste UX are handled directly in the installed config via
cursor-color=cell-foreground, cursor-text=cell-background, cursor-style=block,
cursor-style-blink=true, shell-integration-features=no-cursor, and
clipboard-paste-protection=false.

To uninstall, run ./uninstall.sh.
EOM
