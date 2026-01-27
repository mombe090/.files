#!/usr/bin/env bash
# Install zsh and set as default shell
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
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/redhat-release ]]; then
        echo "redhat"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    else
        echo "unknown"
    fi
}

# ===== INSTALL ZSH =====
install_zsh() {
    if command -v zsh &> /dev/null; then
        log_warn "zsh already installed ($(zsh --version))"
        return 0
    fi

    log_info "Installing zsh..."

    local os=$(detect_os)
    case $os in
        macos)
            brew install zsh
            ;;
        debian)
            sudo apt-get update
            sudo apt-get install -y zsh
            ;;
        redhat)
            sudo yum install -y zsh
            ;;
        arch)
            sudo pacman -S --noconfirm zsh
            ;;
        *)
            log_error "Unsupported OS"
            exit 1
            ;;
    esac

    log_info "zsh installed"
}

# ===== SET DEFAULT SHELL =====
set_default_shell() {
    local current_shell=$(basename "$SHELL")
    
    if [[ "$current_shell" == "zsh" ]]; then
        log_warn "zsh already default shell"
        return 0
    fi

    log_info "Setting zsh as default shell..."

    local zsh_path=$(command -v zsh)

    # Add zsh to valid shells if not present
    if ! grep -q "$zsh_path" /etc/shells; then
        log_info "Adding zsh to /etc/shells..."
        echo "$zsh_path" | sudo tee -a /etc/shells
    fi

    # Change default shell
    sudo chsh -s "$zsh_path" "$USER"

    log_info "Default shell changed to zsh"
    log_warn "You need to log out and back in for changes to take effect"
}

# ===== MAIN =====
main() {
    log_info "Installing zsh and setting as default shell"

    install_zsh
    set_default_shell

    log_info "✓ Done!"
    log_info "Log out and log back in to use zsh"
}

main "$@"
