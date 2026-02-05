#!/usr/bin/env bash
# =============================================================================
# Logging Functions for Unix Scripts
# =============================================================================
# This module provides colored logging functions for Unix shell scripts.
#
# Functions:
#   - log_info: Informational messages (green)
#   - log_success: Success messages (green with checkmark)
#   - log_error: Error messages (red)
#   - log_warning: Warning messages (yellow)
#   - log_header: Section headers (magenta)
#   - log_step: Sub-step messages (blue)
# =============================================================================

# Color codes
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_MAGENTA='\033[0;35m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_NC='\033[0m'  # No Color

# =============================================================================
# log_info - Print an informational message in green
#
# Usage: log_info "message"
# Example: log_info "Installing package..."
# =============================================================================
log_info() {
    echo -e "${COLOR_GREEN}[INFO]${COLOR_NC} $1"
}

# =============================================================================
# log_success - Print a success message in green with a checkmark
#
# Usage: log_success "message"
# Example: log_success "Installation complete"
# =============================================================================
log_success() {
    echo -e "${COLOR_GREEN}[✓]${COLOR_NC} $1"
}

# =============================================================================
# log_error - Print an error message in red to stderr
#
# Usage: log_error "message"
# Example: log_error "Failed to install package"
# =============================================================================
log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_NC} $1" >&2
}

# =============================================================================
# log_warning - Print a warning message in yellow
#
# Usage: log_warning "message"
# Example: log_warning "Package already installed"
# =============================================================================
log_warning() {
    echo -e "${COLOR_YELLOW}[WARN]${COLOR_NC} $1"
}

# Alias for consistency
log_warn() {
    log_warning "$@"
}

# =============================================================================
# log_header - Print a section header in magenta with separator lines
#
# Usage: log_header "message"
# Example: log_header "Installing Dependencies"
# =============================================================================
log_header() {
    echo ""
    echo -e "${COLOR_MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo -e "${COLOR_MAGENTA}[#] $1${COLOR_NC}"
    echo -e "${COLOR_MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_NC}"
    echo ""
}

# =============================================================================
# log_step - Print a step message in blue
#
# Usage: log_step "message"
# Example: log_step "Checking dependencies"
# =============================================================================
log_step() {
    echo -e "${COLOR_BLUE}[STEP]${COLOR_NC} $1"
}
