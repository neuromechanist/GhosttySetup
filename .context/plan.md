# GhosttySetup Development Plan

## Project Overview
**Goal:** Keep Ghostty's appearance theme-aware on macOS by watching system light/dark mode and updating the keys Ghostty does not switch automatically (cursor color/text, split divider, unfocused split fill, shell colors).
**Timeline:** Maintenance mode — feature work as needed.
**Stack:** Bash, Zsh, macOS LaunchAgent, Ghostty 1.1.0+.

## Development Tasks
<!-- Status markers: [ ] pending, [~] in progress, [x] complete -->

### Done (existing repo state)
- [x] Minimal Ghostty config template (`config/config`)
- [x] Theme watcher daemon (`bin/ghostty-theme-watcher`)
- [x] Shell appearance helper (`shell/appearance.zsh`) and zinit plugin entry
- [x] Installer / uninstaller with LaunchAgent provisioning
- [x] README documenting install, theme keys, and watcher control
- [x] Adopt AGENTS.md / CLAUDE.md / .rules / .context conventions in this repo

### Near-term
- [ ] Add a `shellcheck` GitHub Actions workflow for `*.sh` and the watcher script
- [ ] Back up the user's existing `~/.config/ghostty/config` before `install.sh` overwrites it
- [ ] Document the Reload Helper Accessibility setup with a screenshot or short script-driven verification
- [ ] Decide whether to upgrade `set -e` to `set -euo pipefail` across all scripts (see `.context/ideas.md`)

### Stretch / ideas
- [ ] Linux support (would require replacing `defaults` + `launchctl` with a desktop-environment probe and systemd user unit)
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
