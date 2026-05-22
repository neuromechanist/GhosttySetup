# GhosttySetup Design Ideas and Decisions

## Why a watcher instead of static config
Ghostty 1.1.0 supports `theme = dark:X,light:Y`, but four keys are NOT switched by the built-in theme system:
- `cursor-color`
- `cursor-text`
- `split-divider-color`
- `unfocused-split-fill`

A background watcher polls `defaults read -g AppleInterfaceStyle` and rewrites those keys in the active config so the rest of the appearance stays consistent with the system theme.

## Why manual restart
`Cmd+Shift+,` reloads most of Ghostty's config but does not refresh split divider colors. A full quit + relaunch is currently required for split keys to pick up the new values. The README spells this out so users do not file bugs against the watcher.

## Theme-aware key palette
| Mode  | cursor-color | cursor-text | split-divider-color | unfocused-split-fill |
|-------|--------------|-------------|---------------------|----------------------|
| Dark  | #f0f0f0      | #0f0f0f     | #f0f0f0             | #f0f0f0              |
| Light | #0f0f0f      | #f0f0f0     | #0f0f0f             | #0f0f0f              |

Values are intentionally near-pure black/white rather than exact black/white to keep the cursor visible against typical terminal backgrounds without looking harsh.

## Shell appearance helper
`shell/appearance.zsh` resets fast-syntax-highlighting to its default theme (which uses ANSI color names that adapt to Ghostty's active palette) and sets a matching `LS_COLORS` / `LSCOLORS`. It is loaded either via zinit (`zinit light neuromechanist/GhosttySetup`) or sourced manually from `~/.zshrc`.

## Outstanding questions
- Should `install.sh` back up an existing `~/.config/ghostty/config` before overwriting? Today it copies unconditionally. The repo template is intentionally minimal so a backup-and-merge flow would be friendlier.
- Should we upgrade `set -e` to `set -euo pipefail` across the shell scripts? Pros: safer; Cons: a couple of conditional `launchctl` and `xattr` calls already swallow failures intentionally and would need explicit `|| true`.
- Is there value in turning the watcher into a Swift app that listens for `NSApplication.appearanceDidChangeNotification` instead of polling? Polling is cheap and simpler to ship, but an event-driven version would feel more native.
