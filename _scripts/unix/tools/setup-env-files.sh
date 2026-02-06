#!/usr/bin/env bash
# =============================================================================
# Environment Files Setup Script
# =============================================================================
# This script helps set up local environment files from templates
# Creates local copies of sample files that you can edit with your credentials
# =============================================================================

set -euo pipefail

# Get script directory and dotfiles root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Source Unix libraries
source "$DOTFILES_ROOT/_scripts/unix/lib/init.sh"

# =============================================================================
# Functions
# =============================================================================

setup_zsh_env() {
    log_header "Setting up Zsh environment files"

    # Setup main .envrc
    if [[ -f "$HOME/.envrc" ]]; then
        log_warning "~/.envrc already exists"
        read -p "Do you want to backup and recreate it? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mv "$HOME/.envrc" "$HOME/.envrc.backup.$(date +%Y%m%d-%H%M%S)"
            log_info "Backed up existing .envrc"
        else
            log_info "Skipping .envrc setup"
            return 0
        fi
    fi

    # Copy main sample file
    cp "$DOTFILES_ROOT/zsh/.envrc.sample" "$HOME/.envrc"
    log_success "Created ~/.envrc from template"
    chmod 600 "$HOME/.envrc"

    # Setup private .private.envrc
    if [[ ! -f "$HOME/.private.envrc" ]]; then
        cp "$DOTFILES_ROOT/zsh/.private.envrc.sample" "$HOME/.private.envrc"
        log_success "Created ~/.private.envrc from template"
        chmod 600 "$HOME/.private.envrc"
    else
        log_info "~/.private.envrc already exists (keeping it)"
    fi

    echo ""
    log_info "Please edit both files with your actual values:"
    log_info "  nvim ~/.envrc          # Basic config (USER_FULLNAME, USER_EMAIL, PC_TYPE)"
    log_info "  nvim ~/.private.envrc  # Secrets (API keys, passwords, tokens)"
    echo ""
    log_info "Then allow direnv to load it:"
    log_info "  direnv allow ~"
}

setup_nushell_env() {
    log_header "Setting up Nushell environment files"

    local env_local="$HOME/.config/nushell/env.local.nu"
    local env_private="$HOME/.config/nushell/env.private.nu"

    # Setup main env.local.nu
    if [[ -f "$env_local" ]]; then
        log_warning "$env_local already exists"
        read -p "Do you want to backup and recreate it? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mv "$env_local" "$env_local.backup.$(date +%Y%m%d-%H%M%S)"
            log_info "Backed up existing env.local.nu"
        else
            log_info "Skipping env.local.nu setup"
            return 0
        fi
    fi

    # Copy main sample file
    mkdir -p "$HOME/.config/nushell"
    cp "$DOTFILES_ROOT/nushell/.config/nushell/env.nu.sample" "$env_local"
    log_success "Created $env_local from template"
    chmod 600 "$env_local"

    # Setup private env.private.nu
    if [[ ! -f "$env_private" ]]; then
        cp "$DOTFILES_ROOT/nushell/.config/nushell/env.private.nu.sample" "$env_private"
        log_success "Created $env_private from template"
        chmod 600 "$env_private"
    else
        log_info "$env_private already exists (keeping it)"
    fi

    echo ""
    log_info "Please edit both files with your actual values:"
    log_info "  nvim $env_local    # Basic config"
    log_info "  nvim $env_private  # Secrets"
}

setup_powershell_env() {
    log_header "Setting up PowerShell environment files"

    local env_local="$HOME/.config/powershell/env.local.ps1"
    local env_private="$HOME/.config/powershell/env.private.ps1"

    # Setup main env.local.ps1
    if [[ -f "$env_local" ]]; then
        log_warning "$env_local already exists"
        read -p "Do you want to backup and recreate it? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mv "$env_local" "$env_local.backup.$(date +%Y%m%d-%H%M%S)"
            log_info "Backed up existing env.local.ps1"
        else
            log_info "Skipping env.local.ps1 setup"
            return 0
        fi
    fi

    # Copy main sample file
    mkdir -p "$HOME/.config/powershell"
    cp "$DOTFILES_ROOT/powershell/.config/powershell/env.ps1.sample" "$env_local"
    log_success "Created $env_local from template"
    chmod 600 "$env_local"

    # Setup private env.private.ps1
    if [[ ! -f "$env_private" ]]; then
        cp "$DOTFILES_ROOT/powershell/.config/powershell/env.private.ps1.sample" "$env_private"
        log_success "Created $env_private from template"
        chmod 600 "$env_private"
    else
        log_info "$env_private already exists (keeping it)"
    fi

    echo ""
    log_info "Please edit both files with your actual values:"
    log_info "  code $env_local    # Basic config"
    log_info "  code $env_private  # Secrets"
}

show_help() {
    cat << EOF
Environment Files Setup Script

USAGE:
    bash setup-env-files.sh [OPTIONS]

OPTIONS:
    --zsh           Setup Zsh environment files
    --nushell       Setup Nushell environment files
    --powershell    Setup PowerShell environment files
    --all           Setup all environment files
    --help          Show this help message

EXAMPLES:
    # Setup all environment files
    bash setup-env-files.sh --all

    # Setup only Zsh
    bash setup-env-files.sh --zsh

    # Setup Nushell and PowerShell
    bash setup-env-files.sh --nushell --powershell

EOF
}

# =============================================================================
# Main
# =============================================================================

main() {
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi

    log_header "Environment Files Setup"
    echo ""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --zsh)
                setup_zsh_env
                ;;
            --nushell)
                setup_nushell_env
                ;;
            --powershell)
                setup_powershell_env
                ;;
            --all)
                setup_zsh_env
                echo ""
                setup_nushell_env
                echo ""
                setup_powershell_env
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done

    echo ""
    log_success "Environment files setup complete!"
    echo ""
    log_info "Next steps:"
    log_info "  1. Edit the created files with your actual credentials"
    log_info "  2. Restart your shell or reload your profile"
    log_info "  3. Run verification commands to check if variables are loaded"
    echo ""
    log_info "For detailed instructions, see: $DOTFILES_ROOT/ENV_SETUP_GUIDE.md"
}

main "$@"
