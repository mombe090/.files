#!/usr/bin/env bash
# Orchestrate all configuration patches

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$CONFIG_DIR/.." && pwd)"

# Source helpers
source "$SCRIPT_DIR/helpers/all.sh"

log_info "Applying configuration patches..."

# Count total scripts
TOTAL_SCRIPTS=$(find "$CONFIG_DIR" -maxdepth 1 -name "*.sh" ! -name "all.sh" | wc -l)
CURRENT=0

# Run each config patch
for script in "$CONFIG_DIR"/*.sh; do
    # Skip all.sh itself
    [[ "$(basename "$script")" == "all.sh" ]] && continue
    
    CURRENT=$((CURRENT + 1))
    script_name=$(basename "$script" .sh)
    log_info "→ [$CURRENT/$TOTAL_SCRIPTS] Patching: $script_name"
    bash "$script"
done

log_success "All configuration patches completed"
