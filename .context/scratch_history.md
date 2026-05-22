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

### 2026-05-22 — macOS config path mismatch (latent bug)
- What was tried: trusted the pre-existing setup where `install.sh` wrote to `~/.config/ghostty/config` while `bin/ghostty-theme-watcher` edited `~/Library/Application Support/com.mitchellh.ghostty/config`.
- Why it failed: on macOS, the Application Support file is loaded AFTER the XDG file and overrides it. The installer's settings were effectively masked by whatever the Ghostty .app had previously written to Application Support, and the watcher's edits never visibly affected the installed config.
- What we did instead: in issue #2, install and watcher now both target `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` on macOS.
- Where the fix lives: install.sh, bin/ghostty-theme-watcher (resolve_config_file).

### 2026-05-22 — Typing indicator missing
- What was tried: set `cursor-style-blink = true` to make the cursor more visible while typing.
- Why it failed: Ghostty's shell integration forcibly switches to a thin bar cursor at every prompt, overriding the config.
- What we did instead: added `shell-integration-features = no-cursor` so the prompt no longer overrides the block/blink cursor.
- Where the fix lives: config/config.

### 2026-05-22 — Claude Code question text invisible on GitHub light theme
- What was tried: shipped `theme = dark:GitHub Dark,light:GitHub` with default contrast settings (Ghostty's default `minimum-contrast` is 1.1).
- Why it failed: Claude Code's TUI renders its question header in bright-white (ANSI brightWhite / color 15), which the GitHub light theme maps near `#ffffff` — invisible on the near-white background.
- What we did instead: added `minimum-contrast = 3` so Ghostty bumps any foreground to meet a 3:1 ratio against its background at draw time. We initially tried `4.5` (WCAG AA) but it visibly washed out syntax-highlight nuance; `3` is Ghostty docs' "recommended floor to avoid difficult-to-read text" and felt like the right balance.
- Where the fix lives: config/config, README.md.

### 2026-05-22 — Installer wiped theme directive
- What was tried: shipped a minimal `config/config` that set splits, cursor, paste, and `shell-integration-features = no-cursor`. Ran install on a Mac that already had `theme = dark:GitHub Dark,light:GitHub`, a custom keybind, and `shell-integration-features = ssh-terminfo / ssh-env`.
- Why it failed: with no `theme = ...` in our installed file, Ghostty fell back to its default dark theme regardless of system appearance — light mode rendered with a dark background. The single `shell-integration-features = no-cursor` line also replaced the user's ssh-terminfo/ssh-env preferences.
- What we did instead: shipped a `theme = dark:GitHub Dark,light:GitHub` default in `config/config`, combined the shell-integration features into one line (`no-cursor,ssh-terminfo,ssh-env`), restored `unfocused-split-opacity = 0.95`, restored the `shift+enter=text:\n` keybind, and added a "personal overrides go below" marker plus README note about the per-install `.bak` file.
- Where the fix lives: config/config, README.md.

### 2026-05-22 — Cursor watcher logic was unnecessary
- What was tried: previous design kept a watcher loop writing `cursor-color` / `cursor-text` on every appearance change.
- Why it failed: not a failure per se — it just became dead weight after Ghostty 1.2.0 introduced `cell-foreground` / `cell-background`. Same outcome with less code and no watcher round-trip.
- What we did instead: deleted the cursor branch of the watcher; cursor contrast is now pure config.
- Where the fix lives: bin/ghostty-theme-watcher, config/config.

## Template for future entries
```
### YYYY-MM-DD — short title
- What was tried:
- Why it failed:
- What we did instead:
- Where the fix lives:
```
