#!/usr/bin/env bash
# Install mise version manager and configure shell integration
#
# Usage:
#   install-mise.sh [OPTIONS]
#
# Options:
#   --global, -g    Install to /usr/local/bin for all users (requires root/sudo)
#   --user, -u      Install to ~/.local/bin (current user only) — default
#   --help, -h      Show this help message
#
# Default behavior (no flag):
#   - Installs to ~/.local/bin (current user only)
#   - Use --global to install to /usr/local/bin for all users
set -e

# Path resolution - Script is at: _scripts/unix/installers/ — 3 levels up to repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Source Unix libraries
source "$DOTFILES_ROOT/_scripts/unix/lib/init.sh"

# ===== PARSE ARGUMENTS =====
MISE_SCOPE="user"  # user (default) | global

while [[ $# -gt 0 ]]; do
    case "$1" in
        --global|-g)
            MISE_SCOPE="global"
            shift
            ;;
        --user|-u)
            MISE_SCOPE="user"
            shift
            ;;
        --help|-h)
            cat << 'EOF'
install-mise.sh - Install mise version manager

USAGE:
    bash install-mise.sh [OPTIONS]

OPTIONS:
    --global, -g    Install to /usr/local/bin for all users (requires root/sudo)
    --user, -u      Install to ~/.local/bin (current user only)
    --help, -h      Show this help message

DEFAULT BEHAVIOR (no flag):
    Installs to ~/.local/bin (current user only).
    Use --global to install system-wide for all users.
EOF
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# ===== INSTALL MISE =====
install_mise() {
    if command -v mise &> /dev/null; then
        log_warn "mise already installed ($(mise --version))"
        return 0
    fi

    log_info "Installing mise..."

    case "$MISE_SCOPE" in
        global)
            # Global install — requires root or passwordless sudo
            if [[ $EUID -eq 0 ]]; then
                log_info "Installing globally to /usr/local/bin (running as root)..."
                curl https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh
                export PATH="/usr/local/bin:$PATH"
            elif sudo -n true 2>/dev/null; then
                log_info "Installing globally to /usr/local/bin (via sudo)..."
                curl https://mise.run | sudo MISE_INSTALL_PATH=/usr/local/bin/mise sh
                export PATH="/usr/local/bin:$PATH"
            else
                log_error "--global requested but no root or passwordless sudo access"
                log_info "Run as root, grant passwordless sudo, or omit --global for user install"
                return 1
            fi
            ;;
        user|*)
            # Default: user-level install
            log_info "Installing to ~/.local/bin (current user only)..."
            curl https://mise.run | sh
            export PATH="$HOME/.local/bin:$PATH"
            ;;
    esac

    log_info "mise installed"
}

# ===== CONFIGURE SHELL =====
configure_shell() {
    local zshrc="$HOME/.zshrc"
    local bashrc="$HOME/.bashrc"

    # Configure zsh
    if [[ -f "$zshrc" ]]; then
        if grep -q 'mise activate' "$zshrc" 2>/dev/null; then
            log_warn "mise already configured in ~/.zshrc"
        else
            log_info "Adding mise to ~/.zshrc..."
            cat >> "$zshrc" << 'EOF'

# ===== MISE CONFIGURATION =====
export MISE_DATA_DIR="$HOME/.local/share/mise"
export MISE_CACHE_DIR="$HOME/.cache/mise"
eval "$(mise activate zsh)"
EOF
        fi
    fi

    # Configure bash
    if [[ -f "$bashrc" ]]; then
        if grep -q 'mise activate' "$bashrc" 2>/dev/null; then
            log_warn "mise already configured in ~/.bashrc"
        else
            log_info "Adding mise to ~/.bashrc..."
            cat >> "$bashrc" << 'EOF'

# ===== MISE CONFIGURATION =====
export MISE_DATA_DIR="$HOME/.local/share/mise"
export MISE_CACHE_DIR="$HOME/.cache/mise"
eval "$(mise activate bash)"
EOF
        fi
    fi

    log_info "Shell configured"
}

# ===== MAIN =====
main() {
    log_info "Installing mise for dotfiles"

    install_mise
    configure_shell

    log_info "✓ Done! Next steps:"
    echo "  1. source ~/.zshrc (or ~/.bashrc)"
    echo "  2. cd $DOTFILES_ROOT && mise install"
    echo "  3. mise list"
}

main "$@"
