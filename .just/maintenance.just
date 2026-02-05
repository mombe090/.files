# =============================================================================
# maintenance.just - Update, backup, and cleanup recipes
# =============================================================================

# Update everything (git pull + packages + mise + restow)
[unix]
update:
    @just _log_step "Updating dotfiles..."
    @echo ""
    @just _log_info "1/5 Pulling latest changes..."
    @git pull
    @echo ""
    @just _log_info "2/5 Updating system packages..."
    @just packages_update || true
    @echo ""
    @just _log_info "3/5 Upgrading mise tools..."
    @mise upgrade || true
    @echo ""
    @just _log_info "4/5 Updating JavaScript packages..."
    @{{installers}}/install-js-packages.sh --update || true
    @echo ""
    @just _log_info "5/5 Restowing configurations..."
    @just restow
    @echo ""
    @just _log_success "Update complete!"

# Sync dotfiles (quick git pull + restow)
[unix]
sync:
    @just _log_step "Syncing dotfiles..."
    @git pull
    @just restow
    @just _log_success "Sync complete!"

# Create backup of current configurations
[unix]
backup_create:
    @just _log_step "Creating backup..."
    @{{tools}}/backup.sh

# List all backups
[unix]
backup_list:
    @just _log_step "Available backups:"
    @ls -lh ~/.dotfiles-backup-* 2>/dev/null || echo "No backups found"

# Restore backup by timestamp
[unix]
backup_restore TIMESTAMP:
    #!/usr/bin/env bash
    set -euo pipefail

    BACKUP_DIR="$HOME/.dotfiles-backup-{{TIMESTAMP}}"

    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "{{color_red}}[ERROR]{{color_reset}} Backup not found: $BACKUP_DIR"
        echo ""
        echo "Available backups:"
        ls -1d ~/.dotfiles-backup-* 2>/dev/null || echo "  None"
        exit 1
    fi

    echo -e "{{color_yellow}}[WARN]{{color_reset}} This will restore from: $BACKUP_DIR"
    read -p "Are you sure? [y/N] " confirm
    [ "$confirm" = "y" ] || exit 0

    echo -e "{{color_blue}}[STEP]{{color_reset}} Restoring backup..."
    cp -r "$BACKUP_DIR"/* "$HOME/"
    echo -e "{{color_green}}[✓]{{color_reset}} Backup restored"

# Clean temporary files and old backups
[unix]
clean:
    @just _log_step "Cleaning up..."
    @find ~/.dotfiles-backup-* -type d -mtime +30 -exec rm -rf {} \; 2>/dev/null || true
    @just _log_success "Cleanup complete!"

# Uninstall dotfiles and restore backups
[unix]
uninstall:
    #!/usr/bin/env bash
    set -euo pipefail

    echo -e "{{color_yellow}}[WARN]{{color_reset}} This will remove dotfiles and restore backups"
    read -p "Are you sure? [y/N] " confirm
    [ "$confirm" = "y" ] || exit 0

    {{tools}}/uninstall.sh
