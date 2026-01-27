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

    if grep -q 'mise activate' "$zshrc" 2>/dev/null; then
        log_warn "mise already configured in ~/.zshrc"
        return 0
    fi

    log_info "Adding mise to ~/.zshrc..."
    cat >> "$zshrc" << 'EOF'

# ===== MISE CONFIGURATION =====
eval "$(mise activate zsh)"
EOF

    log_info "Shell configured"
}

# ===== MAIN =====
main() {
    log_info "Installing mise for dotfiles"

    install_mise
    configure_shell

    log_info "✓ Done! Next steps:"
    echo "  1. source ~/.zshrc"
    echo "  2. cd $DOTFILES_ROOT && mise install"
    echo "  3. mise list"
}

main "$@"
