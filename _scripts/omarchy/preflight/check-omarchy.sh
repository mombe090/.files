#!/usr/bin/env bash
# Check if running on Omarchy

PREFLIGHT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$PREFLIGHT_DIR/.." && pwd)"

# Source helpers
source "$SCRIPT_DIR/helpers/all.sh"

log_info "Verifying Omarchy installation..."

if ! is_omarchy; then
    log_error "Not running on Omarchy"
    log_error "These patches are designed for Omarchy Linux"
    exit 1
fi

VERSION=$(get_omarchy_version)
log_success "Omarchy detected (version: $VERSION)"
