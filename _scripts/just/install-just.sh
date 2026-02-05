#!/usr/bin/env bash
# Install just on Linux/macOS
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }

# Check if just is already installed
if command -v just &> /dev/null; then
    log_success "just is already installed ($(just --version))"
    exit 0
fi

log_step "Installing just..."

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
else
    log_error "Unsupported OS: $OSTYPE"
    exit 1
fi

# =============================================================================
# Installation methods
# =============================================================================

install_via_brew() {
    if command -v brew &> /dev/null; then
        log_info "Installing via Homebrew..."
        brew install just
        return 0
    fi
    return 1
}

install_via_apt() {
    # just is available in the universe repo on Ubuntu 22.04+
    if command -v apt &> /dev/null; then
        log_info "Installing via apt..."
        sudo apt-get update -qq && sudo apt-get install -y -qq just
        return 0
    fi
    return 1
}

install_via_script() {
    log_info "Installing via official install script (fallback)..."

    if [ -w "/usr/local/bin" ] || sudo -n true 2>/dev/null; then
        INSTALL_DIR="/usr/local/bin"
        log_info "Installing to $INSTALL_DIR"
        curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | sudo bash -s -- --to "$INSTALL_DIR"
    else
        INSTALL_DIR="$HOME/.local/bin"
        log_info "Installing to $INSTALL_DIR"
        mkdir -p "$INSTALL_DIR"
        curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to "$INSTALL_DIR"

        if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
            log_warn "Add $INSTALL_DIR to your PATH"
            log_info "Add this to your ~/.zshrc or ~/.bashrc:"
            echo "    export PATH=\"$INSTALL_DIR:\$PATH\""
        fi
    fi

    return 0
}

# =============================================================================
# Install — prefer native package manager, fall back to official script
# =============================================================================

if [ "$OS" = "macos" ]; then
    install_via_brew || install_via_script
else
    install_via_apt || install_via_script
fi

# Verify installation
if command -v just &> /dev/null; then
    log_success "just installed successfully: $(just --version)"
    log_info "Try: just --list"
else
    log_error "Installation failed. Please install manually:"
    echo "  https://github.com/casey/just#installation"
    exit 1
fi
