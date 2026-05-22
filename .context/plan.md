# GhosttySetup Development Plan

## Project Overview
**Goal:** Keep Ghostty's appearance theme-aware on macOS and Linux/GNOME by watching system light/dark mode and updating the split keys Ghostty does not switch automatically (split divider, unfocused split fill, shell colors). Cursor contrast is handled statically via `cell-foreground` / `cell-background` and minimum-contrast.
**Timeline:** Maintenance mode — feature work as needed.
**Stack:** Bash, Zsh, macOS LaunchAgent, Linux systemd user unit, Ghostty 1.2.0+.

## Development Tasks
<!-- Status markers: [ ] pending, [~] in progress, [x] complete -->

### Done (existing repo state)
- [x] Minimal Ghostty config template (`config/config`)
- [x] Theme watcher daemon (`bin/ghostty-theme-watcher`)
- [x] Shell appearance helper (`shell/appearance.zsh`) and zinit plugin entry
- [x] Installer / uninstaller with LaunchAgent provisioning
- [x] README documenting install, theme keys, and watcher control
- [x] Adopt AGENTS.md / CLAUDE.md / .rules / .context conventions in this repo

### In progress (issue #2 / feature/issue-2-cursor-paste-and-linux)
- [x] Backup existing config before overwrite
- [x] `set -euo pipefail` in install.sh, uninstall.sh, watcher
- [x] Linux/GNOME support (`gsettings`, systemd user unit)
- [x] Cursor UX via `cell-foreground` / `cell-background` (drops watcher cursor handling)
- [x] Prominent typing indicator via `cursor-style = block` + `cursor-style-blink = true` + `shell-integration-features = no-cursor`
- [x] `clipboard-paste-protection = false`
- [x] Bash appearance helper
- [x] Fix macOS path mismatch (installer + watcher now share `Application Support/.../config.ghostty`)
- [ ] Manual verification on this Mac (light↔dark toggle, watcher logs)
- [ ] PR open, `/review-pr` clean

### Near-term (after this PR)
- [ ] `shellcheck` GitHub Actions workflow for `*.sh` and the watcher
- [ ] Document the Reload Helper Accessibility setup with a screenshot

### Stretch / ideas
- [ ] KDE / Hyprland / Sway appearance detection
- [ ] First-class fish shell helper
- [ ] Configurable theme-aware key list (today hardcoded in the watcher)
- [ ] Self-update path for the installed watcher script when the repo changes

## Success Criteria
- [x] Toggling System Settings > Appearance updates Ghostty's theme-aware keys without manual edits
- [x] `install.sh` and `uninstall.sh` are idempotent on a fresh macOS user
- [ ] CI runs shellcheck on every PR
- [ ] README install flow works in under 5 minutes from clone to first appearance switch

## Notes
- Manual restart of Ghostty is intentional — `Cmd+Shift+,` does not refresh split colors. Document that prominently if behavior changes upstream.
- Keep LaunchAgent label `com.ghostty.theme-watcher` stable so existing installs continue to upgrade cleanly.
