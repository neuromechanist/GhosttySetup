# GhosttySetup Instructions

## Project Context
**Purpose:** Lightweight, theme-aware Ghostty terminal configuration for macOS. Adds dynamic appearance switching for cursor, split dividers, and shell colors that Ghostty's built-in `theme = dark:X,light:Y` does not handle. Long overdue housekeeping: bringing AGENTS.md/CLAUDE.md/.rules/.context conventions into this repo so future agent work follows the same standards as our other projects.

**Tech Stack:**
- Bash (installer, uninstaller, theme watcher, reload helper)
- Zsh (shell appearance helper, zinit plugin entry)
- macOS LaunchAgent (`launchd` plist for background watcher)
- Ghostty 1.1.0+ config

**Architecture:**
- `install.sh` / `uninstall.sh` — idempotent installers that drop files into `~/.config/ghostty`, `~/.local/bin`, and `~/Library/LaunchAgents`
- `bin/ghostty-theme-watcher` — long-running watcher polling `defaults read -g AppleInterfaceStyle` and rewriting theme-aware keys in the active Ghostty config
- `bin/create-reload-app.sh` — optional AppleScript bundle so the watcher can trigger Ghostty's config reload
- `shell/appearance.zsh` — sourced at shell start to align fast-syntax-highlighting + LS_COLORS with the active appearance
- `config/config` — minimal Ghostty config template installed to `~/.config/ghostty/config`
- `ghosttysetup.plugin.zsh` — zinit/zsh plugin entry that sources `shell/appearance.zsh`

## Repo Map
```
.
├── bin/
│   ├── ghostty-theme-watcher       # Background appearance watcher
│   └── create-reload-app.sh        # Builds Ghostty Reload Helper.app
├── config/
│   └── config                      # Ghostty config template
├── shell/
│   └── appearance.zsh              # FSH + LS_COLORS appearance helper
├── ghosttysetup.plugin.zsh         # zinit plugin entry
├── install.sh                      # Installer
├── uninstall.sh                    # Uninstaller
└── README.md                       # End-user docs
```

## Environment Setup
Manual workflow (no package manager — shell-only project):
```bash
# Install onto the current macOS user
./install.sh

# Tail the watcher logs while testing
tail -f /tmp/ghostty-theme-watcher.log

# Toggle the watcher
launchctl unload ~/Library/LaunchAgents/com.ghostty.theme-watcher.plist
launchctl load   ~/Library/LaunchAgents/com.ghostty.theme-watcher.plist

# Remove everything
./uninstall.sh
```

## Development Workflow
1. **Check context:** Review `.context/plan.md` for pending work.
2. **Understand deeply:** Check `.context/ideas.md` for design decisions (theme-aware keys, opacity, why a watcher).
3. **Research if needed:** Update `.context/research.md` with Ghostty config quirks and macOS appearance APIs.
4. **Branch:** `gh issue develop <issue-number>` (or short topic branch for trivial fixes).
5. **Code:** Edit shell scripts in place; keep `set -e` and idempotency.
6. **Test:** Run `./install.sh` on the dev machine, toggle System Settings > Appearance, confirm Ghostty config keys flip and logs are clean. Document failures in `.context/scratch_history.md`.
7. **Commit:** Atomic, <50 chars, no emojis, no AI attribution.
8. **PR:** Reference issue and what was manually verified (light↔dark toggle, install, uninstall).
9. **Code review:** Run `/review-pr` after creating the PR (see `.rules/code_review.md`).

## [CRITICAL] Core Principles

### Idempotent Installs
- `install.sh` must be safe to run repeatedly without duplicating launch agents, helper apps, or shell sources.
- Always unload an existing LaunchAgent before reloading it.
- Never overwrite a user's existing `~/.config/ghostty/config` without an explicit prompt or backup; today's behavior unconditionally copies the template — flag any change to that.

### Test Reality Only (no mocks)
- This is a macOS-only shell project. There is no unit-test harness; tests are manual: install, switch appearance, observe.
- Capture each manual verification step in the PR body and in `.context/scratch_history.md` when something breaks.
**Details:** `.rules/testing.md` (adapt the "no mocks" stance to shell — verify on the real OS).

### Commits & Git
- Atomic commits, focused changes; messages <50 chars, no emojis, no AI attribution.
**Details:** `.rules/git.md`.

### No Technical Debt Carried Forward
- Address all PR review findings; only skip genuine false positives with an explanation in the PR.
**Details:** `.rules/code_review.md`.

### Documentation
- Keep `README.md` the source of truth for end users; AGENTS.md is for contributors and agents.
- Update the README's feature table whenever a new theme-aware key is added or removed.
**Details:** `.rules/documentation.md`.

## [NEVER DO THIS]
- Never overwrite the user's Ghostty config without backing it up or warning.
- Never silently fail in `install.sh` / `uninstall.sh`; `set -e` plus explicit error messages.
- Never hardcode personal paths (`/Users/yahya/...`) into installed artifacts; use `$HOME` and `$SCRIPT_DIR`.
- Never commit secrets, .env files, or credentials.
- Never add emojis or AI attribution to commits, PRs, or scripts.
- Never add a TODO without a linked issue.
- Never assume Linux/Windows — this project is macOS-only (uses `defaults`, `launchctl`, `osascript`).

## [REFERENCE] Rules Directory

### Core Standards
- `.rules/testing.md` — Manual verification stance, adapted from the NO MOCK policy
- `.rules/self_improve.md` — Capturing learnings from each iteration
- `.rules/documentation.md` — README + AGENTS.md conventions
- `.rules/code_review.md` — `/review-pr` workflow and checklist
- `.rules/git.md` — Commit, branch, and PR conventions

### Tooling
- `.rules/ci_cd.md` — GitHub Actions guidance (currently no CI; add lint workflow when scripts grow)
- `.rules/serena_mcp.md` — Code intelligence via Serena MCP (optional)

## Context Files
- `.context/plan.md` — Current tasks and phases
- `.context/research.md` — Ghostty config behavior, macOS appearance APIs
- `.context/ideas.md` — Design decisions (theme-aware keys, watcher vs static config, opacity)
- `.context/scratch_history.md` — Failed attempts and lessons

## Quick Commands
```bash
# Install / reinstall
./install.sh

# Uninstall
./uninstall.sh

# Watcher logs
tail -f /tmp/ghostty-theme-watcher.log
tail -f /tmp/ghostty-theme-watcher.error.log

# Force a manual appearance probe
defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light"

# Lint shell scripts (install when needed)
shellcheck install.sh uninstall.sh bin/ghostty-theme-watcher bin/create-reload-app.sh
```

## Project-Specific Guidelines
- Maintain the theme-aware key table in `README.md` (cursor-color, cursor-text, split-divider-color, unfocused-split-fill). Any new key needs a row and a watcher update in lockstep.
- `shell/appearance.zsh` should remain safe to source from non-Ghostty terminals; guard on `$GHOSTTY_RESOURCES_DIR` or similar when adding Ghostty-only logic.
- Prefer `set -euo pipefail` for new scripts; existing scripts use `set -e` — upgrade opportunistically when touching them.
- LaunchAgent label is `com.ghostty.theme-watcher`; keep it stable so existing installs upgrade cleanly.

---
Remember: this is a small but user-facing tool. Breakage shows up immediately on the contributor's own desktop, so favor visible logging and idempotent operations over cleverness.
