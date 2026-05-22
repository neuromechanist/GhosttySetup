# GhosttySetup

Lightweight Ghostty configuration with always-readable cursor, theme-aware split dividers, prominent typing indicator, and frictionless paste. Works on macOS and Linux (GNOME tested).

## Features

- **Cursor that always contrasts**: uses Ghostty 1.2.0+ `cell-foreground` / `cell-background` so the cursor inverts against whatever cell it covers, in any theme
- **Prominent typing indicator**: block cursor, blinking, with shell-integration's bar override disabled
- **No paste-confirmation popup**: `clipboard-paste-protection = false`
- **Theme-aware split dividers**: white (#f0f0f0) in dark mode, black (#0f0f0f) in light mode, updated automatically by a background watcher
- **Theme-aware split fill**: matches divider color for a clean unfocused-pane look
- **Split opacity**: unfocused panes dimmed to 99%
- **Shell appearance helpers**: fast-syntax-highlighting (zsh) and LS_COLORS / LSCOLORS adapt to the active appearance
- **zsh plugin entry**: loadable via zinit

## Platform Support

| Platform | Status | Appearance probe | Background service |
|----------|--------|------------------|--------------------|
| macOS 13+ | Supported | `defaults read -g AppleInterfaceStyle` | LaunchAgent |
| Linux + GNOME (Ubuntu 22.04+) | Supported | `gsettings get org.gnome.desktop.interface color-scheme` | systemd user unit |
| Linux + KDE / Hyprland / Sway | Not yet | — | — |
| Windows | Not supported by Ghostty itself; see [Winghostty](https://winghostty.com/) | — | — |

The installer detects your OS automatically and refuses to install on unsupported platforms with a pointer to the appropriate next step.

## Installation

```bash
git clone https://github.com/neuromechanist/GhosttySetup.git
cd GhosttySetup
./install.sh
```

This installs:

- Ghostty config (with backup of any existing one)
  - macOS: `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`
  - Linux: `~/.config/ghostty/config.ghostty`
- Theme watcher binary at `~/.local/bin/ghostty-theme-watcher`
- Background service that runs the watcher on login
  - macOS: LaunchAgent (`~/Library/LaunchAgents/com.ghostty.theme-watcher.plist`)
  - Linux: systemd user unit (`~/.config/systemd/user/ghostty-theme-watcher.service`)
- Shell appearance helpers: `appearance.zsh` and `appearance.bash` in `~/.config/ghostty/`

## How It Works

The theme watcher polls the system appearance and rewrites two keys in your Ghostty config: `split-divider-color` and `unfocused-split-fill`. After a change, manually quit and reopen Ghostty (Cmd+Q on macOS) so the new split colors take effect.

**Why manual restart?** Ghostty's config reload (Cmd+Shift+, on macOS, Ctrl+Shift+, on Linux) does not refresh split colors; only a full restart applies them.

### Theme-Aware Keys

| Mode  | split-divider-color | unfocused-split-fill |
|-------|---------------------|----------------------|
| Dark  | #f0f0f0 (near white)| #f0f0f0              |
| Light | #0f0f0f (near black)| #0f0f0f              |

Cursor color is no longer in this table: as of Ghostty 1.2.0, `cursor-color = cell-foreground` and `cursor-text = cell-background` are special values that make the cursor invert against whichever cell it covers. There is nothing for the watcher to switch.

## Configuration

The installed config (`config/config` in this repo) sets:

- **Theme**: `theme = dark:GitHub Dark,light:GitHub` (override with any bundled theme — run `ghostty +list-themes`)
- **Minimum contrast**: `minimum-contrast = 4.5` (WCAG AA). Prevents TUIs that render bright-white text on near-white themes (e.g., Claude Code question prompts on GitHub light) from being invisible. Raise toward 7 for AAA.
- **Splits**: `split-divider-color`, `unfocused-split-fill` (theme-watcher managed), `unfocused-split-opacity = 0.95`
- **Cursor**: `cursor-color = cell-foreground`, `cursor-text = cell-background`, `cursor-style = block`, `cursor-style-blink = true`
- **Shell integration**: `shell-integration-features = no-cursor,ssh-terminfo,ssh-env` (block/blink cursor preserved at prompt; SSH terminfo and TERM env forwarding enabled)
- **Keybind**: `shift+enter=text:\n` (literal newline, useful for multi-line input widgets)
- **Paste**: `clipboard-paste-protection = false`

Add personal overrides (font, padding, extra keybinds) below the marker comment at the bottom of the installed config. The installer always overwrites the file but creates a `.bak.<timestamp>` next to it on every run, so you can recover prior customizations.

## Shell Appearance

The shell helper sets fast-syntax-highlighting (zsh) and LS_COLORS / LSCOLORS for the current appearance. Pick the file that matches your shell.

### zsh, via zinit (recommended)

Add to your `~/.zshrc` after loading fast-syntax-highlighting:

```zsh
zinit light neuromechanist/GhosttySetup
```

### zsh, manual

```zsh
source ~/.config/ghostty/appearance.zsh
```

### bash

```bash
source ~/.config/ghostty/appearance.bash
```

### fish or other shells

No first-class helper yet. The bash file is POSIX-ish; you can adapt it or open an issue.

## Theme Watcher Control

The watcher runs automatically via the platform's service manager. To control it manually:

### macOS

```bash
launchctl unload ~/Library/LaunchAgents/com.ghostty.theme-watcher.plist  # stop
launchctl load   ~/Library/LaunchAgents/com.ghostty.theme-watcher.plist  # start
tail -f /tmp/ghostty-theme-watcher.log
tail -f /tmp/ghostty-theme-watcher.error.log
```

### Linux (systemd)

```bash
systemctl --user stop  ghostty-theme-watcher.service
systemctl --user start ghostty-theme-watcher.service
journalctl --user -u ghostty-theme-watcher.service -f
```

## Uninstall

```bash
./uninstall.sh
```

Removes the watcher, service, shell helpers, and renames the installed config to `*.uninstall-bak.<timestamp>` so you can recover it. The parent config directory is preserved.

## Why This Project Exists

Ghostty 1.1.0+ supports built-in theme switching with `theme = dark:X,light:Y`. That handles the standard ANSI palette but does not switch `split-divider-color` or `unfocused-split-fill`, which remain static config values. This project adds a tiny background watcher to flip those keys with the system mode, and bundles cursor and paste defaults that make day-to-day terminal use less annoying.

Cursor color used to be on that watch list too. Since Ghostty 1.2.0, the special values `cell-foreground` / `cell-background` make the cursor self-contrasting, so the watcher no longer needs to touch cursor keys.

## Migrating from WezTerm

If you are coming from a WezTerm config, key bindings are largely compatible. Major differences:

| Feature | WezTerm | Ghostty |
|---------|---------|---------|
| Split dividers | `config.colors.split` | `split-divider-color` |
| Split opacity | `inactive_pane_hsb.brightness` | `unfocused-split-opacity` |
| Config reload | auto on save | Cmd+Shift+, or full restart for split colors |
| Theme switching | `window-config-reloaded` event | built-in `theme = dark:X,light:Y` + this watcher |

## Requirements

- Ghostty 1.2.0 or later (1.2.3+ recommended for the `config.ghostty` filename)
- macOS 13+ OR Linux with GNOME 42+ (for `gsettings color-scheme`)
- A JetBrains Mono-compatible font (or edit the font setting after install)
- macOS only: Accessibility permission for the optional reload helper, if you want automatic config reload after appearance changes

## License

MIT
