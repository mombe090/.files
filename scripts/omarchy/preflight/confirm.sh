#!/usr/bin/env bash
# User confirmation before applying patches

PREFLIGHT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$PREFLIGHT_DIR/.." && pwd)"

# Source helpers
source "$SCRIPT_DIR/helpers/all.sh"

if [[ "$FORCE" == "true" ]] || [[ "$DRY_RUN" == "true" ]]; then
    log_info "Force/Dry-run mode: skipping confirmation"
    exit 0
fi

# Check if running non-interactively
if [[ ! -t 0 ]]; then
    log_warn "Non-interactive mode detected, auto-confirming"
    exit 0
fi

cat <<EOF

╔═══════════════════════════════════════════════════════════╗
║      Omarchy Dotfiles Patches - Confirmation              ║
╚═══════════════════════════════════════════════════════════╝

This script will:
  • Stow hypr configs (custom configs will be symlinked)
  • Stow themes (themes will be symlinked)
  • Inject custom source lines into Zsh configs
  • Install/remove packages (if configured)
  • Backup existing configurations first

Backups will be created in: $BACKUP_DIR
Log file: $DOTFILES_LOG_FILE

EOF

log_info "Press 'y' to continue or 'n' to abort..."
read -p "Continue? (y/N) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Aborted by user"
    exit 1
fi

log_success "User confirmed, proceeding..."
