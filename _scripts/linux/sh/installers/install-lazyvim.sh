#!/usr/bin/env bash
#
# Install LazyVim (Neovim distribution)
#
# This script installs LazyVim by:
# 1. Backing up existing Neovim configuration
# 2. Cloning the LazyVim starter template
# 3. Removing .git folder for customization
# 4. Installing required dependencies if needed
#
# Usage:
#   ./install-lazyvim.sh              # Install with backup
#   ./install-lazyvim.sh --no-backup  # Install without backup
#   ./install-lazyvim.sh --force      # Force reinstall
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
NVIM_CONFIG_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
NVIM_DATA_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
NVIM_STATE_PATH="${XDG_STATE_HOME:-$HOME/.local/state}/nvim"
NVIM_CACHE_PATH="${XDG_CACHE_HOME:-$HOME/.cache}/nvim"

NVIM_CONFIG_BACKUP="${NVIM_CONFIG_PATH}.bak"
NVIM_DATA_BACKUP="${NVIM_DATA_PATH}.bak"
NVIM_STATE_BACKUP="${NVIM_STATE_PATH}.bak"
NVIM_CACHE_BACKUP="${NVIM_CACHE_PATH}.bak"

LAZYVIM_REPO="https://github.com/LazyVim/starter"

# Parse arguments
SKIP_BACKUP=false
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-backup)
            SKIP_BACKUP=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Install LazyVim Neovim distribution"
            echo ""
            echo "Options:"
            echo "  --no-backup    Skip backing up existing configuration"
            echo "  --force        Force reinstall even if already installed"
            echo "  -h, --help     Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Helper functions
print_header() {
    echo -e "\n${CYAN}==>${NC} ${BLUE}$1${NC}"
}

print_info() {
    echo -e "${CYAN}  →${NC} $1"
}

print_success() {
    echo -e "${GREEN}  ✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}  !${NC} $1"
}

print_error() {
    echo -e "${RED}  ✗${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check dependencies
check_dependencies() {
    print_header "Checking dependencies"

    local missing_required=()
    local missing_optional=()

    # Required dependencies
    if ! command_exists nvim; then
        print_error "Missing required: Neovim"
        missing_required+=("neovim")
    else
        print_success "Found: Neovim ($(nvim --version | head -n1))"
    fi

    if ! command_exists git; then
        print_error "Missing required: Git"
        missing_required+=("git")
    else
        print_success "Found: Git ($(git --version))"
    fi

    # Optional dependencies
    if ! command_exists rg; then
        print_warning "Missing optional: ripgrep (recommended)"
        missing_optional+=("ripgrep")
    else
        print_success "Found: ripgrep"
    fi

    if ! command_exists fd; then
        print_warning "Missing optional: fd (recommended)"
        missing_optional+=("fd")
    else
        print_success "Found: fd"
    fi

    if ! command_exists lazygit; then
        print_warning "Missing optional: lazygit (recommended)"
        missing_optional+=("lazygit")
    else
        print_success "Found: lazygit"
    fi

    # Handle missing required dependencies
    if [ ${#missing_required[@]} -gt 0 ]; then
        print_error ""
        print_error "Missing required dependencies: ${missing_required[*]}"
        print_info ""
        print_info "Install them using your package manager:"
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            print_info "  brew install neovim git"
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command_exists apt; then
                print_info "  sudo apt install neovim git"
            elif command_exists yum; then
                print_info "  sudo yum install neovim git"
            elif command_exists pacman; then
                print_info "  sudo pacman -S neovim git"
            fi
        fi
        return 1
    fi

    # Handle missing optional dependencies
    if [ ${#missing_optional[@]} -gt 0 ]; then
        print_warning ""
        print_warning "Missing optional dependencies: ${missing_optional[*]}"
        print_info "For the best experience, install them using:"
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            print_info "  brew install ripgrep fd lazygit"
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command_exists apt; then
                print_info "  sudo apt install ripgrep fd-find lazygit"
            elif command_exists yum; then
                print_info "  sudo yum install ripgrep fd-find lazygit"
            elif command_exists pacman; then
                print_info "  sudo pacman -S ripgrep fd lazygit"
            fi
        fi
        print_info ""
    fi

    return 0
}

# Backup existing Neovim configuration
backup_neovim_config() {
    print_header "Backing up existing Neovim configuration"

    # Backup config
    if [ -d "$NVIM_CONFIG_PATH" ]; then
        if [ -d "$NVIM_CONFIG_BACKUP" ]; then
            print_warning "Backup already exists at: $NVIM_CONFIG_BACKUP"
            print_info "Removing old backup..."
            rm -rf "$NVIM_CONFIG_BACKUP"
        fi
        
        print_info "Backing up config: $NVIM_CONFIG_PATH -> $NVIM_CONFIG_BACKUP"
        mv "$NVIM_CONFIG_PATH" "$NVIM_CONFIG_BACKUP"
        print_success "Config backed up successfully"
    else
        print_info "No existing Neovim config found at: $NVIM_CONFIG_PATH"
    fi

    # Backup data (optional but recommended)
    if [ -d "$NVIM_DATA_PATH" ]; then
        if [ -d "$NVIM_DATA_BACKUP" ]; then
            print_warning "Data backup already exists at: $NVIM_DATA_BACKUP"
            print_info "Removing old data backup..."
            rm -rf "$NVIM_DATA_BACKUP"
        fi
        
        print_info "Backing up data: $NVIM_DATA_PATH -> $NVIM_DATA_BACKUP"
        mv "$NVIM_DATA_PATH" "$NVIM_DATA_BACKUP"
        print_success "Data backed up successfully"
    fi

    # Backup state (optional)
    if [ -d "$NVIM_STATE_PATH" ]; then
        if [ -d "$NVIM_STATE_BACKUP" ]; then
            rm -rf "$NVIM_STATE_BACKUP"
        fi
        print_info "Backing up state: $NVIM_STATE_PATH -> $NVIM_STATE_BACKUP"
        mv "$NVIM_STATE_PATH" "$NVIM_STATE_BACKUP"
    fi

    # Backup cache (optional)
    if [ -d "$NVIM_CACHE_PATH" ]; then
        if [ -d "$NVIM_CACHE_BACKUP" ]; then
            rm -rf "$NVIM_CACHE_BACKUP"
        fi
        print_info "Backing up cache: $NVIM_CACHE_PATH -> $NVIM_CACHE_BACKUP"
        mv "$NVIM_CACHE_PATH" "$NVIM_CACHE_BACKUP"
    fi
}

# Install LazyVim starter
install_lazyvim_starter() {
    print_header "Installing LazyVim starter template"

    print_info "Cloning LazyVim starter from GitHub..."
    print_info "Repository: $LAZYVIM_REPO"
    print_info "Destination: $NVIM_CONFIG_PATH"

    if ! git clone "$LAZYVIM_REPO" "$NVIM_CONFIG_PATH"; then
        print_error "Failed to clone LazyVim starter"
        return 1
    fi
    print_success "LazyVim starter cloned successfully"

    # Remove .git folder to allow customization
    if [ -d "$NVIM_CONFIG_PATH/.git" ]; then
        print_info "Removing .git folder to allow customization..."
        rm -rf "$NVIM_CONFIG_PATH/.git"
        print_success ".git folder removed"
    fi

    return 0
}

# Main installation process
main() {
    print_header "LazyVim Installation Script"
    print_info "Installing LazyVim Neovim distribution..."
    echo ""

    # Check dependencies
    if ! check_dependencies; then
        print_error "Please install required dependencies first"
        exit 1
    fi

    # Check if LazyVim is already installed
    if [ -d "$NVIM_CONFIG_PATH" ] && [ -f "$NVIM_CONFIG_PATH/lua/config/lazy.lua" ] && [ "$FORCE" != true ]; then
        print_warning "LazyVim appears to be already installed at: $NVIM_CONFIG_PATH"
        print_info "Use --force to reinstall"
        
        read -rp "Do you want to reinstall? (y/N): " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_info "Installation cancelled"
            exit 0
        fi
        FORCE=true
    fi

    # Backup existing configuration
    if [ "$SKIP_BACKUP" != true ]; then
        backup_neovim_config
    else
        print_info "Skipping backup (as requested)"
        if [ -d "$NVIM_CONFIG_PATH" ]; then
            print_warning "Removing existing config without backup..."
            rm -rf "$NVIM_CONFIG_PATH"
        fi
    fi

    # Install LazyVim starter
    if ! install_lazyvim_starter; then
        print_error "LazyVim installation failed"
        exit 1
    fi

    # Success message
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           LazyVim installed successfully! 🎉                       ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    print_info "Next steps:"
    print_info "  1. Start Neovim: nvim"
    print_info "  2. LazyVim will automatically install plugins on first launch"
    print_info "  3. Run health check: :LazyHealth"
    print_info "  4. Customize your config in: $NVIM_CONFIG_PATH"
    echo ""
    print_info "Configuration location:"
    print_info "  Config: $NVIM_CONFIG_PATH"
    if [ "$SKIP_BACKUP" != true ] && [ -d "$NVIM_CONFIG_BACKUP" ]; then
        print_info "  Backup: $NVIM_CONFIG_BACKUP"
    fi
    echo ""
    print_info "Recommended keymaps to explore:"
    print_info "  - Press <leader>l to open Lazy plugin manager"
    print_info "  - Press <leader>e to open file explorer"
    print_info "  - Press <leader>ff to find files"
    print_info "  - Press <leader>sg to search in files (grep)"
    echo ""
    print_info "Documentation: https://www.lazyvim.org/"
    echo ""
}

# Run installation
main
