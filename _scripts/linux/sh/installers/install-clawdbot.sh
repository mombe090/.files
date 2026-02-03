#!/usr/bin/env bash
# Install Clawdbot CLI
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

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
