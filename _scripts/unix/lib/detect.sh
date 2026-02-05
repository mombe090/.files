#!/usr/bin/env bash
# =============================================================================
# OS and System Detection Functions for Unix
# =============================================================================
# This module provides OS detection and system information gathering functions.
#
# Functions:
#   - detect_os: Detect OS type (macos/linux/unknown)
#   - get_distro: Get Linux distribution (ubuntu/debian/fedora/arch/etc)
#   - is_macos: Check if running on macOS
#   - is_linux: Check if running on Linux
#   - get_package_manager: Detect available package manager
#   - is_root: Check if running as root
#   - get_home_dir: Get correct user home directory
# =============================================================================

<#
.SYNOPSIS
    Detect the operating system type.

.OUTPUTS
    String - "macos", "linux", or "unknown"

.EXAMPLE
    OS=$(detect_os)
    if [[ "$OS" == "macos" ]]; then
        # macOS-specific code
    fi
#>
detect_os() {
    case "$OSTYPE" in
        darwin*)  echo "macos" ;;
        linux*)   echo "linux" ;;
        *)        echo "unknown" ;;
    esac
}

<#
.SYNOPSIS
    Get the Linux distribution ID.

.OUTPUTS
    String - Distribution ID (ubuntu/debian/fedora/arch/etc) or "unknown"

.EXAMPLE
    DISTRO=$(get_distro)
    case "$DISTRO" in
        ubuntu|debian) apt-get install ... ;;
        fedora|rhel)   dnf install ... ;;
    esac
#>
get_distro() {
    if [[ -f /etc/os-release ]]; then
        # Source the file and return ID
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

<#
.SYNOPSIS
    Check if running on macOS.

.OUTPUTS
    Boolean - 0 if macOS, 1 otherwise

.EXAMPLE
    if is_macos; then
        brew install package
    fi
#>
is_macos() {
    [[ "$(detect_os)" == "macos" ]]
}

<#
.SYNOPSIS
    Check if running on Linux.

.OUTPUTS
    Boolean - 0 if Linux, 1 otherwise

.EXAMPLE
    if is_linux; then
        apt-get install package
    fi
#>
is_linux() {
    [[ "$(detect_os)" == "linux" ]]
}

<#
.SYNOPSIS
    Detect the available package manager.

.OUTPUTS
    String - "brew", "apt", "dnf", "yum", "pacman", "zypper", or "unknown"

.EXAMPLE
    PM=$(get_package_manager)
    case "$PM" in
        apt) sudo apt-get install ... ;;
        brew) brew install ... ;;
    esac
#>
get_package_manager() {
    local os=$(detect_os)
    
    if [[ "$os" == "macos" ]]; then
        if command -v brew &>/dev/null; then
            echo "brew"
            return 0
        fi
    elif [[ "$os" == "linux" ]]; then
        # Check for common package managers
        if command -v apt-get &>/dev/null; then
            echo "apt"
        elif command -v dnf &>/dev/null; then
            echo "dnf"
        elif command -v yum &>/dev/null; then
            echo "yum"
        elif command -v pacman &>/dev/null; then
            echo "pacman"
        elif command -v zypper &>/dev/null; then
            echo "zypper"
        else
            echo "unknown"
        fi
        return 0
    fi
    
    echo "unknown"
}

<#
.SYNOPSIS
    Check if running as root.

.OUTPUTS
    Boolean - 0 if root, 1 otherwise

.EXAMPLE
    if is_root; then
        echo "Running as root"
    fi
#>
is_root() {
    [[ $EUID -eq 0 ]]
}

<#
.SYNOPSIS
    Get the correct user home directory.

.DESCRIPTION
    Ensures HOME points to the actual current user's home directory.
    Fixes issues with stale HOME after using 'su' without '-'.

.OUTPUTS
    String - User's home directory path

.EXAMPLE
    HOME=$(get_home_dir)
#>
get_home_dir() {
    # Get real home from passwd database
    local real_home
    real_home=$(getent passwd "$(whoami)" | cut -d: -f6)
    
    # Warn if HOME is stale
    if [[ "$HOME" != "$real_home" ]]; then
        log_warning "HOME was $HOME, correcting to $real_home" >&2
    fi
    
    echo "$real_home"
}

<#
.SYNOPSIS
    Ensure HOME environment variable is correct.

.DESCRIPTION
    Corrects HOME if it's stale (happens with 'su' without '-').
    This function modifies the HOME environment variable directly.

.EXAMPLE
    ensure_home_correct
#>
ensure_home_correct() {
    local real_home
    real_home=$(getent passwd "$(whoami)" | cut -d: -f6)
    
    if [[ "$HOME" != "$real_home" ]]; then
        export HOME="$real_home"
    fi
}
