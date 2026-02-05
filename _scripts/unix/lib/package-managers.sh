#!/usr/bin/env bash
# =============================================================================
# Package Manager Abstraction for Unix
# =============================================================================
# This module provides abstraction for different package managers.
#
# Functions:
#   - install_package: Install a package using the available package manager
#   - check_package_installed: Check if a package is installed
#   - update_packages: Update all packages
#   - install_with_brew: Install using Homebrew (macOS/Linux)
#   - install_with_apt: Install using apt (Debian/Ubuntu)
#   - install_with_dnf: Install using dnf (Fedora/RHEL)
#   - install_with_pacman: Install using pacman (Arch)
# =============================================================================

<#
.SYNOPSIS
    Install a package using the available package manager.

.PARAMETER package_name
    The name of the package to install.

.PARAMETER pm
    Optional: specific package manager to use (brew/apt/dnf/yum/pacman).

.OUTPUTS
    Boolean - 0 if successful, 1 otherwise

.EXAMPLE
    install_package git
    install_package git brew  # Force use of Homebrew
#>
install_package() {
    local package_name="$1"
    local pm="${2:-$(get_package_manager)}"
    
    case "$pm" in
        brew)
            install_with_brew "$package_name"
            ;;
        apt)
            install_with_apt "$package_name"
            ;;
        dnf)
            install_with_dnf "$package_name"
            ;;
        yum)
            install_with_yum "$package_name"
            ;;
        pacman)
            install_with_pacman "$package_name"
            ;;
        *)
            log_error "No supported package manager found"
            return 1
            ;;
    esac
}

<#
.SYNOPSIS
    Check if a package is installed.

.PARAMETER package_name
    The name of the package to check.

.PARAMETER pm
    Optional: specific package manager to use.

.OUTPUTS
    Boolean - 0 if installed, 1 otherwise

.EXAMPLE
    if check_package_installed git; then
        echo "Git is installed"
    fi
#>
check_package_installed() {
    local package_name="$1"
    local pm="${2:-$(get_package_manager)}"
    
    case "$pm" in
        brew)
            brew list "$package_name" &>/dev/null
            ;;
        apt)
            dpkg -l "$package_name" 2>/dev/null | grep -q "^ii"
            ;;
        dnf|yum)
            rpm -q "$package_name" &>/dev/null
            ;;
        pacman)
            pacman -Q "$package_name" &>/dev/null
            ;;
        *)
            log_error "No supported package manager found"
            return 1
            ;;
    esac
}

<#
.SYNOPSIS
    Update all packages using the available package manager.

.PARAMETER pm
    Optional: specific package manager to use.

.OUTPUTS
    Boolean - 0 if successful, 1 otherwise

.EXAMPLE
    update_packages
#>
update_packages() {
    local pm="${1:-$(get_package_manager)}"
    
    log_info "Updating packages with $pm..."
    
    case "$pm" in
        brew)
            brew update && brew upgrade
            ;;
        apt)
            sudo apt-get update && sudo apt-get upgrade -y
            ;;
        dnf)
            sudo dnf upgrade -y
            ;;
        yum)
            sudo yum update -y
            ;;
        pacman)
            sudo pacman -Syu --noconfirm
            ;;
        *)
            log_error "No supported package manager found"
            return 1
            ;;
    esac
}

# =============================================================================
# Package Manager Specific Functions
# =============================================================================

install_with_brew() {
    local package_name="$1"
    
    if ! has_command brew; then
        log_error "Homebrew not installed"
        return 1
    fi
    
    if brew list "$package_name" &>/dev/null; then
        log_warning "$package_name already installed (Homebrew)"
        return 0
    fi
    
    log_info "Installing $package_name with Homebrew..."
    brew install "$package_name"
}

install_with_apt() {
    local package_name="$1"
    
    if ! has_command apt-get; then
        log_error "apt not installed"
        return 1
    fi
    
    if dpkg -l "$package_name" 2>/dev/null | grep -q "^ii"; then
        log_warning "$package_name already installed (apt)"
        return 0
    fi
    
    log_info "Installing $package_name with apt..."
    sudo apt-get install -y "$package_name"
}

install_with_dnf() {
    local package_name="$1"
    
    if ! has_command dnf; then
        log_error "dnf not installed"
        return 1
    fi
    
    if rpm -q "$package_name" &>/dev/null; then
        log_warning "$package_name already installed (dnf)"
        return 0
    fi
    
    log_info "Installing $package_name with dnf..."
    sudo dnf install -y "$package_name"
}

install_with_yum() {
    local package_name="$1"
    
    if ! has_command yum; then
        log_error "yum not installed"
        return 1
    fi
    
    if rpm -q "$package_name" &>/dev/null; then
        log_warning "$package_name already installed (yum)"
        return 0
    fi
    
    log_info "Installing $package_name with yum..."
    sudo yum install -y "$package_name"
}

install_with_pacman() {
    local package_name="$1"
    
    if ! has_command pacman; then
        log_error "pacman not installed"
        return 1
    fi
    
    if pacman -Q "$package_name" &>/dev/null; then
        log_warning "$package_name already installed (pacman)"
        return 0
    fi
    
    log_info "Installing $package_name with pacman..."
    sudo pacman -S --noconfirm "$package_name"
}
