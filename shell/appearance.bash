# GhosttySetup: appearance-aware shell color configuration (bash)
#
# Detects system dark/light mode and sets LS_COLORS / LSCOLORS to match
# whichever Ghostty color scheme is active.
#
# Source this file in your ~/.bashrc:
#   source ~/.config/ghostty/appearance.bash

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
      if command -v gsettings >/dev/null 2>&1; then
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

  if [ "$appearance" = "light" ]; then
    export LSCOLORS="ExGxDxDxCxDxDxBxBxExEx"
  else
    export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
  fi

  if command -v gdircolors >/dev/null 2>&1; then
    eval "$(gdircolors -b)"
  elif command -v dircolors >/dev/null 2>&1; then
    eval "$(dircolors -b)"
  fi

  if [ -n "${GIT_CONFIG_COUNT:-}" ]; then
    local old_count=$GIT_CONFIG_COUNT
    unset GIT_CONFIG_COUNT
    local i=0
    while [ "$i" -lt "$old_count" ]; do
      unset "GIT_CONFIG_KEY_${i}" "GIT_CONFIG_VALUE_${i}"
      i=$((i + 1))
    done
  fi
}

ghosttysetup_update_colors
