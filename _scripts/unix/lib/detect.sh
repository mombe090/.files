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

detect_os() {
    case "$OSTYPE" in
        darwin*)  echo "macos" ;;
        linux*)   echo "linux" ;;
        *)        echo "unknown" ;;
    esac
}

get_distro() {
    if [[ -f /etc/os-release ]]; then
        # Source the file and return ID
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

is_macos() {
    [[ "$(detect_os)" == "macos" ]]
}

is_linux() {
    [[ "$(detect_os)" == "linux" ]]
}

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

is_root() {
    [[ $EUID -eq 0 ]]
}

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

ensure_home_correct() {
    local real_home
    real_home=$(getent passwd "$(whoami)" | cut -d: -f6)

    if [[ "$HOME" != "$real_home" ]]; then
        export HOME="$real_home"
    fi
}
