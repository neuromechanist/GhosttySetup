# GhosttySetup

Lightweight Ghostty configuration with automatic theme-aware split dividers and split fill colors.

## Features

- **System Theme Integration**: Auto-switches between light/dark themes
- **Theme-Aware Split Dividers**: White (#f0f0f0) in dark mode, black (#0f0f0f) in light mode
- **Theme-Aware Split Fill**: Matches split divider color for consistent appearance
- **Split Opacity**: Unfocused splits dimmed to 99% opacity
- **Automatic Config Reload**: Uses Ghostty's Cmd+Shift+, reload mechanism
- **Key Bindings**: WezTerm-compatible shortcuts for easy migration
- **Background Theme Watcher**: Automatic appearance detection and config updates

## Installation

```bash
git clone https://github.com/neuromechanist/GhosttySetup.git
cd GhosttySetup
./install.sh
```

This installs:
- Theme watcher script to `~/.local/bin/ghostty-theme-watcher`
- Theme watcher as a LaunchAgent (runs automatically on login)

**Note:** Does not modify your existing Ghostty config. The watcher updates split colors in your config at:
```
~/Library/Application Support/com.mitchellh.ghostty/config
```

## How It Works

The theme watcher runs in the background and:
1. Monitors macOS system appearance (dark/light mode)
2. Automatically updates `split-divider-color` and `unfocused-split-fill` in your config
3. You manually restart Ghostty (Cmd+Q, reopen) when you want to apply the new colors

**Why manual restart?** Ghostty's config reload (Cmd+Shift+,) doesn't update split colors - only a full restart applies them.

### Theme-Aware Colors

| Mode  | split-divider-color | unfocused-split-fill |
|-------|---------------------|----------------------|
| Dark  | #f0f0f0 (white)     | #f0f0f0 (white)      |
| Light | #0f0f0f (black)     | #0f0f0f (black)      |

## Configuration

The main config file (`~/.config/ghostty/config`) includes:

**Theme Management:**
- Built-in theme switching: `theme = dark:GhosttyDark,light:GhosttyLight`
- Dynamic split colors updated by theme watcher

**Split Appearance:**
- Split dividers: Theme-aware (white in dark, black in light)
- Unfocused split fill: Matches divider color
- Unfocused split opacity: 99%

**Key Bindings:**
- Standard terminal navigation (Option+arrows, Cmd+arrows)
- Shift+Enter sends `\x1b\r`
- Font size: Cmd+Plus/Minus/0
- Pane splitting: Cmd+D (right split), Cmd+Shift+D (down split)
- Pane navigation: Cmd+Shift+Arrows
- Pane resize: Cmd+Ctrl+Arrows

## Theme Watcher Control

The theme watcher runs automatically via LaunchAgent. To control it manually:

```bash
# Stop theme watcher
launchctl unload ~/Library/LaunchAgents/com.ghostty.theme-watcher.plist

# Start theme watcher
launchctl load ~/Library/LaunchAgents/com.ghostty.theme-watcher.plist

# View logs
tail -f /tmp/ghostty-theme-watcher.log
tail -f /tmp/ghostty-theme-watcher.error.log
```

## Uninstall

```bash
./uninstall.sh
```

Removes config files, LaunchAgent, and cache directory.

## Why Not Ghostty's Built-in Theme Switching?

Ghostty 1.1.0 supports built-in theme switching with `theme = dark:X,light:Y`, which handles color schemes automatically. However, `split-divider-color` and `unfocused-split-fill` are static config values that don't respond to theme changes.

This project adds a background watcher to make these split appearance settings theme-aware, matching the rest of Ghostty's theme switching behavior.

## Migrating from WezTerm

If you're coming from WezSetup (WezTerm), the key bindings are compatible. Major differences:

| Feature | WezTerm | Ghostty |
|---------|---------|---------|
| Split dividers | config.colors.split | split-divider-color |
| Split opacity | inactive_pane_hsb.brightness | unfocused-split-opacity |
| Config reload | Auto on save | Cmd+Shift+, or script trigger |
| Theme switching | window-config-reloaded event | Built-in theme system + watcher |

## Requirements

- macOS (uses `defaults read -g AppleInterfaceStyle` for appearance detection)
- Ghostty 1.1.0 or later
- JetBrains Mono font (or customize in config)
- Accessibility permissions for automatic config reload (optional, can reload manually)

## License

MIT
