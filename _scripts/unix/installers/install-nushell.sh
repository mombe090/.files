#!/usr/bin/env bash
# Install Nushell shell
# macOS: via Homebrew
# Linux: via official binary release

set -e

# Path resolution - Script is at: _scripts/unix/installers/ — 3 levels up to repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Source Unix libraries
source "$DOTFILES_ROOT/_scripts/unix/lib/init.sh"

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unsupported"
    fi
}

# Check if Nushell is already installed
check_nushell() {
    if command -v nu &> /dev/null; then
        log_info "Nushell is already installed: $(nu --version)"
        return 0
    fi
    return 1
}

# Install Nushell on macOS via Homebrew
install_macos() {
    log_step "Installing Nushell via Homebrew..."
    
    if ! command -v brew &> /dev/null; then
        log_error "Homebrew is not installed"
        log_info "Install Homebrew from: https://brew.sh"
        return 1
    fi
    
    brew install nushell
    log_success "Nushell installed via Homebrew"
}

# Install Nushell on Linux via binary release
install_linux() {
    log_step "Installing Nushell via binary release..."
    
    # Detect architecture
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)
            ARCH_NAME="x86_64"
            ;;
        aarch64|arm64)
            ARCH_NAME="aarch64"
            ;;
        armv7l)
            ARCH_NAME="armv7"
            ;;
        *)
            log_error "Unsupported architecture: $ARCH"
            return 1
            ;;
    esac
    
    # Get latest version from GitHub
    log_info "Fetching latest Nushell version..."
    LATEST_VERSION=$(curl -s https://api.github.com/repos/nushell/nushell/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [[ -z "$LATEST_VERSION" ]]; then
        log_error "Failed to fetch latest version"
        return 1
    fi
    
    log_info "Latest version: $LATEST_VERSION"
    
    # Download binary
    DOWNLOAD_URL="https://github.com/nushell/nushell/releases/download/${LATEST_VERSION}/nu-${LATEST_VERSION}-${ARCH_NAME}-unknown-linux-musl.tar.gz"
    TEMP_DIR=$(mktemp -d)
    DOWNLOAD_FILE="${TEMP_DIR}/nushell.tar.gz"
    
    log_info "Downloading from: $DOWNLOAD_URL"
    if ! curl -L -o "$DOWNLOAD_FILE" "$DOWNLOAD_URL"; then
        log_error "Failed to download Nushell binary"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    # Extract binary
    log_info "Extracting binary..."
    tar -xzf "$DOWNLOAD_FILE" -C "$TEMP_DIR"
    
    # Install to ~/.local/bin
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
    
    # Find the nu binary in the extracted directory
    NU_BINARY=$(find "$TEMP_DIR" -name "nu" -type f | head -n 1)
    
    if [[ -z "$NU_BINARY" ]]; then
        log_error "Could not find nu binary in archive"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    log_info "Installing to $INSTALL_DIR/nu..."
    cp "$NU_BINARY" "$INSTALL_DIR/nu"
    chmod +x "$INSTALL_DIR/nu"
    
    # Cleanup
    rm -rf "$TEMP_DIR"
    
    log_success "Nushell installed to $INSTALL_DIR/nu"
    
    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        log_warn "~/.local/bin is not in your PATH"
        log_info "Add it to your shell config: export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
}

# Main installation
main() {
    log_step "Installing Nushell..."
    echo ""
    
    # Check if already installed
    if check_nushell; then
        log_info "Nushell version: $(nu --version)"
        echo ""
        log_success "Nushell is already installed"
        return 0
    fi
    
    # Detect OS and install
    OS=$(detect_os)
    
    case "$OS" in
        macos)
            log_info "Detected: macOS"
            install_macos
            ;;
        linux)
            log_info "Detected: Linux"
            install_linux
            ;;
        *)
            log_error "Unsupported operating system: $OSTYPE"
            return 1
            ;;
    esac
    
    echo ""
    
    # Verify installation
    if check_nushell; then
        log_success "Nushell installation complete!"
        log_info "Version: $(nu --version)"
        log_info "Run 'nu' to start Nushell"
    else
        log_error "Installation failed - nu command not found"
        return 1
    fi
}

main "$@"
