#!/usr/bin/env bash
# Orchestrate all preflight checks

PREFLIGHT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$PREFLIGHT_DIR/.." && pwd)"

# Source helpers
source "$SCRIPT_DIR/helpers/all.sh"

log_info "Running preflight checks..."

log_info "→ Checking Omarchy installation..."
bash "$PREFLIGHT_DIR/check-omarchy.sh"

log_info "→ Checking dependencies..."
bash "$PREFLIGHT_DIR/check-deps.sh"

log_info "→ Awaiting user confirmation..."
bash "$PREFLIGHT_DIR/confirm.sh"

log_success "Preflight checks passed"
