#!/usr/bin/env bash
# Theme integration and stow management

THEMES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$THEMES_DIR/.." && pwd)"

# Source helpers
source "$SCRIPT_DIR/helpers/all.sh"

log_info "Theme integration..."

DOTFILES_THEMES="$DOTFILES_ROOT/themes"
TARGET_CONFIG="$HOME/.config/omarchy"

if [[ ! -d "$DOTFILES_THEMES" ]]; then
    log_warn "Themes directory not found: $DOTFILES_THEMES"
    log_info "Skipping theme integration"
    exit 0
fi

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would stow themes from: $DOTFILES_THEMES"
    log_info "[DRY RUN] Would create symlinks in: $TARGET_CONFIG"
    exit 0
fi

# Stow the themes directory
cd "$DOTFILES_ROOT" || {
    log_error "Failed to cd to: $DOTFILES_ROOT"
    exit 1
}

log_info "Stowing themes..."

# Check if stow is available
if ! command -v stow &> /dev/null; then
    log_error "stow command not found. Please install GNU Stow."
    exit 1
fi

# Unstow first (in case of previous stow)
stow -D themes 2>/dev/null || true

# Stow themes
STOW_OUTPUT=$(stow -v themes 2>&1)
STOW_EXIT=$?

if [[ -n "$LOG_FILE" ]]; then
    echo "$STOW_OUTPUT" | tee -a "$LOG_FILE"
else
    echo "$STOW_OUTPUT"
fi

if [[ $STOW_EXIT -eq 0 ]]; then
    log_success "Themes stowed successfully"
    log_info "Custom themes available in: $TARGET_CONFIG/themes"
else
    log_error "Failed to stow themes"
    log_error "$STOW_OUTPUT"
    exit 1
fi

# List available themes
AVAILABLE_THEMES=$(ls -1 "$DOTFILES_THEMES/.config/omarchy/themes" 2>/dev/null)
if [[ -n "$AVAILABLE_THEMES" ]]; then
    log_info "Available custom themes:"
    while IFS= read -r theme; do
        log_info "  - $theme"
    done <<< "$AVAILABLE_THEMES"
fi

log_info "Switch themes with: omarchy theme <theme-name>"
