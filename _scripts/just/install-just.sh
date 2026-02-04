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

# Try different installation methods
install_via_homebrew() {
    if command -v brew &> /dev/null; then
        log_info "Installing via Homebrew..."
        brew install just
        return 0
    fi
    return 1
}

install_via_cargo() {
    if command -v cargo &> /dev/null; then
        log_info "Installing via cargo..."
        cargo install just
        return 0
    fi
    return 1
}

install_via_mise() {
    if command -v mise &> /dev/null; then
        log_info "Installing via mise..."
        mise use -g just@latest
        return 0
    fi
    return 1
}

install_via_script() {
    log_info "Installing via official script..."

    # Determine install location
    if [ -w "/usr/local/bin" ] || sudo -n true 2>/dev/null; then
        INSTALL_DIR="/usr/local/bin"
        log_info "Installing to $INSTALL_DIR (requires sudo)"
        curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | sudo bash -s -- --to "$INSTALL_DIR"
    else
        INSTALL_DIR="$HOME/.local/bin"
        log_info "Installing to $INSTALL_DIR (no sudo)"
        mkdir -p "$INSTALL_DIR"
        curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to "$INSTALL_DIR"

        # Add to PATH if not already there
        if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
            log_warn "Add $INSTALL_DIR to your PATH"
            log_info "Add this to your ~/.zshrc or ~/.bashrc:"
            echo "    export PATH=\"$INSTALL_DIR:\$PATH\""
        fi
    fi

    return 0
}

# Try installation methods in order of preference
if [ "$OS" = "macos" ]; then
    install_via_homebrew || install_via_mise || install_via_cargo || install_via_script
else
    install_via_mise || install_via_cargo || install_via_script
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
