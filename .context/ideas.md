# GhosttySetup Design Ideas and Decisions

## Why a watcher instead of static config
Ghostty 1.2.0+ supports `theme = dark:X,light:Y`, but two keys are NOT switched by the built-in theme system:
- `split-divider-color`
- `unfocused-split-fill`

A background watcher (macOS: `defaults read -g AppleInterfaceStyle`; Linux/GNOME: `gsettings get org.gnome.desktop.interface color-scheme`) rewrites those keys in the active config so split borders stay legible against the active theme.

Cursor color used to be on this list. Since Ghostty 1.2.0, `cursor-color = cell-foreground` and `cursor-text = cell-background` make the cursor self-contrasting — see "Why cursor is now static config" below.

## Why manual restart
`Cmd+Shift+,` (macOS) / `Ctrl+Shift+,` (Linux) reloads most of Ghostty's config but does not refresh split divider colors. A full quit + relaunch is currently required for split keys to pick up the new values. The README spells this out so users do not file bugs against the watcher.

## Theme-aware key palette
| Mode  | split-divider-color | unfocused-split-fill |
|-------|---------------------|----------------------|
| Dark  | #f0f0f0             | #f0f0f0              |
| Light | #0f0f0f             | #0f0f0f              |

Values are intentionally near-pure black/white rather than exact black/white to keep dividers visible against typical terminal backgrounds without looking harsh.

## Shell appearance helper
`shell/appearance.zsh` resets fast-syntax-highlighting to its default theme (which uses ANSI color names that adapt to Ghostty's active palette) and sets a matching `LS_COLORS` / `LSCOLORS`. It is loaded either via zinit (`zinit light neuromechanist/GhosttySetup`) or sourced manually from `~/.zshrc`.

## Outstanding questions
- ~Should `install.sh` back up an existing `~/.config/ghostty/config` before overwriting?~ Yes; done in issue #2.
- ~Should we upgrade `set -e` to `set -euo pipefail`?~ Yes; done in issue #2 for all maintained scripts.
- Is there value in turning the watcher into a Swift app that listens for `NSApplication.appearanceDidChangeNotification` instead of polling? Polling is cheap and simpler to ship, but an event-driven version would feel more native.
- Is `gsettings` enough for Linux, or should we also probe `kreadconfig5` (KDE) and `hyprctl` (Hyprland)? Deferred until someone files an issue.
- Should the bash helper bother with `dircolors`? It works on Linux (GNU coreutils) and on macOS only if the user installed coreutils (`gdircolors`). The helper checks for both.

## Why cursor is now static config, not watcher-managed
`cell-foreground` / `cell-background` were added in Ghostty 1.2.0 specifically to make the cursor self-contrasting. They subsume the deprecated `cursor-invert-fg-bg` and our previous "rewrite cursor-color on theme change" loop. The watcher now only manages keys Ghostty cannot derive at draw time — `split-divider-color` and `unfocused-split-fill`.
