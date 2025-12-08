#!/usr/bin/env bash
# Backup utilities for safe configuration patching

BACKUP_DIR="$HOME/.local/state/dotfiles/backups"

# Initialize backup directory
init_backup() {
    mkdir -p "$BACKUP_DIR"
}

# Backup a file or directory
backup_file() {
    local target="$1"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    
    if [[ -e "$target" ]]; then
        local backup_name
        backup_name="$(basename "$target").backup_$timestamp"
        local backup_path="$BACKUP_DIR/$backup_name"
        
        cp -r "$target" "$backup_path"
        log_info "Backed up: $target -> $backup_path"
    fi
}

# Restore from backup
restore_backup() {
    local backup_path="$1"
    local target="$2"
    
    if [[ -e "$backup_path" ]]; then
        rm -rf "$target"
        cp -r "$backup_path" "$target"
        log_success "Restored: $target from backup"
    else
        log_error "Backup not found: $backup_path"
        return 1
    fi
}

# List available backups
list_backups() {
    ls -lh "$BACKUP_DIR"
}
