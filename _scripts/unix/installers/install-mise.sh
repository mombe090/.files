#!/usr/bin/env bash
# Install mise globally and configure shell integration
set -e

# Path resolution - Script is at: _scripts/unix/installers/ — 3 levels up to repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Source Unix libraries
source "$DOTFILES_ROOT/_scripts/unix/lib/init.sh"

# ===== INSTALL MISE =====
install_mise() {
    if command -v mise &> /dev/null; then
        log_warn "mise already installed ($(mise --version))"
        return 0
    fi

    log_info "Installing mise..."

    # Try global installation (requires sudo or root)
    if [[ $EUID -eq 0 ]]; then
        # Running as root, no sudo needed
        log_info "Installing globally to /usr/local/bin (running as root)..."
        curl https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh
        export PATH="/usr/local/bin:$PATH"
    elif sudo -n true 2>/dev/null; then
        # Can use sudo without password
        log_info "Installing globally to /usr/local/bin..."
        curl https://mise.run | sudo MISE_INSTALL_PATH=/usr/local/bin/mise sh
        export PATH="/usr/local/bin:$PATH"
    else
        # No sudo access
        log_warn "No sudo access, installing to ~/.local/bin..."
        curl https://mise.run | sh
        export PATH="$HOME/.local/bin:$PATH"
    fi

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
