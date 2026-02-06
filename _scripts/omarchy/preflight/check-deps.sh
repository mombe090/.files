#!/usr/bin/env bash
# Check required dependencies

PREFLIGHT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$PREFLIGHT_DIR/.." && pwd)"

# Source helpers
source "$SCRIPT_DIR/helpers/all.sh"

REQUIRED_COMMANDS=(git stow)

log_info "Checking required commands..."

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! has_command "$cmd"; then
        log_error "Required command not found: $cmd"
        log_error "Install with: sudo pacman -S $cmd"
        exit 1
    else
        log_info "  ✓ $cmd"
    fi
done

log_success "All required dependencies found"
