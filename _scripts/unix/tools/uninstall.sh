#!/usr/bin/env bash
# Uninstall dotfiles (remove symlinks created by stow)
set -e

# Path resolution - Script is at: _scripts/unix/tools/ — 3 levels up to repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Source Unix libraries
source "$DOTFILES_ROOT/_scripts/unix/lib/init.sh"

# ===== CONFIGURATION =====
STOW_PACKAGES=(
    "zsh"
    "git"
    "nvim"
    "starship"
    "alacritty"
    "ghostty"
    "bat"
    "delta"
    "mise"
    "zellij"
    "hypr"
    "omarchy"
    "nushell"
    "opencode"
)

# ===== CHECK STOW =====
check_stow() {
    if ! command -v stow &> /dev/null; then
        log_error "GNU Stow not found. Cannot uninstall."
        log_info "If you manually created symlinks, remove them manually."
        exit 1
    fi
}

# ===== UNSTOW PACKAGES =====
unstow_packages() {
    log_info "Removing symlinks created by stow..."
    echo ""
    
    cd "$DOTFILES_ROOT"
    
    local unstowed_count=0
    local skipped_count=0
    
    for package in "${STOW_PACKAGES[@]}"; do
        if [[ -d "$package" ]]; then
            log_info "Unstowing $package..."
            if stow -D -v -t "$HOME" "$package" 2>&1 | grep -v "BUG in find_stowed_path"; then
                ((unstowed_count++))
            fi
        else
            log_warn "Package $package not found, skipping"
            ((skipped_count++))
        fi
    done
    
    echo ""
    log_success "Unstow complete"
    echo "  - Packages unstowed: $unstowed_count"
    echo "  - Packages skipped: $skipped_count"
}

# ===== RESTORE BACKUP =====
restore_backup() {
    if [[ ! -f "$HOME/.dotfiles-backup-location" ]]; then
        log_info "No backup location found"
        return 0
    fi
    
    local backup_dir=$(cat "$HOME/.dotfiles-backup-location")
    
    if [[ ! -d "$backup_dir" ]]; then
        log_warn "Backup directory not found: $backup_dir"
        return 0
    fi
    
    echo ""
    read -p "Restore backup from $backup_dir? [y/N]: " restore
    
    if [[ "$restore" =~ ^[Yy]$ ]]; then
        log_info "Restoring backup..."
        cp -r "$backup_dir"/* "$HOME/" 2>/dev/null || true
        log_success "Backup restored"
    else
        log_info "Backup not restored"
        log_info "To restore manually: cp -r $backup_dir/* ~/"
    fi
}

# ===== CLEAN ZINIT =====
clean_zinit() {
    local zinit_dir="$HOME/.local/share/zinit"
    
    if [[ ! -d "$zinit_dir" ]]; then
        return 0
    fi
    
    echo ""
    read -p "Remove Zinit and plugins? [y/N]: " clean
    
    if [[ "$clean" =~ ^[Yy]$ ]]; then
        log_info "Removing Zinit..."
        rm -rf "$zinit_dir"
        log_success "Zinit removed"
    else
        log_info "Zinit kept at: $zinit_dir"
    fi
}

# ===== MAIN =====
main() {
    echo ""
    echo -e "${BOLD}==================================${NC}"
    echo -e "${BOLD}   Dotfiles Uninstall Utility${NC}"
    echo -e "${BOLD}==================================${NC}"
    echo ""
    
    log_warn "This will remove all symlinks created by stow"
    echo ""
    read -p "Continue with uninstall? [y/N]: " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Uninstall cancelled"
        exit 0
    fi
    
    echo ""
    
    check_stow
    unstow_packages
    restore_backup
    clean_zinit
    
    echo ""
    echo -e "${GREEN}==================================${NC}"
    echo -e "${GREEN}✓ Uninstall Complete!${NC}"
    echo -e "${GREEN}==================================${NC}"
    echo ""
    echo "Your dotfiles symlinks have been removed."
    echo ""
    echo "Note: The following were NOT removed:"
    echo "  - Installed packages (mise, homebrew packages, etc.)"
    echo "  - Shell configurations in ~/.zshrc (if modified)"
    echo "  - The dotfiles repository itself ($DOTFILES_ROOT)"
    echo ""
    echo "To completely remove everything:"
    echo "  1. Uninstall packages manually (brew uninstall, mise uninstall)"
    echo "  2. Remove the dotfiles repository: rm -rf $DOTFILES_ROOT"
    echo ""
}

# ===== HELP =====
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    echo "Usage: $0"
    echo ""
    echo "Uninstall dotfiles by removing symlinks created by GNU Stow."
    echo "Optionally restore backups created during installation."
    echo ""
    echo "This script will:"
    echo "  1. Remove all symlinks created by stow"
    echo "  2. Offer to restore from backup (if available)"
    echo "  3. Offer to remove Zinit plugins"
    echo ""
    echo "Note: Installed packages are NOT removed."
    exit 0
fi

main "$@"
