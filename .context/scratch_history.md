# GhosttySetup Scratch History

## Purpose
Capture failed attempts, dead ends, and lessons learned so we do not repeat them. Date each entry.

## Lessons captured from prior work

### 2026-05-22 — Initial AGENTS.md adoption
Brought AGENTS.md / CLAUDE.md / .rules / .context conventions into this repo well after the project had stabilized. No code changes were needed; the templates were customized to reflect the existing shell + LaunchAgent architecture. Removed `.rules/python.md` because this project is shell-only on macOS.

### Historical (recovered from README and commit history)
- `Cmd+Shift+,` does not refresh split divider colors. Several attempts at "reload without restart" failed because Ghostty itself does not re-apply those keys live. Workaround: a manual quit + relaunch, documented in the README.
- Earlier configs tried to bake colors into a single static `theme` block. That broke as soon as the user switched between light and dark mode, which is why the watcher exists.
- Hardcoding `/Users/<name>/...` paths into installed artifacts broke other contributors. All installed scripts now resolve `$HOME` and `$SCRIPT_DIR` at runtime.

## Template for future entries
```
### YYYY-MM-DD — short title
- What was tried:
- Why it failed:
- What we did instead:
- Where the fix lives:
```
