#!/usr/bin/env bash
# Install mise globally and configure shell integration
set -e

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ===== INSTALL MISE =====
install_mise() {
    if command -v mise &> /dev/null; then
        log_warn "mise already installed ($(mise --version))"
        return 0
    fi

    log_info "Installing mise..."

    # Try global installation (requires sudo)
    if [[ $EUID -eq 0 ]] || sudo -n true 2>/dev/null; then
        log_info "Installing globally to /usr/local/bin..."
        curl https://mise.run | sudo MISE_INSTALL_PATH=/usr/local/bin/mise sh
        export PATH="/usr/local/bin:$PATH"
    else
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
export MISE_HOME="$HOME/.local/share/mise"
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
export MISE_HOME="$HOME/.local/share/mise"
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
