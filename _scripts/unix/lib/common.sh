#!/usr/bin/env bash
# =============================================================================
# Common Utility Functions for Unix Scripts
# =============================================================================
# This module provides utility functions for Unix shell scripts.
#
# Functions:
#   - has_command: Check if a command exists
#   - retry: Retry a command with backoff
#   - backup_file: Create a backup of a file
#   - confirm_prompt: Ask for user confirmation
#   - safe_mkdir: Create directories safely
#   - check_internet: Check internet connectivity
# =============================================================================

has_command() {
    command -v "$1" &>/dev/null
}

retry() {
    local max_attempts=3
    local attempt=1
    local delay=1

    # If first arg is a number, use it as max_attempts
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        max_attempts=$1
        shift
    fi

    local cmd="$@"

    while [[ $attempt -le $max_attempts ]]; do
        if $cmd; then
            return 0
        fi

        if [[ $attempt -lt $max_attempts ]]; then
            log_warning "Attempt $attempt/$max_attempts failed. Retrying in ${delay}s..." >&2
            sleep $delay
            delay=$((delay * 2))
        fi

        attempt=$((attempt + 1))
    done

    log_error "All $max_attempts attempts failed for: $cmd" >&2
    return 1
}

backup_file() {
    local file="$1"
    local backup_dir="${2:-$(dirname "$file")}"

    if [[ ! -f "$file" ]]; then
        log_warning "File not found, skipping backup: $file" >&2
        return 1
    fi

    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local basename=$(basename "$file")
    local backup_path="$backup_dir/${basename}.backup_${timestamp}"

    # Create backup directory if needed
    mkdir -p "$backup_dir"

    # Create backup
    cp -a "$file" "$backup_path"
    log_success "Backup created: $backup_path" >&2

    echo "$backup_path"
}

confirm_prompt() {
    local message="$1"
    local default="${2:-n}"
    local prompt

    if [[ "$default" == "y" ]]; then
        prompt="$message [Y/n]: "
    else
        prompt="$message [y/N]: "
    fi

    read -p "$prompt" -r response
    response=${response:-$default}

    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

safe_mkdir() {
    local path="$1"

    if [[ -d "$path" ]]; then
        log_info "Directory already exists: $path" >&2
        return 0
    fi

    if mkdir -p "$path" 2>/dev/null; then
        log_success "Created directory: $path" >&2
        return 0
    else
        log_error "Failed to create directory: $path" >&2
        return 1
    fi
}

check_internet() {
    local host="${1:-8.8.8.8}"

    # Try ping first
    if ping -c 1 -W 2 "$host" &>/dev/null; then
        return 0
    fi

    # Fallback to curl
    if has_command curl && curl -sf --max-time 2 "http://$host" &>/dev/null; then
        return 0
    fi

    return 1
}

get_dotfiles_root() {
    local levels_up="${1:-1}"
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
    local path="$script_dir"

    for ((i=0; i<levels_up; i++)); do
        path="$path/.."
    done

    cd "$path" && pwd
}
