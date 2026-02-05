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

install_via_binary() {
    # Download specific version from GitHub releases
    local JUST_VERSION="1.46.0"
    log_info "Installing just v${JUST_VERSION} from GitHub releases..."

    # Detect architecture
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)  ARCH="x86_64" ;;
        aarch64) ARCH="aarch64" ;;
        arm64)   ARCH="aarch64" ;;
        *)
            log_warn "Unsupported architecture: $ARCH"
            return 1
            ;;
    esac

    # Detect OS for binary naming
    case "$OS" in
        linux) PLATFORM="unknown-linux-musl" ;;
        macos) PLATFORM="apple-darwin" ;;
        *)
            log_warn "Unsupported OS for binary install: $OS"
            return 1
            ;;
    esac

    BINARY_NAME="just-${ARCH}-${PLATFORM}"
    DOWNLOAD_URL="https://github.com/casey/just/releases/download/${JUST_VERSION}/${BINARY_NAME}.tar.gz"

    log_info "Downloading: $BINARY_NAME"

    # Create temp directory
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf '$TEMP_DIR'" EXIT

    # Download and extract
    if ! curl -fsSL "$DOWNLOAD_URL" | tar -xz -C "$TEMP_DIR"; then
        log_warn "Failed to download binary from v${JUST_VERSION}"
        return 1
    fi

    # Install to /usr/local/bin if we have permission, otherwise ~/.local/bin
    if [ -w "/usr/local/bin" ] || sudo -n true 2>/dev/null; then
        INSTALL_DIR="/usr/local/bin"
        log_info "Installing to $INSTALL_DIR (requires sudo)"
        sudo mv "$TEMP_DIR/just" "$INSTALL_DIR/just"
        sudo chmod +x "$INSTALL_DIR/just"
    else
        INSTALL_DIR="$HOME/.local/bin"
        log_info "Installing to $INSTALL_DIR"
        mkdir -p "$INSTALL_DIR"
        mv "$TEMP_DIR/just" "$INSTALL_DIR/just"
        chmod +x "$INSTALL_DIR/just"

        if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
            log_warn "Add $INSTALL_DIR to your PATH"
            log_info "Add this to your ~/.zshrc or ~/.bashrc:"
            echo "    export PATH=\"$INSTALL_DIR:\$PATH\""
        fi
    fi

    return 0
}

install_via_apt() {
    # WARNING: apt version may be outdated (e.g., 1.21.0 vs required 1.46.0)
    # Only use as fallback if binary download fails
    if command -v apt &> /dev/null; then
        log_warn "Installing via apt (may be outdated version)..."
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
# Install — prefer v1.46.0 binary, fall back to brew/apt/script
# =============================================================================

if [ "$OS" = "macos" ]; then
    # macOS: Try brew first (usually up-to-date), then binary v1.46.0, then script
    install_via_brew || install_via_binary || install_via_script
else
    # Linux: Try binary v1.46.0 first, then apt (may be old), then script
    install_via_binary || install_via_apt || install_via_script
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
