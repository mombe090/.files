#!/usr/bin/env bash
# Zsh configuration patches using injection strategy

ZSH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$ZSH_DIR/.." && pwd)"

# Source helpers
source "$SCRIPT_DIR/helpers/all.sh"

log_info "Applying Zsh patches..."

DOTFILES_ZSH="$DOTFILES_ROOT/zsh/.config/zsh"
TARGET_ZSH="$HOME/.config/zsh"
CUSTOM_DIR="$TARGET_ZSH/custom"
ZSHRC="$HOME/.zshrc"
MARKER="# === Custom Dotfiles Overrides ==="

if [[ ! -d "$DOTFILES_ZSH" ]]; then
    log_warn "Zsh dotfiles not found: $DOTFILES_ZSH"
    log_info "Skipping Zsh patches"
    exit 0
fi

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would apply Zsh patches"
    exit 0
fi

# Create custom directory
mkdir -p "$CUSTOM_DIR"

# Copy all zsh files from dotfiles to custom directory
if [[ -d "$DOTFILES_ZSH" ]]; then
    cp -r "$DOTFILES_ZSH"/* "$CUSTOM_DIR/"
    log_success "Copied Zsh configs to: $CUSTOM_DIR"
fi

# Inject source lines into .zshrc
inject_source "$ZSHRC" "" "$MARKER"

# Source all custom zsh files
for zsh_file in "$CUSTOM_DIR"/*.zsh; do
    if [[ -f "$zsh_file" ]]; then
        SOURCE_LINE="[[ -f \"$zsh_file\" ]] && source \"$zsh_file\""
        inject_source "$ZSHRC" "$SOURCE_LINE"
    fi
done

log_success "Zsh patches applied successfully"
log_info "Restart shell with: exec zsh"
