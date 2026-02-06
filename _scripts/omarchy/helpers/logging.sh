#!/usr/bin/env bash
# Logging utilities for Omarchy dotfiles patches

DOTFILES_LOG_DIR="$HOME/.local/state/dotfiles"
DOTFILES_LOG_FILE="$DOTFILES_LOG_DIR/omarchy-patches.log"

# Initialize logging
init_logging() {
    mkdir -p "$DOTFILES_LOG_DIR"
    touch "$DOTFILES_LOG_FILE"
}

# Log functions with timestamps
log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $*" | tee -a "$DOTFILES_LOG_FILE"
}

log_success() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $*" | tee -a "$DOTFILES_LOG_FILE"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $*" | tee -a "$DOTFILES_LOG_FILE" >&2
}

log_warn() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $*" | tee -a "$DOTFILES_LOG_FILE"
}

# Run command with logging
run_logged() {
    local description="$1"
    shift

    log_info "Starting: $description"

    if "$@" >> "$DOTFILES_LOG_FILE" 2>&1; then
        log_success "Completed: $description"
        return 0
    else
        log_error "Failed: $description"
        return 1
    fi
}
