#!/usr/bin/env bash
# Install GNU Stow for dotfiles management
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

# ===== INSTALL STOW =====
install_stow() {
    if command -v stow &> /dev/null; then
        log_warn "stow already installed ($(stow --version | head -n1))"
        return 0
    fi

    log_info "Installing GNU Stow..."

    local os=$(detect_os)
    case $os in
        macos)
            brew install stow
            ;;
        debian)
            sudo apt-get update
            sudo apt-get install -y stow
            ;;
        redhat)
            sudo yum install -y stow
            ;;
        arch)
            sudo pacman -S --noconfirm stow
            ;;
        *)
            log_error "Unsupported OS"
            exit 1
            ;;
    esac

    log_info "stow installed"
}

# ===== MAIN =====
main() {
    log_info "Installing GNU Stow"

    install_stow

    log_info "✓ Done!"
    log_info "Use 'stow <package>' to symlink dotfiles"
}

main "$@"
