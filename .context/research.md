# GhosttySetup Research Notes

## Purpose
Track Ghostty-specific quirks, macOS appearance APIs, and reference links useful when extending the watcher or shell helper.

## macOS appearance detection
- `defaults read -g AppleInterfaceStyle` returns `Dark` in dark mode and errors (no key) in light mode. The watcher treats a non-zero exit as "Light".
- The value updates immediately on a system appearance change, so polling on a short interval (~2s) is sufficient.
- Per-app appearance overrides (`AppleInterfaceStyleSwitchesAutomatically`, `NSRequiresAquaSystemAppearance`) are not currently considered. If they ever matter, prefer reading `NSAppearance.currentDrawing()` via a small Swift helper.

## Ghostty config reload behavior
- `Cmd+Shift+,` reloads many keys live but does NOT refresh split divider colors. Tested on Ghostty 1.1.0.
- A full quit (`Cmd+Q`) + relaunch is the only reliable way to pick up `split-divider-color` and `unfocused-split-fill` updates today.
- Built-in `theme = dark:X,light:Y` handles the standard color palette but ignores split keys — that gap is the reason the watcher still exists.

## Ghostty 1.2.0+ cursor model
- `cursor-invert-fg-bg` is deprecated. Replacement: `cursor-color = cell-foreground` and `cursor-text = cell-background` — special values that resolve at draw time to the cell colors under the cursor.
- This removes the need to flip cursor colors with the system theme. The watcher used to write `cursor-color` / `cursor-text` on every appearance change; that code is gone.
- Known edge case (issue #4771): a block cursor over an already-inverted cell (e.g., a selection) can render invisible. Acceptable trade-off; not worth working around in code.

## Shell integration overrides cursor
- Ghostty's shell integration forcibly switches the cursor to a thin bar at every prompt, overriding `cursor-style` and `cursor-style-blink`. This was the root cause of the "typing indicator not prominent" complaint.
- Fix: `shell-integration-features = no-cursor`. Programs that explicitly request a bar via DECSCUSR (vim insert mode, fish) still get one — desirable behavior.
- Reference: Ghostty Discussion #2812.

## Linux appearance detection
- GNOME (Ubuntu default): `gsettings get org.gnome.desktop.interface color-scheme` returns `'prefer-dark'`, `'prefer-light'`, or `'default'`. We treat anything not matching `prefer-dark` as light.
- KDE / Hyprland / Sway: each uses different mechanisms (kreadconfig5, hyprctl, plain env). Out of scope until requested.

## Config file paths (canonical)
- macOS: `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` (this loads AFTER XDG and overrides it, so it is the file to install AND the file the watcher edits — earlier code split those between two locations, which was a bug)
- Linux: `$XDG_CONFIG_HOME/ghostty/config.ghostty` or `~/.config/ghostty/config.ghostty`
- Legacy filename `config` is still read but `config.ghostty` is the new canonical filename since 1.2.3.

## Windows status (May 2026)
- No official Ghostty build. Tracking issue: ghostty-org/ghostty#2563.
- Third-party port: https://winghostty.com/. We point users there and exit cleanly when run from MSYS/Cygwin/MINGW.

## Background services
- macOS: LaunchAgent at `~/Library/LaunchAgents/com.ghostty.theme-watcher.plist`. Label stable across versions.
- Linux: systemd user unit at `~/.config/systemd/user/ghostty-theme-watcher.service`. `WantedBy=default.target` so it starts at user-manager activation; `After=graphical-session.target` so `gsettings` works at startup.

## LaunchAgent notes
- Label: `com.ghostty.theme-watcher`. Stable across versions so reinstalls upgrade cleanly.
- `KeepAlive.SuccessfulExit = false` means the agent only restarts on abnormal exits, not when the watcher exits cleanly.
- Logs land in `/tmp/ghostty-theme-watcher.log` and `/tmp/ghostty-theme-watcher.error.log`. `/tmp` is wiped on reboot, which is fine for short-lived debugging logs.

## References
- Ghostty docs: https://ghostty.org/docs
- Ghostty config reference: https://ghostty.org/docs/config/reference
- macOS `launchd.plist` keys: https://www.manpagez.com/man/5/launchd.plist/
- fast-syntax-highlighting: https://github.com/zdharma-continuum/fast-syntax-highlighting

## Open investigation threads
- Is there a public Ghostty IPC for "reload now" that does not require Accessibility permissions? The Reload Helper app exists today because there is not.
- Does Ghostty's upcoming roadmap include theme-aware cursor/split keys natively? If so, parts of this project become obsolete and the watcher should degrade gracefully.
