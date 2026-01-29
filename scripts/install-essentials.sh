#!/usr/bin/env bash
# Install essential build tools and dependencies
# Includes: C/C++ compilers, build tools, libraries, etc.

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/redhat-release ]] || [[ -f /etc/fedora-release ]]; then
        echo "redhat"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    elif [[ -f /etc/alpine-release ]]; then
        echo "alpine"
    else
        echo "unknown"
    fi
}

# Check if running as root (needed for package installation)
check_sudo() {
    if [[ "$EUID" -eq 0 ]]; then
        log_warn "Running as root - sudo not needed"
        return 0
    fi
    
    if ! command -v sudo &> /dev/null; then
        log_error "sudo is not installed and you're not running as root"
        log_info "Please install sudo or run this script as root"
        return 1
    fi
    
    return 0
}

# Install essentials for Debian/Ubuntu
install_debian_essentials() {
    log_step "Installing essentials for Debian/Ubuntu..."
    
    local packages=(
        # Build essentials
        "build-essential"      # GCC, G++, make, libc-dev
        "cmake"                # Build system
        "pkg-config"           # Package configuration tool
        
        # Version control
        "git"                  # Already checked, but included for completeness
        "git-lfs"              # Git Large File Storage
        
        # Download tools
        "curl"                 # Already checked
        "wget"                 # Alternative download tool
        "ca-certificates"      # SSL certificates
        
        # Compression tools
        "unzip"                # Unzip archives
        "zip"                  # Create zip archives
        "tar"                  # Tar archives
        "gzip"                 # Gzip compression
        "bzip2"                # Bzip2 compression
        "xz-utils"             # XZ compression
        
        # Text processing
        "sed"                  # Stream editor
        "awk"                  # Text processing
        "grep"                 # Search tool
        
        # Development libraries
        "libssl-dev"           # OpenSSL development files
        "zlib1g-dev"           # Compression library
        "libbz2-dev"           # Bzip2 library
        "libgdbm-dev"          # GNU dbm library
        "liblzma-dev"          # LZMA library
        "libxml2-dev"          # XML library
        "libxmlsec1-dev"       # XML security library
        "libcurl4-openssl-dev" # cURL library
        
        # Additional tools
        "software-properties-common" # Manage PPAs
        "apt-transport-https"        # HTTPS support for apt
        "gnupg"                      # GNU Privacy Guard
        "lsb-release"                # LSB version reporting
    )
    
    log_info "Updating package list..."
    sudo apt-get update -qq
    
    log_info "Installing ${#packages[@]} essential packages..."
    local installed=0
    local failed=0
    local skipped=0
    
    for package in "${packages[@]}"; do
        # Check if already installed
        if dpkg -l | grep -q "^ii  $package "; then
            log_info "✓ $package (already installed)"
            skipped=$((skipped + 1))
        else
            if sudo apt-get install -y -qq "$package" &> /dev/null; then
                log_success "$package installed"
                installed=$((installed + 1))
            else
                log_warn "Failed to install $package"
                failed=$((failed + 1))
            fi
        fi
    done
    
    echo ""
    log_success "Debian/Ubuntu essentials installation complete!"
    echo "Summary:"
    echo "  ✓ Installed: $installed"
    echo "  ⊙ Already installed: $skipped"
    echo "  ✗ Failed: $failed"
    echo "  Total: ${#packages[@]}"
}

# Install essentials for RHEL/Fedora/Rocky/Alma
install_redhat_essentials() {
    log_step "Installing essentials for RHEL/Fedora..."
    
    # Detect package manager (dnf or yum)
    local pkg_manager="dnf"
    if ! command -v dnf &> /dev/null; then
        pkg_manager="yum"
    fi
    
    local packages=(
        # Development tools group (includes GCC, make, etc.)
        "@development-tools"   # Base development tools
        
        # Build essentials
        "gcc"                  # C compiler
        "gcc-c++"              # C++ compiler
        "make"                 # Build automation
        "cmake"                # Build system
        "pkg-config"           # Package configuration
        
        # Version control
        "git"                  # Version control
        "git-lfs"              # Git Large File Storage
        
        # Download tools
        "curl"                 # Download tool
        "wget"                 # Alternative download tool
        "ca-certificates"      # SSL certificates
        
        # Compression tools
        "unzip"                # Unzip archives
        "zip"                  # Create zip archives
        "tar"                  # Tar archives
        "gzip"                 # Gzip compression
        "bzip2"                # Bzip2 compression
        "xz"                   # XZ compression
        
        # Development libraries
        "openssl-devel"        # OpenSSL development files
        "libffi-devel"         # Foreign function interface
        "zlib-devel"           # Compression library
        "bzip2-devel"          # Bzip2 library
        "libcurl-devel"        # cURL library
        
        # Additional tools
        "gnupg2"               # GNU Privacy Guard
    )
    
    log_info "Installing ${#packages[@]} essential packages..."
    local installed=0
    local failed=0
    local skipped=0
    
    for package in "${packages[@]}"; do
        if sudo $pkg_manager install -y -q "$package" &> /dev/null; then
            log_success "$package installed"
            installed=$((installed + 1))
        else
            # Check if it's already installed
            if rpm -q "$package" &> /dev/null; then
                log_info "✓ $package (already installed)"
                skipped=$((skipped + 1))
            else
                log_warn "Failed to install $package (may not exist in repos)"
                failed=$((failed + 1))
            fi
        fi
    done
    
    echo ""
    log_success "RHEL/Fedora essentials installation complete!"
    echo "Summary:"
    echo "  ✓ Installed: $installed"
    echo "  ⊙ Already installed: $skipped"
    echo "  ✗ Failed: $failed"
    echo "  Total: ${#packages[@]}"
}

# Install essentials for Arch Linux
install_arch_essentials() {
    log_step "Installing essentials for Arch Linux..."
    
    local packages=(
        # Build essentials
        "base-devel"           # Base development tools (includes GCC, make, etc.)
        "cmake"                # Build system
        "pkg-config"           # Package configuration
        
        # Version control
        "git"                  # Version control
        "git-lfs"              # Git Large File Storage
        
        # Download tools
        "curl"                 # Download tool
        "wget"                 # Alternative download tool
        "ca-certificates"      # SSL certificates
        
        # Compression tools
        "unzip"                # Unzip archives
        "zip"                  # Create zip archives
        "tar"                  # Tar archives
        "gzip"                 # Gzip compression
        "bzip2"                # Bzip2 compression
        "xz"                   # XZ compression
        
        # Development libraries
        "openssl"              # OpenSSL
        "libffi"               # Foreign function interface
        "readline"             # Readline library
        "zlib"                 # Compression library
        "bzip2"                # Bzip2 library
        "sqlite"               # SQLite library
        "ncurses"              # Terminal control library
        "gdbm"                 # GNU dbm library
        "xz"                   # LZMA library
        "libxml2"              # XML library
        
        # Python build dependencies
        "python"               # Python 3
        "python-pip"           # Python package installer
    )
    
    log_info "Updating package database..."
    sudo pacman -Sy --noconfirm
    
    log_info "Installing ${#packages[@]} essential packages..."
    local installed=0
    local failed=0
    local skipped=0
    
    for package in "${packages[@]}"; do
        if sudo pacman -S --noconfirm --needed "$package" &> /dev/null; then
            log_success "$package installed"
            installed=$((installed + 1))
        else
            if pacman -Q "$package" &> /dev/null; then
                log_info "✓ $package (already installed)"
                skipped=$((skipped + 1))
            else
                log_warn "Failed to install $package"
                failed=$((failed + 1))
            fi
        fi
    done
    
    echo ""
    log_success "Arch Linux essentials installation complete!"
    echo "Summary:"
    echo "  ✓ Installed: $installed"
    echo "  ⊙ Already installed: $skipped"
    echo "  ✗ Failed: $failed"
    echo "  Total: ${#packages[@]}"
}

# Install essentials for macOS
install_macos_essentials() {
    log_step "Installing essentials for macOS..."
    
    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        log_error "Homebrew is not installed"
        log_info "Please install Homebrew first:"
        log_info "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        return 1
    fi
    
    # Check for Command Line Tools
    if ! xcode-select -p &> /dev/null; then
        log_info "Installing Xcode Command Line Tools..."
        xcode-select --install
        log_warn "Please complete the Xcode Command Line Tools installation and re-run this script"
        return 1
    fi
    
    local packages=(
        # Build essentials (most provided by Xcode CLT)
        "cmake"                # Build system
        "pkg-config"           # Package configuration
        
        # Version control
        "git"                  # Version control
        "git-lfs"              # Git Large File Storage
        
        # Download tools (curl comes with macOS)
        "wget"                 # Alternative download tool
        
        # Compression tools (most come with macOS)
        "unzip"                # Unzip archives
        "xz"                   # XZ compression
        
        # Development libraries
        "openssl@3"            # OpenSSL (latest)
        "libffi"               # Foreign function interface
        "readline"             # Readline library
        "zlib"                 # Compression library (macOS has it, but brew version is newer)
        "bzip2"                # Bzip2 library
        "sqlite"               # SQLite library
        "ncurses"              # Terminal control library
        "gdbm"                 # GNU dbm library
        "libxml2"              # XML library
        
        # Python (macOS has system python, but brew is recommended)
        "python@3.12"          # Python 3
        
        # Additional tools
        "gnupg"                # GNU Privacy Guard
    )
    
    log_info "Updating Homebrew..."
    brew update
    
    log_info "Installing ${#packages[@]} essential packages..."
    local installed=0
    local failed=0
    local skipped=0
    
    for package in "${packages[@]}"; do
        if brew list "$package" &> /dev/null; then
            log_info "✓ $package (already installed)"
            skipped=$((skipped + 1))
        else
            if brew install "$package" &> /dev/null; then
                log_success "$package installed"
                installed=$((installed + 1))
            else
                log_warn "Failed to install $package"
                failed=$((failed + 1))
            fi
        fi
    done
    
    echo ""
    log_success "macOS essentials installation complete!"
    echo "Summary:"
    echo "  ✓ Installed: $installed"
    echo "  ⊙ Already installed: $skipped"
    echo "  ✗ Failed: $failed"
    echo "  Total: ${#packages[@]}"
    echo ""
    log_info "Note: Most build tools are provided by Xcode Command Line Tools"
}

# Install essentials for Alpine Linux
install_alpine_essentials() {
    log_step "Installing essentials for Alpine Linux..."
    
    local packages=(
        # Build essentials
        "build-base"           # Base build tools (gcc, make, libc-dev)
        "cmake"                # Build system
        "pkgconfig"            # Package configuration
        
        # Version control
        "git"                  # Version control
        "git-lfs"              # Git Large File Storage
        
        # Download tools
        "curl"                 # Download tool
        "wget"                 # Alternative download tool
        "ca-certificates"      # SSL certificates
        
        # Compression tools
        "unzip"                # Unzip archives
        "zip"                  # Create zip archives
        "tar"                  # Tar archives
        "gzip"                 # Gzip compression
        "bzip2"                # Bzip2 compression
        "xz"                   # XZ compression
        
        # Development libraries
        "openssl-dev"          # OpenSSL development files
        "libffi-dev"           # Foreign function interface
        "readline-dev"         # Readline library
        "zlib-dev"             # Compression library
        "bzip2-dev"            # Bzip2 library
        "sqlite-dev"           # SQLite library
        "ncurses-dev"          # Terminal control library
        "gdbm-dev"             # GNU dbm library
        "xz-dev"               # LZMA library
        "libxml2-dev"          # XML library
        "curl-dev"             # cURL library
        
        # Python build dependencies
        "python3-dev"          # Python 3 development files
        "py3-pip"              # Python package installer
        
        # Additional tools
        "gnupg"                # GNU Privacy Guard
        "bash"                 # Bash shell
    )
    
    log_info "Updating package index..."
    sudo apk update
    
    log_info "Installing ${#packages[@]} essential packages..."
    local installed=0
    local failed=0
    local skipped=0
    
    for package in "${packages[@]}"; do
        if sudo apk add "$package" &> /dev/null; then
            log_success "$package installed"
            installed=$((installed + 1))
        else
            if apk info -e "$package" &> /dev/null; then
                log_info "✓ $package (already installed)"
                skipped=$((skipped + 1))
            else
                log_warn "Failed to install $package"
                failed=$((failed + 1))
            fi
        fi
    done
    
    echo ""
    log_success "Alpine Linux essentials installation complete!"
    echo "Summary:"
    echo "  ✓ Installed: $installed"
    echo "  ⊙ Already installed: $skipped"
    echo "  ✗ Failed: $failed"
    echo "  Total: ${#packages[@]}"
}

# List installed compilers and build tools
list_installed() {
    log_step "Checking installed build tools..."
    echo ""
    
    # C/C++ Compilers
    echo "C/C++ Compilers:"
    if command -v gcc &> /dev/null; then
        echo "  ✓ gcc: $(gcc --version 2>&1 | head -n1)"
    else
        echo "  ✗ gcc: not installed"
    fi
    
    if command -v g++ &> /dev/null; then
        echo "  ✓ g++: $(g++ --version 2>&1 | head -n1)"
    else
        echo "  ✗ g++: not installed"
    fi
    
    if command -v clang &> /dev/null; then
        echo "  ✓ clang: $(clang --version 2>&1 | head -n1)"
    else
        echo "  ✗ clang: not installed"
    fi
    
    echo ""
    
    # Build tools
    echo "Build Tools:"
    if command -v make &> /dev/null; then
        echo "  ✓ make: $(make --version 2>&1 | head -n1)"
    else
        echo "  ✗ make: not installed"
    fi
    
    if command -v cmake &> /dev/null; then
        echo "  ✓ cmake: $(cmake --version 2>&1 | head -n1)"
    else
        echo "  ✗ cmake: not installed"
    fi
    
    if command -v pkg-config &> /dev/null; then
        echo "  ✓ pkg-config: $(pkg-config --version 2>&1)"
    else
        echo "  ✗ pkg-config: not installed"
    fi
    
    echo ""
    
    # Version control
    echo "Version Control:"
    if command -v git &> /dev/null; then
        echo "  ✓ git: $(git --version 2>&1)"
    else
        echo "  ✗ git: not installed"
    fi
    
    echo ""
    
    # Python
    echo "Python:"
    if command -v python3 &> /dev/null; then
        echo "  ✓ python3: $(python3 --version 2>&1)"
    else
        echo "  ✗ python3: not installed"
    fi
    
    if command -v pip3 &> /dev/null; then
        echo "  ✓ pip3: $(pip3 --version 2>&1)"
    else
        echo "  ✗ pip3: not installed"
    fi
    
    echo ""
}

# Show help
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Install essential build tools and development dependencies.

This script installs:
  - C/C++ compilers (GCC, G++, Clang)
  - Build tools (make, cmake, pkg-config)
  - Development libraries (OpenSSL, libffi, readline, zlib, etc.)
  - Compression tools (zip, unzip, tar, gzip, bzip2, xz)
  - Python development files and pip
  - Version control tools (git, git-lfs)
  - SSL certificates and download tools

Options:
  --list, -l      List installed build tools and compilers
  --help, -h      Show this help message

Examples:
  # Install all essentials
  $(basename "$0")
  
  # List installed tools
  $(basename "$0") --list

Platform support:
  - Debian/Ubuntu (apt)
  - RHEL/Fedora/Rocky/Alma (dnf/yum)
  - Arch Linux (pacman)
  - Alpine Linux (apk)
  - macOS (Homebrew + Xcode CLT)

Note: This script requires sudo/root access for package installation.

EOF
}

# Main function
main() {
    local action="${1:-install}"
    
    case "$action" in
        --list|-l)
            list_installed
            exit 0
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        install|--install|-i|"")
            # Continue with installation
            ;;
        *)
            log_error "Unknown option: $action"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
    
    log_step "Installing essential build tools and dependencies..."
    echo ""
    
    # Detect OS
    local os=$(detect_os)
    log_info "Detected OS: $os"
    echo ""
    
    # Check sudo access (except for macOS which may not need it for Homebrew)
    if [[ "$os" != "macos" ]]; then
        if ! check_sudo; then
            exit 1
        fi
    fi
    
    # Install based on OS
    case "$os" in
        debian)
            install_debian_essentials
            ;;
        redhat)
            install_redhat_essentials
            ;;
        arch)
            install_arch_essentials
            ;;
        alpine)
            install_alpine_essentials
            ;;
        macos)
            install_macos_essentials
            ;;
        *)
            log_error "Unsupported operating system: $OSTYPE"
            log_info "Supported: Debian/Ubuntu, RHEL/Fedora, Arch Linux, Alpine Linux, macOS"
            exit 1
            ;;
    esac
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Show installed tools
    list_installed
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    log_success "Essential build tools installation complete!"
    echo ""
    echo "You can now compile software from source and build native extensions."
    echo ""
    echo "Verify installation:"
    echo "  gcc --version      # C compiler"
    echo "  g++ --version      # C++ compiler"
    echo "  make --version     # Build tool"
    echo "  cmake --version    # Build system"
    echo ""
}

main "$@"
