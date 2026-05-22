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
- Built-in `theme = dark:X,light:Y` handles the standard color palette but ignores cursor and split keys — that gap is the entire reason this project exists.

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
