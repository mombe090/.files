#!/usr/bin/env bash
# Install Clawdbot CLI
set -e

# Path resolution - Script is at: _scripts/unix/installers/ — 3 levels up to repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Source Unix libraries
source "$DOTFILES_ROOT/_scripts/unix/lib/init.sh"

# ===== INSTALL CLAWDBOT =====
install_clawdbot() {
    if command -v clawd &> /dev/null; then
        log_warn "clawdbot already installed ($(clawd --version 2>/dev/null || echo 'version unknown'))"
        return 0
    fi

    log_info "Installing Clawdbot..."

    # Check if npm is available
    if ! command -v npm &> /dev/null; then
        log_error "npm not found. Install Node.js first:"
        echo "  Run: ./scripts/install-mise.sh && mise install node"
        exit 1
    fi

    # Install globally with npm
    npm install -g clawdbot

    log_info "clawdbot installed"
}

# ===== MAIN =====
main() {
    log_info "Installing Clawdbot CLI"

    install_clawdbot

    log_info "✓ Done!"
    log_info "Run 'clawd' to start using Clawdbot"
    log_info "Visit https://clawd.bot for documentation"
}

main "$@"
