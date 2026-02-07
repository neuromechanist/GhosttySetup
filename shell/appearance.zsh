# GhosttySetup: Appearance-aware shell color configuration
# Detects system dark/light mode and sets fast-syntax-highlighting theme
# and LS_COLORS accordingly.
#
# Ghostty's color schemes (GitHub Dark / GitHub Light via theme switching)
# define ANSI color palettes with readable colors on their respective
# backgrounds. FSH's default theme uses ANSI color names, so it
# automatically adapts to whichever scheme is active.
#
# Source this file in your ~/.zshrc AFTER loading fast-syntax-highlighting:
#   source ~/.config/ghostty/appearance.zsh

# Detect macOS appearance, returns "dark" or "light"
ghosttysetup_detect_appearance() {
  if defaults read -g AppleInterfaceStyle &>/dev/null; then
    echo "dark"
  else
    echo "light"
  fi
}

# Apply fast-syntax-highlighting theme and LS_COLORS for current appearance
ghosttysetup_update_colors() {
  local appearance
  appearance=$(ghosttysetup_detect_appearance)

  # Use FSH default theme for both modes. It uses ANSI color names (green,
  # yellow, blue, etc.) which the terminal maps to the correct hex values
  # based on the active Ghostty color scheme.
  if (( $+functions[fast-theme] )); then
    fast-theme default &>/dev/null
  fi

  # macOS ls uses LSCOLORS (BSD format)
  # Linux ls uses LS_COLORS (GNU format)
  if [[ "$appearance" == "light" ]]; then
    export LSCOLORS="ExGxDxDxCxDxDxBxBxExEx"
    if (( $+commands[gdircolors] )); then
      eval "$(gdircolors -b)"
    fi
  else
    export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
    if (( $+commands[gdircolors] )); then
      eval "$(gdircolors -b)"
    fi
  fi

  # Clean up any git color env overrides from previous versions
  if [[ -n "${GIT_CONFIG_COUNT:-}" ]]; then
    local -i old_count=$GIT_CONFIG_COUNT
    unset GIT_CONFIG_COUNT
    local -i i
    for (( i=0; i < old_count; i++ )); do
      unset "GIT_CONFIG_KEY_${i}" "GIT_CONFIG_VALUE_${i}"
    done
  fi
}

# Run on shell startup
ghosttysetup_update_colors
