# GhosttySetup: appearance-aware shell color configuration (zsh)
#
# Detects system dark/light mode and aligns fast-syntax-highlighting and
# LS_COLORS / LSCOLORS with whichever Ghostty color scheme is active.
#
# Ghostty's color schemes define ANSI color palettes with readable colors on
# their respective backgrounds; FSH's default theme uses ANSI color names, so
# it automatically adapts to the active scheme.
#
# Source this file in your ~/.zshrc AFTER loading fast-syntax-highlighting:
#   source ~/.config/ghostty/appearance.zsh

# Detect OS appearance: prints "dark" or "light".
ghosttysetup_detect_appearance() {
  case "$(uname -s)" in
    Darwin)
      if defaults read -g AppleInterfaceStyle &>/dev/null; then
        echo "dark"
      else
        echo "light"
      fi
      ;;
    Linux)
      local scheme=""
      if (( $+commands[gsettings] )); then
        scheme=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)
      fi
      case "$scheme" in
        *prefer-dark*) echo "dark" ;;
        *) echo "light" ;;
      esac
      ;;
    *)
      echo "light"
      ;;
  esac
}

ghosttysetup_update_colors() {
  local appearance
  appearance=$(ghosttysetup_detect_appearance)

  # FSH default theme uses ANSI color names that map through the active Ghostty
  # palette in both light and dark modes.
  if (( $+functions[fast-theme] )); then
    fast-theme default &>/dev/null
  fi

  # macOS ls uses LSCOLORS (BSD); GNU ls uses LS_COLORS via dircolors.
  if [[ "$appearance" == "light" ]]; then
    export LSCOLORS="ExGxDxDxCxDxDxBxBxExEx"
  else
    export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
  fi

  if (( $+commands[gdircolors] )); then
    eval "$(gdircolors -b)"
  elif (( $+commands[dircolors] )); then
    eval "$(dircolors -b)"
  fi

  # Clear git color env overrides from previous versions.
  if [[ -n "${GIT_CONFIG_COUNT:-}" ]]; then
    local -i old_count=$GIT_CONFIG_COUNT
    unset GIT_CONFIG_COUNT
    local -i i
    for (( i=0; i < old_count; i++ )); do
      unset "GIT_CONFIG_KEY_${i}" "GIT_CONFIG_VALUE_${i}"
    done
  fi
}

ghosttysetup_update_colors
