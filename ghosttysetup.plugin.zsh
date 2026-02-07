# GhosttySetup - Ghostty configuration plugin
# https://github.com/neuromechanist/GhosttySetup

# Standard zinit/zsh plugin dir detection
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"
local _ghosttysetup_dir="${0:h}"

# Export plugin dir so install.sh can detect plugin mode
export GHOSTTYSETUP_PLUGIN_DIR="$_ghosttysetup_dir"

# Source appearance-aware colors (dark/light theme detection for shell)
source "$_ghosttysetup_dir/shell/appearance.zsh"
