#!/usr/bin/env bash
# Verify installation

VERIFY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$VERIFY_DIR/.." && pwd)"

# Source helpers
source "$SCRIPT_DIR/helpers/all.sh"

log_info "Verifying installation..."

ERRORS=0

# Verify critical directories
CRITICAL_DIRS=(
    "$HOME/.config/hypr/custom"
    "$HOME/.config/zsh/custom"
)

for dir in "${CRITICAL_DIRS[@]}"; do
    if [[ ! -d "$dir" ]]; then
        log_error "Missing directory: $dir"
        ((ERRORS++))
    fi
done

if [[ $ERRORS -gt 0 ]]; then
    log_error "Verification failed with $ERRORS errors"
    exit 1
fi

log_success "Verification passed"
