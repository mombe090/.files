#!/usr/bin/env bash
# Orchestrate package operations

PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$PACKAGES_DIR/.." && pwd)"

# Source helpers
source "$SCRIPT_DIR/helpers/all.sh"

log_info "Starting package management..."

bash "$PACKAGES_DIR/uninstall-defaults.sh"
bash "$PACKAGES_DIR/install-custom.sh"

log_success "Package management completed"
