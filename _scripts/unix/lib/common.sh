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

<#
.SYNOPSIS
    Check if a command exists in PATH.

.PARAMETER cmd
    The command name to check.

.OUTPUTS
    Boolean - 0 if command exists, 1 otherwise

.EXAMPLE
    if has_command git; then
        echo "Git is installed"
    fi
#>
has_command() {
    command -v "$1" &>/dev/null
}

<#
.SYNOPSIS
    Retry a command multiple times with exponential backoff.

.PARAMETER max_attempts
    Maximum number of retry attempts (default: 3).

.PARAMETER command...
    The command and its arguments to execute.

.OUTPUTS
    Boolean - 0 if command succeeds, 1 if all retries fail

.EXAMPLE
    retry 5 curl -fsSL https://example.com/file.tar.gz
#>
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

<#
.SYNOPSIS
    Create a timestamped backup of a file.

.PARAMETER file
    The file to backup.

.PARAMETER backup_dir
    Optional backup directory (default: same directory as file).

.OUTPUTS
    String - Path to the backup file

.EXAMPLE
    backup_file ~/.zshrc
    backup_file ~/.config/nvim/init.lua ~/.backups/
#>
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

<#
.SYNOPSIS
    Ask for user confirmation.

.PARAMETER message
    The prompt message to display.

.PARAMETER default
    Default answer: "y" or "n" (default: "n").

.OUTPUTS
    Boolean - 0 if user confirms (yes), 1 otherwise (no)

.EXAMPLE
    if confirm_prompt "Continue with installation?"; then
        install_package
    fi
#>
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

<#
.SYNOPSIS
    Create directories safely with error checking.

.PARAMETER path
    The directory path to create.

.OUTPUTS
    Boolean - 0 if successful, 1 otherwise

.EXAMPLE
    safe_mkdir ~/.config/nvim
#>
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

<#
.SYNOPSIS
    Check internet connectivity.

.PARAMETER host
    Host to ping (default: 8.8.8.8 - Google DNS).

.OUTPUTS
    Boolean - 0 if internet is reachable, 1 otherwise

.EXAMPLE
    if check_internet; then
        echo "Internet is available"
    fi
#>
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

<#
.SYNOPSIS
    Get the absolute path of the dotfiles repository root.

.DESCRIPTION
    Resolves the path relative to the calling script's location.

.PARAMETER levels_up
    Number of levels to go up from the script directory (default: 1).

.OUTPUTS
    String - Absolute path to dotfiles root

.EXAMPLE
    # Script is in _scripts/unix/installers/ (3 levels deep)
    DOTFILES_ROOT=$(get_dotfiles_root 3)
#>
get_dotfiles_root() {
    local levels_up="${1:-1}"
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
    local path="$script_dir"
    
    for ((i=0; i<levels_up; i++)); do
        path="$path/.."
    done
    
    cd "$path" && pwd
}
