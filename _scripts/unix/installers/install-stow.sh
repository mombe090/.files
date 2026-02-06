#!/usr/bin/env bash
# Install GNU Stow for dotfiles management
set -e

# Path resolution - Script is at: _scripts/unix/installers/ — 3 levels up to repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Source Unix libraries
source "$DOTFILES_ROOT/_scripts/unix/lib/init.sh"

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
