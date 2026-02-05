#!/usr/bin/env bash
# =============================================================================
# Bootstrap Script - Quick setup for new machines
# =============================================================================
# This script installs essential development tools and Just command runner.
# After bootstrap, use `just install_full` or `just install_minimal` for
# complete dotfiles installation.
#
# Usage:
#   bash bootstrap.sh           # Interactive (recommended)
#   bash bootstrap.sh --yes     # Non-interactive (auto-confirm)
#   bash bootstrap.sh --help    # Show help
# =============================================================================

set -e

# Ensure HOME points to the actual current user (fixes stale HOME after su)
if command -v getent &> /dev/null; then
    REAL_HOME=$(getent passwd "$(whoami)" | cut -d: -f6)
    if [[ "$HOME" != "$REAL_HOME" ]]; then
        echo "[WARN] HOME was $HOME, correcting to $REAL_HOME"
        export HOME="$REAL_HOME"
    fi
fi

# Get dotfiles root directory (script is in _scripts/, go up one level)
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$DOTFILES_ROOT/_scripts"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

log_header() {
    echo ""
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}[#] $1${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} ${BOLD}$1${NC}"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} ${BOLD}$1${NC}"; }

# Parse arguments
AUTO_YES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --yes|-y)
            AUTO_YES=true
            shift
            ;;
        --help|-h)
            cat << 'EOF'
Bootstrap Script - Quick setup for new machines

USAGE:
    bash bootstrap.sh [OPTIONS]

OPTIONS:
    --yes, -y       Auto-confirm all prompts (non-interactive)
    --help, -h      Show this help message

DESCRIPTION:
    Installs essential development tools:
    - curl (required for downloads)
    - git (required for version control)
    - Essential packages (stow, zsh, build-essential, etc.)
    - Just command runner (modern task runner)

    After bootstrap completes, use:
        just install_full      # Full dotfiles installation
        just install_minimal   # Minimal dotfiles installation

EXAMPLES:
    # Interactive (recommended)
    bash bootstrap.sh

    # Non-interactive (CI/automation)
    bash bootstrap.sh --yes

EOF
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# =============================================================================
# Banner
# =============================================================================

clear
echo ""
echo -e "${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║                                                                ║${NC}"
echo -e "${BOLD}║                   ${MAGENTA}DOTFILES BOOTSTRAP${NC}${BOLD}                         ║${NC}"
echo -e "${BOLD}║                                                                ║${NC}"
echo -e "${BOLD}║          Quick setup for essential development tools          ║${NC}"
echo -e "${BOLD}║                                                                ║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# =============================================================================
# Detect OS
# =============================================================================

log_header "System Detection"

if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    PM="brew"
    log_info "Detected: macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"

    # Detect Linux distribution
    if command -v lsb_release &> /dev/null; then
        DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    elif [[ -f /etc/os-release ]]; then
        DISTRO=$(grep "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')
    else
        DISTRO="unknown"
    fi

    # Set package manager
    case "$DISTRO" in
        ubuntu|debian|linuxmint)
            PM="apt"
            ;;
        fedora|rhel|centos)
            PM="dnf"
            ;;
        arch|manjaro)
            PM="pacman"
            ;;
        *)
            PM="unknown"
            ;;
    esac

    log_info "Detected: Linux ($DISTRO)"
    log_info "Package Manager: $PM"
else
    log_error "Unsupported OS: $OSTYPE"
    exit 1
fi

# =============================================================================
# Confirm Installation
# =============================================================================

if [[ "$AUTO_YES" != "true" ]]; then
    echo ""
    echo -e "${BOLD}This script will install:${NC}"
    echo "  • curl (if not installed)"
    echo "  • git (if not installed)"
    echo "  • Essential development packages (via install-packages.sh)"
    echo "  • Just command runner (latest version)"
    echo ""
    echo -e "${YELLOW}Package manager: $PM${NC}"
    echo ""
    read -p "Continue? [Y/n] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ -n $REPLY ]]; then
        log_warn "Installation cancelled"
        exit 0
    fi
fi

# =============================================================================
# Install Essential Tools
# =============================================================================

log_header "Installing Essential Tools"

# Function to check if a command exists
has_command() {
    command -v "$1" &> /dev/null
}

# Install curl
if has_command curl; then
    log_success "curl already installed"
else
    log_step "Installing curl..."
    case "$PM" in
        brew)
            brew install curl
            ;;
        apt)
            sudo apt-get update -qq
            sudo apt-get install -y curl
            ;;
        dnf)
            sudo dnf install -y curl
            ;;
        pacman)
            sudo pacman -S --noconfirm curl
            ;;
        *)
            log_error "Please install curl manually"
            exit 1
            ;;
    esac
    log_success "curl installed"
fi

# Install git
if has_command git; then
    log_success "git already installed ($(git --version))"
else
    log_step "Installing git..."
    case "$PM" in
        brew)
            brew install git
            ;;
        apt)
            sudo apt-get update -qq
            sudo apt-get install -y git
            ;;
        dnf)
            sudo dnf install -y git
            ;;
        pacman)
            sudo pacman -S --noconfirm git
            ;;
        *)
            log_error "Please install git manually"
            exit 1
            ;;
    esac
    log_success "git installed"
fi

# =============================================================================
# Install Essential Packages
# =============================================================================

log_header "Installing Essential Packages"

# Check if install-packages.sh exists
if [[ -f "$SCRIPTS_DIR/unix/installers/install-packages.sh" ]]; then
    log_step "Installing essential development packages..."

    # Install only essential packages (minimal mode)
    if bash "$SCRIPTS_DIR/unix/installers/install-packages.sh" --pro --minimal --category essentials; then
        log_success "Essential packages installed"
    else
        log_warn "Some packages may have failed to install"
        log_info "You can retry with: just packages-minimal"
    fi
else
    log_warn "install-packages.sh not found, skipping package installation"
    log_info "Essential packages will be installed during full setup"
fi

# =============================================================================
# Install Just Command Runner
# =============================================================================

log_header "Installing Just Command Runner"

if bash "$SCRIPTS_DIR/just/install-just.sh"; then
    log_success "Just installed successfully"
else
    log_error "Failed to install Just"
    log_info "You can install it manually from: https://github.com/casey/just"
    exit 1
fi

# Verify just is in PATH
if has_command just; then
    JUST_VERSION=$(just --version)
    log_success "Just is ready: $JUST_VERSION"
else
    log_warn "Just installed but not in PATH yet"
    log_info "Add to your PATH (if installed to ~/.local/bin):"
    echo '    export PATH="$HOME/.local/bin:$PATH"'
    echo ""
    log_info "Then reload your shell:"
    echo "    source ~/.bashrc    # or ~/.zshrc"
fi

# =============================================================================
# Bootstrap Complete
# =============================================================================

log_header "Bootstrap Complete! 🎉"

echo -e "${GREEN}Essential tools installed:${NC}"
echo "  ✓ curl"
echo "  ✓ git"
echo "  ✓ Essential development packages"
echo "  ✓ just"
echo ""

echo -e "${BOLD}Next Steps:${NC}"
echo ""
echo -e "${BLUE}1.${NC} View available commands:"
echo -e "   ${BOLD}just --list${NC}"
echo ""
echo -e "${BLUE}2.${NC} Install all dotfiles (recommended):"
echo -e "   ${BOLD}just install_full${NC}"
echo ""
echo -e "${BLUE}3.${NC} Or install minimal dotfiles only:"
echo -e "   ${BOLD}just install_minimal${NC}"
echo ""
echo -e "${BLUE}4.${NC} Check system health:"
echo -e "   ${BOLD}just doctor${NC}"
echo ""

echo -e "${YELLOW}Documentation:${NC}"
echo "  • Quick Start:  cat README.md"
echo "  • All Commands: just --list"
echo "  • Get Help:     just help"
echo ""

# If just is not in PATH, show reminder
if ! has_command just; then
    echo -e "${YELLOW}⚠️  REMINDER: Add Just to your PATH${NC}"
    echo -e "   Run: ${BOLD}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
    echo -e "   Then: ${BOLD}source ~/.bashrc${NC}  # or ~/.zshrc"
    echo ""
fi
