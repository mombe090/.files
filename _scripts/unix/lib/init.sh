#!/usr/bin/env bash
# =============================================================================
# Unix Library Initialization
# =============================================================================
# Source this file to load all Unix shell libraries.
#
# Usage:
#   # In your script, source this file:
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   LIB_DIR="$(cd "$SCRIPT_DIR/../lib" && pwd)"
#   source "$LIB_DIR/init.sh"
#
#   # Or if script is at different depth:
#   source "$DOTFILES_ROOT/_scripts/unix/lib/init.sh"
# =============================================================================

# Get the directory where this init.sh file is located
readonly LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all library modules
source "$LIB_DIR/colors.sh"
source "$LIB_DIR/detect.sh"
source "$LIB_DIR/common.sh"
source "$LIB_DIR/package-managers.sh"

# Log that libraries were loaded (only if log_info is available)
if declare -f log_info &>/dev/null; then
    log_info "Unix shell libraries loaded from: $LIB_DIR"
fi
