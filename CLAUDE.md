@AGENTS.md

## Claude Code Specific Instructions

The shared project instructions live in `AGENTS.md`; this file imports them for Claude Code with `@AGENTS.md`. Append only Claude-specific plugin, skill, command, or MCP guidance below.

### Manual verification, not automated tests
This repo has no test harness — work is verified by running `./install.sh` on the dev Mac and toggling System Settings > Appearance. When you finish a change, state explicitly which manual steps you ran (or that you could not, since UI verification requires the user's machine).

### Useful skills for this repo
- `/review-pr` — required before merging per `.rules/code_review.md`.
- `/init` and `/project:init-project` — already applied; do not re-run unless the rules templates need a refresh, in which case prefer `/project:update-rules`.

### macOS-only assumptions
All shell scripts here rely on `defaults`, `launchctl`, and `osascript`. Do not propose Linux or Windows portability changes without first opening an issue to discuss the scope.

### Do not edit installed artifacts
`~/.config/ghostty/config`, `~/.local/bin/ghostty-theme-watcher`, and the LaunchAgent plist are user state, not part of the repo. Edit the sources in `config/`, `bin/`, and `install.sh`, then ask the user to rerun `./install.sh`.
