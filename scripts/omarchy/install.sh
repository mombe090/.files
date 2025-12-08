#!/usr/bin/env bash
# Main entry point for Omarchy dotfiles patches
# Usage: ./install.sh [--dry-run] [--force]

set -eEuo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Options
DRY_RUN=false
FORCE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        -h|--help)
            cat <<EOF
╔═══════════════════════════════════════════════════════════╗
║      Omarchy Dotfiles Patches - Installation              ║
╚═══════════════════════════════════════════════════════════╝

Apply custom dotfiles patches to Omarchy installation.

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --dry-run    Show what would be done without making changes
    --force      Skip confirmations
    -h, --help   Show this help message

EXAMPLES:
    $0                  # Normal installation with confirmations
    $0 --dry-run        # Preview changes
    $0 --force          # Install without prompts

STRATEGY:
    • Inject source lines into Omarchy configs
    • Create custom/ directories for your configs
    • Idempotent - safe to run multiple times
    • Automatic backups before changes

LOGS:
    ~/.local/state/dotfiles/omarchy-patches.log

BACKUPS:
    ~/.local/state/dotfiles/backups/

EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

export DRY_RUN FORCE DOTFILES_ROOT

# Source helpers
source "$SCRIPT_DIR/helpers/all.sh"

# Initialize
init_logging
init_backup

log_info "╔═══════════════════════════════════════════════════════════╗"
log_info "║      Omarchy Dotfiles Patches - Started                  ║"
log_info "╚═══════════════════════════════════════════════════════════╝"
log_info "Started at: $(date)"
log_info "Dotfiles root: $DOTFILES_ROOT"
log_info "Dry run: $DRY_RUN"
log_info "Force: $FORCE"

# Create comprehensive backup before ANY changes
if [[ "$DRY_RUN" != "true" ]]; then
    log_info "Creating comprehensive backup before applying patches..."
    
    # Backup critical config directories
    BACKUP_TARGETS=(
        "$HOME/.config/hypr/hyprland.conf"
        "$HOME/.config/zsh"
        "$HOME/.zshrc"
        "$HOME/.gitconfig"
    )
    
    for target in "${BACKUP_TARGETS[@]}"; do
        if [[ -e "$target" ]]; then
            backup_file "$target"
        fi
    done
    
    log_success "Backup completed. Backups stored in: $BACKUP_DIR"
else
    log_info "[DRY RUN] Would create comprehensive backup before changes"
fi

# Run phases
run_logged "Preflight checks" bash "$SCRIPT_DIR/preflight/all.sh"
run_logged "Package management" bash "$SCRIPT_DIR/packages/all.sh"
run_logged "Configuration patches" bash "$SCRIPT_DIR/config/all.sh"
run_logged "Theme integration" bash "$SCRIPT_DIR/themes/all.sh"
run_logged "Post-install tasks" bash "$SCRIPT_DIR/post-install/all.sh"

log_success "╔═══════════════════════════════════════════════════════════╗"
log_success "║      Omarchy Dotfiles Patches - Completed!               ║"
log_success "╚═══════════════════════════════════════════════════════════╝"
log_info "Finished at: $(date)"
log_info "Log file: $DOTFILES_LOG_FILE"
log_info ""
log_info "Next steps:"
log_info "  1. Restart your shell: exec zsh"
log_info "  2. Reload Hyprland: hyprctl reload"
log_info "  3. Check logs if issues: cat $DOTFILES_LOG_FILE"
