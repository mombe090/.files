#!/usr/bin/env bash
# Install .NET SDK and Runtime
# Supports: macOS (via brew), Ubuntu/Debian (apt), RHEL/Fedora (yum/dnf), Arch (pacman)
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ===== CONFIGURATION =====
DOTNET_VERSION="${DOTNET_VERSION:-10.0}"  # Default to .NET 10
INSTALL_SDK="${INSTALL_SDK:-true}"       # Install SDK by default
INSTALL_RUNTIME="${INSTALL_RUNTIME:-false}"  # Runtime included with SDK

# ===== DETECT OS =====
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian|pop)
                echo "ubuntu"
                ;;
            fedora|rhel|centos|rocky|almalinux)
                echo "redhat"
                ;;
            arch|manjaro|endeavouros)
                echo "arch"
                ;;
            *)
                echo "unknown"
                ;;
        esac
    else
        echo "unknown"
    fi
}

# ===== GET UBUNTU VERSION =====
get_ubuntu_version() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$VERSION_ID"
    else
        echo "unknown"
    fi
}

# ===== CHECK IF DOTNET IS INSTALLED =====
check_dotnet() {
    if command -v dotnet &> /dev/null; then
        local version=$(dotnet --version 2>/dev/null || echo "unknown")
        log_warn ".NET is already installed (version: $version)"
        
        # Skip prompt if AUTO_INSTALL is set
        if [[ "$AUTO_INSTALL" == "true" ]]; then
            log_info "Skipping additional .NET installation (auto-install mode)"
            exit 0
        fi
        
        log_info "To install additional versions, continue anyway"
        read -p "Continue installation? [y/N]: " continue_install
        if [[ ! "$continue_install" =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi
}

# ===== INSTALL ON MACOS =====
install_macos() {
    log_info "Installing .NET $DOTNET_VERSION on macOS..."
    
    if ! command -v brew &> /dev/null; then
        log_error "Homebrew is required but not installed"
        log_info "Install Homebrew from: https://brew.sh"
        exit 1
    fi
    
    if [[ "$INSTALL_SDK" == "true" ]]; then
        log_info "Installing .NET SDK $DOTNET_VERSION via Homebrew..."
        brew install --cask dotnet-sdk
        log_info ".NET SDK installed"
    fi
    
    # Runtime is included with SDK on macOS
    if [[ "$INSTALL_RUNTIME" == "true" ]] && [[ "$INSTALL_SDK" != "true" ]]; then
        log_warn "On macOS, install the SDK to get the runtime"
        log_warn "Or download runtime manually from: https://dotnet.microsoft.com/download"
    fi
}

# ===== INSTALL ON UBUNTU/DEBIAN =====
install_ubuntu() {
    log_info "Installing .NET $DOTNET_VERSION on Ubuntu/Debian..."
    
    local ubuntu_version=$(get_ubuntu_version)
    log_info "Detected Ubuntu version: $ubuntu_version"
    
    # Update package list
    sudo apt-get update
    
    # For Ubuntu 24.04+, .NET is in the default repos
    # For older versions, may need backports PPA
    if [[ "$ubuntu_version" == "22.04" ]] && [[ "$DOTNET_VERSION" =~ ^(9|10) ]]; then
        log_info "Adding .NET backports repository for Ubuntu 22.04..."
        sudo add-apt-repository -y ppa:dotnet/backports
        sudo apt-get update
    fi
    
    if [[ "$INSTALL_SDK" == "true" ]]; then
        log_info "Installing .NET SDK $DOTNET_VERSION..."
        sudo apt-get install -y "dotnet-sdk-$DOTNET_VERSION"
        log_info ".NET SDK installed"
    fi
    
    if [[ "$INSTALL_RUNTIME" == "true" ]] && [[ "$INSTALL_SDK" != "true" ]]; then
        log_info "Installing ASP.NET Core Runtime $DOTNET_VERSION..."
        sudo apt-get install -y "aspnetcore-runtime-$DOTNET_VERSION"
        log_info "ASP.NET Core Runtime installed"
    fi
}

# ===== INSTALL ON REDHAT/FEDORA =====
install_redhat() {
    log_info "Installing .NET $DOTNET_VERSION on RHEL/Fedora..."
    
    # Determine package manager
    local PKG_MGR="yum"
    if command -v dnf &> /dev/null; then
        PKG_MGR="dnf"
    fi
    
    if [[ "$INSTALL_SDK" == "true" ]]; then
        log_info "Installing .NET SDK $DOTNET_VERSION..."
        sudo $PKG_MGR install -y "dotnet-sdk-$DOTNET_VERSION"
        log_info ".NET SDK installed"
    fi
    
    if [[ "$INSTALL_RUNTIME" == "true" ]] && [[ "$INSTALL_SDK" != "true" ]]; then
        log_info "Installing ASP.NET Core Runtime $DOTNET_VERSION..."
        sudo $PKG_MGR install -y "aspnetcore-runtime-$DOTNET_VERSION"
        log_info "ASP.NET Core Runtime installed"
    fi
}

# ===== INSTALL ON ARCH =====
install_arch() {
    log_info "Installing .NET on Arch Linux..."
    
    log_warn "Arch Linux packages .NET differently"
    log_info "Installing dotnet-sdk (includes runtime)..."
    
    sudo pacman -S --noconfirm dotnet-sdk
    
    log_info ".NET SDK installed"
    log_warn "Arch provides the latest stable version, not version-specific packages"
}

# ===== INSTALL VIA SCRIPT (FALLBACK) =====
install_script() {
    log_warn "Using Microsoft install script as fallback..."
    log_info "Downloading install script..."
    
    local install_dir="$HOME/.dotnet"
    local script_url="https://dot.net/v1/dotnet-install.sh"
    
    # Download script
    curl -fsSL "$script_url" -o /tmp/dotnet-install.sh
    chmod +x /tmp/dotnet-install.sh
    
    # Install SDK or Runtime
    if [[ "$INSTALL_SDK" == "true" ]]; then
        log_info "Installing .NET SDK $DOTNET_VERSION to $install_dir..."
        /tmp/dotnet-install.sh --channel "$DOTNET_VERSION" --install-dir "$install_dir"
    fi
    
    if [[ "$INSTALL_RUNTIME" == "true" ]] && [[ "$INSTALL_SDK" != "true" ]]; then
        log_info "Installing .NET Runtime $DOTNET_VERSION to $install_dir..."
        /tmp/dotnet-install.sh --channel "$DOTNET_VERSION" --runtime dotnet --install-dir "$install_dir"
    fi
    
    # Clean up
    rm /tmp/dotnet-install.sh
    
    # Add to PATH
    log_info "Adding .NET to PATH..."
    if [[ ! ":$PATH:" == *":$install_dir:"* ]]; then
        export PATH="$PATH:$install_dir"
        log_warn "Add this to your shell profile:"
        echo "  export PATH=\"\$PATH:$install_dir\""
    fi
}

# ===== VERIFY INSTALLATION =====
verify_installation() {
    log_info "Verifying .NET installation..."
    
    if command -v dotnet &> /dev/null; then
        local version=$(dotnet --version)
        log_info ".NET is available: $version"
        echo ""
        dotnet --info
    else
        log_error "dotnet command not found in current shell"
        log_warn ""
        log_warn "Troubleshooting steps:"
        log_warn ""
        log_warn "1. Restart your terminal/shell session"
        log_warn "   - Close and reopen your terminal"
        log_warn "   - Or run: exec \$SHELL -l"
        log_warn ""
        log_warn "2. Check if dotnet is installed in these locations:"
        
        local dotnet_paths=(
            "/usr/local/bin/dotnet"
            "/usr/bin/dotnet"
            "/opt/homebrew/bin/dotnet"
            "$HOME/.dotnet/dotnet"
        )
        
        local found_path=""
        for path in "${dotnet_paths[@]}"; do
            if [[ -f "$path" ]]; then
                log_warn "   Found: $path"
                found_path="$path"
            fi
        done
        
        if [[ -n "$found_path" ]]; then
            log_warn ""
            log_warn "3. Test dotnet directly:"
            log_warn "   $found_path --version"
            log_warn ""
            log_warn "4. If using these dotfiles, the PATH is configured in:"
            log_warn "   ~/.config/zsh/env.zsh (check if stowed correctly)"
            log_warn ""
            log_warn "5. Or add to PATH manually (temporary fix):"
            local dotnet_dir=$(dirname "$found_path")
            log_warn "   export PATH=\"\$PATH:$dotnet_dir\""
            log_warn ""
            log_warn "6. Reload shell configuration:"
            log_warn "   source ~/.zshrc  # or exec \$SHELL -l"
        else
            log_warn ""
            log_warn "3. Installation may have failed - check logs above"
            log_warn "4. Try manual installation: https://dotnet.microsoft.com/download"
        fi
        
        return 1
    fi
}

# ===== MAIN =====
main() {
    log_info "Installing .NET SDK/Runtime"
    echo ""
    
    # Show configuration
    log_info "Configuration:"
    echo "  Version: $DOTNET_VERSION"
    echo "  Install SDK: $INSTALL_SDK"
    echo "  Install Runtime: $INSTALL_RUNTIME"
    echo ""
    
    # Check existing installation
    check_dotnet
    
    # Detect OS and install
    local os=$(detect_os)
    log_info "Detected OS: $os"
    echo ""
    
    case $os in
        macos)
            install_macos
            ;;
        ubuntu)
            install_ubuntu
            ;;
        redhat)
            install_redhat
            ;;
        arch)
            install_arch
            ;;
        *)
            log_warn "Unsupported OS detected, using install script..."
            install_script
            ;;
    esac
    
    echo ""
    verify_installation
    
    echo ""
    log_info "✓ Done!"
    log_info "Next steps:"
    echo "  - Run: dotnet --version"
    echo "  - Create app: dotnet new console -n MyApp"
    echo "  - Learn more: https://learn.microsoft.com/dotnet"
}

# ===== HELP =====
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Install .NET SDK and/or Runtime"
    echo ""
    echo "Options:"
    echo "  --version VERSION    .NET version to install (default: 10.0)"
    echo "  --sdk-only          Install only SDK"
    echo "  --runtime-only      Install only Runtime"
    echo "  --help, -h          Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  DOTNET_VERSION      .NET version (default: 10.0)"
    echo "  INSTALL_SDK         Install SDK (default: true)"
    echo "  INSTALL_RUNTIME     Install Runtime (default: false)"
    echo ""
    echo "Examples:"
    echo "  $0"
    echo "  $0 --version 10.0"
    echo "  $0 --runtime-only"
    echo "  DOTNET_VERSION=9.0 $0"
    exit 0
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --version)
            DOTNET_VERSION="$2"
            shift 2
            ;;
        --sdk-only)
            INSTALL_SDK="true"
            INSTALL_RUNTIME="false"
            shift
            ;;
        --runtime-only)
            INSTALL_SDK="false"
            INSTALL_RUNTIME="true"
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

main "$@"
