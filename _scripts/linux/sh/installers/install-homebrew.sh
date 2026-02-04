#!/usr/bin/env bash
# Install Homebrew package manager
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ===== DETECT OS =====
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

# ===== INSTALL HOMEBREW =====
install_homebrew() {
    if command -v brew &> /dev/null; then
        log_warn "homebrew already installed ($(brew --version | head -n1))"
        return 0
    fi

    local os=$(detect_os)
    if [[ "$os" == "unknown" ]]; then
        log_error "Unsupported OS for Homebrew"
        exit 1
    fi

    log_info "Installing Homebrew..."

    # Official Homebrew installer
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    log_info "Homebrew installed"
}

# ===== CONFIGURE SHELL =====
configure_shell() {
    local os=$(detect_os)
    local brew_path=""

    # Determine Homebrew path based on OS and architecture
    if [[ "$os" == "macos" ]]; then
        if [[ $(uname -m) == "arm64" ]]; then
            brew_path="/opt/homebrew/bin/brew"
        else
            brew_path="/usr/local/bin/brew"
        fi
    else
        brew_path="/home/linuxbrew/.linuxbrew/bin/brew"
    fi

    # Check if brew exists at expected path
    if [[ ! -f "$brew_path" ]]; then
        log_warn "Homebrew not found at expected path: $brew_path"
        return 0
    fi

    local zshrc="$HOME/.zshrc"
    local bashrc="$HOME/.bashrc"

    # Configure zsh
    if [[ -f "$zshrc" ]]; then
        if grep -q 'HOMEBREW' "$zshrc" 2>/dev/null; then
            log_warn "Homebrew already configured in ~/.zshrc"
        else
            log_info "Adding Homebrew to ~/.zshrc..."
            cat >> "$zshrc" << EOF

# ===== HOMEBREW CONFIGURATION =====
eval "\$($brew_path shellenv)"
EOF
        fi
    fi

    # Configure bash
    if [[ -f "$bashrc" ]]; then
        if grep -q 'HOMEBREW' "$bashrc" 2>/dev/null; then
            log_warn "Homebrew already configured in ~/.bashrc"
        else
            log_info "Adding Homebrew to ~/.bashrc..."
            cat >> "$bashrc" << EOF

# ===== HOMEBREW CONFIGURATION =====
eval "\$($brew_path shellenv)"
EOF
        fi
    fi

    log_info "Shell configured"
}

# ===== MAIN =====
main() {
    log_info "Installing Homebrew"

    install_homebrew
    configure_shell

    log_info "✓ Done!"
    log_info "Run 'source ~/.zshrc' (or ~/.bashrc) to activate Homebrew"
    log_info "Then use 'brew install <package>' to install packages"
}

main "$@"
