#!/usr/bin/env bash
# Hyprland configuration patches using stow
# 1. Copies base config files from hypr/ package (if needed)
# 2. Stows ONLY omarchy_custom package (custom/*.conf overrides)

HYPR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$HYPR_DIR/.." && pwd)"

# Source helpers
source "$SCRIPT_DIR/helpers/all.sh"

log_info "Applying Hyprland patches..."

DOTFILES_HYPR="$DOTFILES_ROOT/hypr/.config/hypr"
DOTFILES_CUSTOM="$DOTFILES_ROOT/omarchy_custom"
TARGET_HYPR="$HOME/.config/hypr"
MARKER="# === Custom Dotfiles Overrides ==="

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would copy base config files (if missing)"
    log_info "[DRY RUN] Would stow omarchy_custom package"
    log_info "[DRY RUN] Would inject custom source lines into hyprland.conf"
    exit 0
fi

# Ensure base config files exist (copy from hypr package if missing)
if [[ -d "$DOTFILES_HYPR" ]]; then
    log_info "  → Ensuring base config files exist..."
    
    # List of required config files
    REQUIRED_CONFIGS=(
        "hyprland.conf"
        "monitors.conf"
        "input.conf"
        "bindings.conf"
        "envs.conf"
        "looknfeel.conf"
        "autostart.conf"
        "utilities.conf"
        "workspaces.conf"
    )
    
    COPIED_COUNT=0
    for conf in "${REQUIRED_CONFIGS[@]}"; do
        if [[ ! -f "$TARGET_HYPR/$conf" ]] && [[ -f "$DOTFILES_HYPR/$conf" ]]; then
            cp "$DOTFILES_HYPR/$conf" "$TARGET_HYPR/$conf"
            COPIED_COUNT=$((COPIED_COUNT + 1))
        fi
    done
    
    if [[ $COPIED_COUNT -gt 0 ]]; then
        log_success "  ✓ Copied $COPIED_COUNT base config files"
    else
        log_info "  ✓ All base config files present"
    fi
fi

# Check if stow is available
if ! command -v stow &> /dev/null; then
    log_error "stow command not found. Please install GNU Stow."
    exit 1
fi

cd "$DOTFILES_ROOT" || {
    log_error "Failed to cd to: $DOTFILES_ROOT"
    exit 1
}

# Stow omarchy_custom package (ONLY custom configs)
if [[ -d "$DOTFILES_CUSTOM" ]]; then
    log_info "  → Stowing omarchy_custom package..."
    STOW_OUTPUT=$(stow -R omarchy_custom 2>&1)
    STOW_EXIT=$?

    if [[ $STOW_EXIT -eq 0 ]]; then
        log_success "  ✓ omarchy_custom stowed successfully"
    else
        log_warn "  ⚠ Stow warnings (likely non-fatal)"
        if [[ -n "$LOG_FILE" ]]; then
            echo "$STOW_OUTPUT" >> "$LOG_FILE"
        fi
    fi
else
    log_info "  ℹ omarchy_custom package not found, skipping custom configs"
fi

# Now inject source lines for custom configs into hyprland.conf
HYPRLAND_CONF="$TARGET_HYPR/hyprland.conf"

if [[ ! -f "$HYPRLAND_CONF" ]]; then
    log_error "Hyprland config not found: $HYPRLAND_CONF"
    log_error "Is Omarchy properly installed?"
    exit 1
fi

log_info "  → Injecting custom sources into hyprland.conf..."

# Inject marker and custom source lines
inject_source "$HYPRLAND_CONF" "$MARKER"

# Inject source lines for custom configs in custom/ directory
CUSTOM_DIR="$TARGET_HYPR/custom"
if [[ -d "$CUSTOM_DIR" ]]; then
    CUSTOM_COUNT=0
    for conf in "$CUSTOM_DIR"/*.conf; do
        if [[ -f "$conf" ]] || [[ -L "$conf" ]]; then
            SOURCE_LINE="source = $conf"
            inject_source "$HYPRLAND_CONF" "$SOURCE_LINE"
            CUSTOM_COUNT=$((CUSTOM_COUNT + 1))
        fi
    done
    log_success "  ✓ Injected $CUSTOM_COUNT custom config sources"
fi

log_success "Hyprland patches applied successfully"
log_info "Base configs: $TARGET_HYPR"
log_info "Custom configs: $CUSTOM_DIR (from omarchy_custom package)"
log_info "Reload Hyprland with: hyprctl reload"
