#!/usr/bin/env bash
# Backup existing dotfiles before installation
set -e

# Path resolution - Script is at: _scripts/unix/tools/ — 3 levels up to repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Source Unix libraries
source "$DOTFILES_ROOT/_scripts/unix/lib/init.sh"

# ===== CONFIGURATION =====
BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)}"

# Files and directories to backup
BACKUP_TARGETS=(
    "$HOME/.zshrc"
    "$HOME/.bashrc"
    "$HOME/.bash_profile"
    "$HOME/.profile"
    "$HOME/.gitconfig"
    "$HOME/.gitignore_global"
    "$HOME/.config/nvim"
    "$HOME/.config/alacritty"
    "$HOME/.config/ghostty"
    "$HOME/.config/starship.toml"
    "$HOME/.config/zsh"
    "$HOME/.config/bat"
    "$HOME/.config/delta"
    "$HOME/.config/zellij"
    "$HOME/.config/k9s"
    "$HOME/.config/hypr"
    "$HOME/.config/omarchy"
    "$HOME/.local/share/zinit"
)

# ===== BACKUP FUNCTION =====
backup_file() {
    local source="$1"
    local relative_path="${source#$HOME/}"
    local backup_path="$BACKUP_DIR/$relative_path"

    # Skip if source doesn't exist
    if [[ ! -e "$source" ]]; then
        return 0
    fi

    # Skip if it's already a symlink (managed by stow)
    if [[ -L "$source" ]]; then
        log_info "Skipping symlink: $source"
        return 0
    fi

    # Create backup directory
    mkdir -p "$(dirname "$backup_path")"

    # Backup the file/directory
    if cp -r "$source" "$backup_path" 2>/dev/null; then
        log_success "Backed up: $relative_path"
        return 0
    else
        log_warn "Failed to backup: $relative_path"
        return 1
    fi
}

# ===== MAIN BACKUP PROCESS =====
main() {
    echo ""
    echo -e "${BOLD}==================================${NC}"
    echo -e "${BOLD}   Dotfiles Backup Utility${NC}"
    echo -e "${BOLD}==================================${NC}"
    echo ""

    log_info "Backup destination: $BACKUP_DIR"
    echo ""

    local backed_up_count=0
    local skipped_count=0

    for target in "${BACKUP_TARGETS[@]}"; do
        if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
            if backup_file "$target"; then
                ((backed_up_count++))
            fi
        else
            ((skipped_count++))
        fi
    done

    echo ""

    if [[ $backed_up_count -eq 0 ]]; then
        log_info "No files needed backup (all are symlinks or don't exist)"
        # Don't create empty backup directory
        rm -rf "$BACKUP_DIR" 2>/dev/null || true
    else
        log_success "Backup complete!"
        echo ""
        echo "Summary:"
        echo "  - Files backed up: $backed_up_count"
        echo "  - Files skipped: $skipped_count"
        echo "  - Backup location: $BACKUP_DIR"
        echo ""

        # Save backup location for reference
        echo "$BACKUP_DIR" > "$HOME/.dotfiles-backup-location"

        echo "To restore from backup:"
        echo "  cp -r $BACKUP_DIR/* ~/"
        echo ""
    fi
}

# ===== HELP =====
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    echo "Usage: $0 [BACKUP_DIR]"
    echo ""
    echo "Backup existing dotfiles before installing new ones."
    echo ""
    echo "Arguments:"
    echo "  BACKUP_DIR    Custom backup directory (default: ~/.dotfiles-backup-TIMESTAMP)"
    echo ""
    echo "Environment Variables:"
    echo "  BACKUP_DIR    Set custom backup directory"
    echo ""
    echo "Examples:"
    echo "  $0"
    echo "  $0 ~/my-backup"
    echo "  BACKUP_DIR=~/my-backup $0"
    exit 0
fi

# Custom backup directory from argument
if [[ -n "$1" ]]; then
    BACKUP_DIR="$1"
fi

main "$@"
