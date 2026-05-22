#!/usr/bin/env bash
# GhosttySetup uninstaller
#
# Removes the watcher binary, shell helpers, background service, and the
# installed Ghostty config (with backup) on macOS or Linux. Leaves the parent
# config directory in place because it may host unrelated files.

set -euo pipefail

OS="$(uname -s)"
case "$OS" in
    Darwin|Linux) : ;;
    MINGW*|MSYS*|CYGWIN*)
        echo "GhosttySetup was never installed on Windows; nothing to remove."
        exit 0
        ;;
    *)
        echo "GhosttySetup: unsupported OS '$OS'; aborting." >&2
        exit 1
        ;;
esac

XDG_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
BIN_DIR="${GHOSTTYSETUP_BIN_DIR:-$HOME/.local/bin}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/ghostty-theme-watcher"

if [ "$OS" = "Darwin" ]; then
    CONFIG_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
    HELPER_DIR="$XDG_CONFIG/ghostty"
else
    CONFIG_DIR="$XDG_CONFIG/ghostty"
    HELPER_DIR="$CONFIG_DIR"
fi

echo "Uninstalling GhosttySetup ($OS)..."

# --- Background service ----------------------------------------------------

if [ "$OS" = "Darwin" ]; then
    PLIST="$HOME/Library/LaunchAgents/com.ghostty.theme-watcher.plist"
    if [ -f "$PLIST" ]; then
        echo "Stopping LaunchAgent..."
        launchctl unload "$PLIST" 2>/dev/null || true
        rm "$PLIST"
        echo "  Removed $PLIST"
    fi
elif [ "$OS" = "Linux" ]; then
    UNIT_FILE="$XDG_CONFIG/systemd/user/ghostty-theme-watcher.service"
    if [ -f "$UNIT_FILE" ]; then
        echo "Stopping systemd unit..."
        if command -v systemctl >/dev/null 2>&1; then
            systemctl --user disable --now ghostty-theme-watcher.service 2>/dev/null || true
            systemctl --user daemon-reload 2>/dev/null || true
        fi
        rm "$UNIT_FILE"
        echo "  Removed $UNIT_FILE"
    fi
fi

# --- Binaries ---------------------------------------------------------------

if [ -f "$BIN_DIR/ghostty-theme-watcher" ]; then
    rm "$BIN_DIR/ghostty-theme-watcher"
    echo "Removed $BIN_DIR/ghostty-theme-watcher"
fi

# --- Config (with backup) ---------------------------------------------------

for name in config.ghostty config; do
    target="$CONFIG_DIR/$name"
    if [ -f "$target" ]; then
        backup="$target.uninstall-bak.$(date +%Y%m%d%H%M%S)"
        mv "$target" "$backup"
        echo "Moved $target -> $backup"
    fi
done

# --- Shell helpers ----------------------------------------------------------

for f in "$HELPER_DIR/appearance.zsh" "$HELPER_DIR/appearance.bash"; do
    if [ -f "$f" ]; then
        rm "$f"
        echo "Removed $f"
    fi
done

# --- Cache and logs --------------------------------------------------------

if [ -d "$CACHE_DIR" ]; then
    rm -rf "$CACHE_DIR"
    echo "Removed cache dir $CACHE_DIR"
fi

if [ "$OS" = "Darwin" ]; then
    rm -f /tmp/ghostty-theme-watcher.log /tmp/ghostty-theme-watcher.error.log
fi

echo ""
echo "Uninstallation complete."
echo "Note: the parent config directory is preserved; old configs were renamed with a .uninstall-bak suffix in case you want them back."
