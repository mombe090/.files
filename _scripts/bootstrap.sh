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
    # Linux: use getent
    REAL_HOME=$(getent passwd "$(whoami)" | cut -d: -f6)
    if [[ -n "$REAL_HOME" ]] && [[ "$HOME" != "$REAL_HOME" ]]; then
        echo "[WARN] HOME was $HOME, correcting to $REAL_HOME"
        export HOME="$REAL_HOME"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS: use eval echo
    CURRENT_USER="$(id -un)"
    if [[ -n "$CURRENT_USER" ]]; then
        REAL_HOME=$(eval echo "~$CURRENT_USER")
        if [[ -n "$REAL_HOME" ]] && [[ "$REAL_HOME" != "$HOME" ]]; then
            echo "[WARN] HOME was $HOME, correcting to $REAL_HOME"
            export HOME="$REAL_HOME"
        fi
    fi
fi

# Verify HOME is set and valid
if [[ -z "$HOME" ]] || [[ "$HOME" == "/" ]]; then
    echo "[ERROR] HOME is not set correctly: '$HOME'"
    CURRENT_USER="$(id -un)"
    export HOME=$(eval echo "~$CURRENT_USER")
    echo "[INFO] Set HOME to: $HOME"
fi

# Final sanity check
if [[ -z "$HOME" ]] || [[ "$HOME" == "/" ]] || [[ ! -d "$HOME" ]]; then
    echo "[ERROR] Failed to determine HOME directory"
    echo "[ERROR] HOME='$HOME', USER='$(id -un)'"
    exit 1
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
MISE_SCOPE_FLAG=""  # empty = auto-detect; "--global" or "--user" passed to install-mise.sh

while [[ $# -gt 0 ]]; do
    case $1 in
        --yes|-y)
            AUTO_YES=true
            shift
            ;;
        --all-users|--global|-g)
            MISE_SCOPE_FLAG="--global"
            shift
            ;;
        --user|-u)
            MISE_SCOPE_FLAG="--user"
            shift
            ;;
        --help|-h)
            cat << 'EOF'
Bootstrap Script - Quick setup for new machines

USAGE:
    bash bootstrap.sh [OPTIONS]

OPTIONS:
    --yes, -y           Auto-confirm all prompts (non-interactive)
    --all-users, --global, -g
                        Install mise globally to /usr/local/bin (requires root/sudo).
                        Use when setting up a shared machine for multiple users.
    --user, -u          Install mise to ~/.local/bin (current user only).
    --help, -h          Show this help message

DESCRIPTION:
    This script prepares your machine for dotfiles installation in 2 phases:

    PHASE 1: Environment Configuration (Interactive)
    - Prompts for USER_FULLNAME, USER_EMAIL, PERSONAL_USER, PC_TYPE
    - Creates ~/.envrc (main config) and ~/.private.envrc (secrets)
    - Can be skipped and configured later

    PHASE 2: Essential Tools Installation
    - curl (required for downloads)
    - git (required for version control)
    - mise (version manager for language runtimes)
    - sudo, jq, wget (essential utilities)
    - stow (symlink manager for dotfiles)
    - yq (YAML parser, installed via mise)
    - Essential packages (build-essential, gcc, make, cmake, etc.)
    - Just command runner (via Homebrew on macOS, GitHub on Linux)

    After bootstrap completes, use:
        just install_full      # Full dotfiles installation
        just install_minimal   # Minimal dotfiles installation

ENVIRONMENT CONFIGURATION:
    To configure/reconfigure environment variables later:
        bash _scripts/unix/tools/configure-env-interactive.sh

    Or manually edit:
        nvim ~/.envrc          # Basic config
        nvim ~/.private.envrc  # Secrets

EXAMPLES:
    # Interactive (recommended) - will prompt for configuration
    bash bootstrap.sh

    # Non-interactive (CI/automation) - skips configuration
    bash bootstrap.sh --yes

    # Global install (shared machine / all users)
    bash bootstrap.sh --all-users
    sudo bash bootstrap.sh --global

    # User-only install (no sudo required)
    bash bootstrap.sh --user

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
# Configure Environment Variables (Optional)
# =============================================================================

log_header "Environment Variables Setup"

if [[ ! -f "$HOME/.envrc" ]]; then
    echo ""
    log_info "Before installing, you should configure your environment variables."
    log_info "This includes your name, email, and machine type (pro/perso)."
    echo ""

    if [[ "$AUTO_YES" == "true" ]]; then
        log_info "Skipping environment setup (non-interactive mode)"
        log_info "You can configure later with: bash _scripts/unix/tools/configure-env-interactive.sh"
    else
        read -p "Would you like to configure environment variables now? [Y/n]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            if [[ -f "$SCRIPTS_DIR/unix/tools/configure-env-interactive.sh" ]]; then
                bash "$SCRIPTS_DIR/unix/tools/configure-env-interactive.sh"
            else
                log_warn "configure-env-interactive.sh not found"
                log_info "You can configure manually later"
            fi
        else
            log_info "Skipping environment setup"
            log_info "You can configure later with: bash _scripts/unix/tools/configure-env-interactive.sh"
        fi
    fi
else
    log_success "Environment variables already configured (~/.envrc exists)"
fi

# =============================================================================
# Confirm Installation
# =============================================================================

if [[ "$AUTO_YES" != "true" ]]; then
    echo ""
    echo -e "${BOLD}This script will install:${NC}"
    echo "  • curl (if not installed)"
    echo "  • git (if not installed)"
    echo "  • mise - Version manager (if not installed)"
    echo "  • sudo, jq, wget - Essential utilities (if not installed)"
    echo "  • stow - Symlink manager for dotfiles"
    echo "  • yq - YAML parser (via mise)"
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
# Install Mise (Version Manager)
# =============================================================================

log_header "Installing Mise Version Manager"

if has_command mise; then
    MISE_VERSION=$(mise --version 2>&1 | head -n1 || echo "unknown")
    log_success "mise already installed ($MISE_VERSION)"
else
    log_step "Installing mise..."
    if [[ -n "$MISE_SCOPE_FLAG" ]]; then
        log_info "Scope: $MISE_SCOPE_FLAG (explicitly requested)"
    else
        log_info "Scope: user (~/.local/bin) — pass --global to install system-wide"
    fi
    if [[ -f "$SCRIPTS_DIR/unix/installers/install-mise.sh" ]]; then
        if bash "$SCRIPTS_DIR/unix/installers/install-mise.sh" $MISE_SCOPE_FLAG; then
            log_success "mise installed"

            # Activate mise for current session
            export MISE_DATA_DIR="$HOME/.local/share/mise"
            export MISE_CACHE_DIR="$HOME/.cache/mise"
            export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"

            # Verify mise is accessible
            if has_command mise; then
                MISE_VERSION=$(mise --version 2>&1 | head -n1 || echo "unknown")
                log_success "mise is ready: $MISE_VERSION"
            else
                log_warn "mise installed but not in PATH yet"
                log_info "You may need to restart your shell"
            fi
        else
            log_warn "Failed to install mise"
            log_info "You can install it manually later"
        fi
    else
        log_warn "install-mise.sh not found, skipping mise installation"
    fi
fi

# =============================================================================
# Install Essential Utilities
# =============================================================================

log_header "Installing Essential Utilities"

# Install sudo
if has_command sudo; then
    log_success "sudo already installed"
else
    log_step "Installing sudo..."
    case "$PM" in
        brew)
            log_info "sudo not needed on macOS"
            ;;
        apt)
            # Must use su to install sudo if not available
            if [[ $EUID -eq 0 ]]; then
                apt-get update -qq
                apt-get install -y sudo
            else
                log_error "sudo not available and not running as root"
                log_info "Please install sudo manually or run as root"
                exit 1
            fi
            ;;
        dnf)
            if [[ $EUID -eq 0 ]]; then
                dnf install -y sudo
            else
                log_error "sudo not available and not running as root"
                exit 1
            fi
            ;;
        pacman)
            if [[ $EUID -eq 0 ]]; then
                pacman -S --noconfirm sudo
            else
                log_error "sudo not available and not running as root"
                exit 1
            fi
            ;;
        *)
            log_warn "Cannot install sudo automatically"
            ;;
    esac
    if has_command sudo; then
        log_success "sudo installed"
    fi
fi

# Install jq
if has_command jq; then
    log_success "jq already installed"
else
    log_step "Installing jq..."
    case "$PM" in
        brew)
            brew install jq
            ;;
        apt)
            sudo apt-get update -qq
            sudo apt-get install -y jq
            ;;
        dnf)
            sudo dnf install -y jq
            ;;
        pacman)
            sudo pacman -S --noconfirm jq
            ;;
        *)
            log_error "Please install jq manually"
            exit 1
            ;;
    esac
    log_success "jq installed"
fi

# Install wget
if has_command wget; then
    log_success "wget already installed"
else
    log_step "Installing wget..."
    case "$PM" in
        brew)
            brew install wget
            ;;
        apt)
            sudo apt-get update -qq
            sudo apt-get install -y wget
            ;;
        dnf)
            sudo dnf install -y wget
            ;;
        pacman)
            sudo pacman -S --noconfirm wget
            ;;
        *)
            log_error "Please install wget manually"
            exit 1
            ;;
    esac
    log_success "wget installed"
fi

# =============================================================================
# Install GNU Stow
# =============================================================================

log_header "Installing GNU Stow"

if has_command stow; then
    STOW_VERSION=$(stow --version 2>&1 | head -n1 || echo "unknown")
    log_success "stow already installed ($STOW_VERSION)"
else
    log_step "Installing GNU Stow..."
    if [[ -f "$SCRIPTS_DIR/unix/installers/install-stow.sh" ]]; then
        if bash "$SCRIPTS_DIR/unix/installers/install-stow.sh"; then
            log_success "stow installed"
        else
            log_warn "Failed to install stow"
            log_info "You can install it manually later"
        fi
    else
        # Fallback to direct installation
        log_step "Installing stow directly..."
        case "$PM" in
            brew)
                brew install stow
                ;;
            apt)
                sudo apt-get update -qq
                sudo apt-get install -y stow
                ;;
            dnf)
                sudo dnf install -y stow
                ;;
            pacman)
                sudo pacman -S --noconfirm stow
                ;;
            *)
                log_error "Please install stow manually"
                exit 1
                ;;
        esac
        log_success "stow installed"
    fi
fi

# =============================================================================
# Install yq via Mise
# =============================================================================

log_header "Installing yq (YAML Parser)"

if has_command yq; then
    YQ_VERSION=$(yq --version 2>&1 || echo "unknown")
    if [[ "$YQ_VERSION" =~ "mikefarah" ]]; then
        log_success "yq already installed (mikefarah's version)"
    else
        log_warn "Found incompatible yq version (need mikefarah's yq v4.x)"
        log_step "Installing yq via mise..."
        if has_command mise; then
            mise install yq@latest
            log_success "yq installed via mise"
        else
            log_error "mise not available, cannot install yq"
            log_info "Please install mise first"
            exit 1
        fi
    fi
else
    log_step "Installing yq via mise..."
    if has_command mise; then
        mise install yq@latest
        log_success "yq installed via mise"
    else
        log_error "mise not available, cannot install yq"
        log_info "Please install mise first"
        exit 1
    fi
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

if has_command just; then
    JUST_VERSION=$(just --version 2>&1 || echo "unknown")
    log_success "just already installed ($JUST_VERSION)"
else
    log_step "Installing just..."

    if [[ "$OS" == "macos" ]]; then
        # Use Homebrew on macOS
        brew install just
        log_success "just installed via Homebrew"
    else
        # Use install-just.sh on Linux
        # Remove old apt version if it exists
        if command -v apt &> /dev/null; then
            if dpkg -l 2>/dev/null | grep -q "^ii.*just"; then
                log_warn "Found just installed via apt (likely outdated)"
                log_step "Removing apt version..."
                sudo apt-get remove -y just 2>/dev/null || true
                sudo apt-get autoremove -y 2>/dev/null || true
            fi
        fi

        # Remove old binaries
        if [[ -f /usr/bin/just ]] || [[ -L /usr/bin/just ]]; then
            log_info "Removing old /usr/bin/just"
            sudo rm -f /usr/bin/just
        fi

        # Install via script
        if bash "$SCRIPTS_DIR/just/install-just.sh"; then
            log_success "just installed via install-just.sh"
        else
            log_error "Failed to install just"
            log_info "You can install it manually from: https://github.com/casey/just"
            exit 1
        fi
    fi

    # Clear bash command hash
    hash -r 2>/dev/null || true

    # Verify installation
    if has_command just; then
        JUST_VERSION=$(just --version 2>&1)
        JUST_LOCATION=$(which just 2>&1)
        log_success "just is ready: $JUST_VERSION"
        log_info "Location: $JUST_LOCATION"
    else
        log_error "just command not found after installation"
        log_info "Try: export PATH=\"/usr/local/bin:\$PATH\" && hash -r"
        exit 1
    fi
fi

# =============================================================================
# Bootstrap Complete
# =============================================================================

log_header "Bootstrap Complete! 🎉"

echo -e "${GREEN}Essential tools installed:${NC}"
echo "  ✓ curl"
echo "  ✓ git"
echo "  ✓ mise"
echo "  ✓ sudo"
echo "  ✓ jq"
echo "  ✓ wget"
echo "  ✓ stow"
echo "  ✓ yq (via mise)"
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
