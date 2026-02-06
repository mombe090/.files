#!/usr/bin/env bash
# Git configuration patches using injection strategy

GIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$GIT_DIR/.." && pwd)"

# Source helpers
source "$SCRIPT_DIR/helpers/all.sh"

log_info "Applying Git patches..."

DOTFILES_GIT="$DOTFILES_ROOT/git"
TARGET_GITCONFIG="$HOME/.gitconfig"
CUSTOM_GITCONFIG="$HOME/.config/git/custom.gitconfig"
MARKER="# === Custom Dotfiles Overrides ==="

if [[ ! -d "$DOTFILES_GIT" ]]; then
    log_warn "Git dotfiles not found: $DOTFILES_GIT"
    log_info "Skipping Git patches"
    exit 0
fi

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would apply Git patches"
    exit 0
fi

# Create custom gitconfig directory
mkdir -p "$(dirname "$CUSTOM_GITCONFIG")"

# Copy gitconfig from dotfiles
if [[ -f "$DOTFILES_GIT/.gitconfig" ]]; then
    cp "$DOTFILES_GIT/.gitconfig" "$CUSTOM_GITCONFIG"
    log_success "Copied custom gitconfig"
fi

# Inject include directive into main gitconfig
if [[ -f "$TARGET_GITCONFIG" ]]; then
    if ! grep -q "\[include\]" "$TARGET_GITCONFIG"; then
        backup_file "$TARGET_GITCONFIG"
        echo "" >> "$TARGET_GITCONFIG"
        echo "$MARKER" >> "$TARGET_GITCONFIG"
        echo "[include]" >> "$TARGET_GITCONFIG"
        echo "    path = $CUSTOM_GITCONFIG" >> "$TARGET_GITCONFIG"
        log_success "Injected custom gitconfig include"
    else
        log_info "Git include section already exists"
    fi
fi

# Copy global gitignore
if [[ -f "$DOTFILES_GIT/.gitignore_global" ]]; then
    cp "$DOTFILES_GIT/.gitignore_global" "$HOME/.gitignore_global"
    log_success "Copied global gitignore"
fi

log_success "Git patches applied successfully"
