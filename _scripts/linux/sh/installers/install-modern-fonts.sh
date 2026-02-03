#!/usr/bin/env bash
# Install modern Nerd Fonts for development
# Supports: CascadiaMono, JetBrainsMono, VictorMono

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} ${BOLD}$1${NC}"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} ${BOLD}$1${NC}"; }

# Font URLs
NERD_FONTS_VERSION="v3.4.0"
CASCADIA_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_VERSION}/CascadiaMono.zip"
JETBRAINS_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_VERSION}/JetBrainsMono.zip"
VICTOR_MONO_URL="https://rubjo.github.io/victor-mono/VictorMonoAll.zip"

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ -n "$WSL_DISTRO_NAME" ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

# Get fonts directory based on OS
get_fonts_dir() {
    local os=$(detect_os)
    
    if [[ "$os" == "macos" ]]; then
        echo "$HOME/Library/Fonts"
    elif [[ "$os" == "linux" ]]; then
        echo "$HOME/.local/share/fonts"
    else
        log_error "Unsupported OS: $OSTYPE"
        exit 1
    fi
}

# Check prerequisites
check_prerequisites() {
    log_step "Checking prerequisites..."
    
    # Check for required tools
    local missing_tools=()
    
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        missing_tools+=("curl or wget")
    fi
    
    if ! command -v unzip &> /dev/null; then
        missing_tools+=("unzip")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        echo ""
        echo "Install them with:"
        if [[ $(detect_os) == "macos" ]]; then
            echo "  brew install wget unzip"
        else
            echo "  sudo apt install wget unzip   # Debian/Ubuntu"
            echo "  sudo yum install wget unzip   # RHEL/Fedora"
        fi
        exit 1
    fi
    
    log_success "All prerequisites met"
}

# Download file
download_file() {
    local url="$1"
    local output="$2"
    
    if command -v curl &> /dev/null; then
        curl -fsSL "$url" -o "$output"
    elif command -v wget &> /dev/null; then
        wget -q "$url" -O "$output"
    else
        log_error "Neither curl nor wget available"
        return 1
    fi
}

# Install a font family
install_font() {
    local font_name="$1"
    local font_url="$2"
    local fonts_dir="$3"
    
    log_info "Installing: $font_name"
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    local zip_file="$temp_dir/${font_name}.zip"
    
    # Download font
    log_info "Downloading $font_name..."
    if ! download_file "$font_url" "$zip_file"; then
        log_error "Failed to download $font_name"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Extract fonts
    log_info "Extracting $font_name..."
    unzip -q "$zip_file" -d "$temp_dir/${font_name}" 2>/dev/null || {
        log_error "Failed to extract $font_name"
        rm -rf "$temp_dir"
        return 1
    }
    
    # Install font files
    local installed=0
    while IFS= read -r font_file; do
        cp "$font_file" "$fonts_dir/"
        installed=$((installed + 1))
    done < <(find "$temp_dir/${font_name}" -type f \( -name "*.ttf" -o -name "*.otf" \) ! -name "*Windows*" ! -path "*/.*")
    
    # Cleanup
    rm -rf "$temp_dir"
    
    if [[ $installed -gt 0 ]]; then
        log_success "$font_name installed ($installed font files)"
        return 0
    else
        log_warn "$font_name: No font files found"
        return 1
    fi
}

# Update font cache (Linux only)
update_font_cache() {
    if [[ $(detect_os) == "linux" ]]; then
        log_step "Updating font cache..."
        if command -v fc-cache &> /dev/null; then
            fc-cache -f "$1" &> /dev/null
            log_success "Font cache updated"
        else
            log_warn "fc-cache not found, fonts may require manual cache refresh"
        fi
    fi
}

# List installed fonts
list_fonts() {
    local fonts_dir="$1"
    
    log_step "Listing installed Nerd Fonts..."
    echo ""
    
    local cascadia_count=$(find "$fonts_dir" -name "*Cascadia*Nerd*" -o -name "*CaskaydiaMono*" 2>/dev/null | wc -l)
    local jetbrains_count=$(find "$fonts_dir" -name "*JetBrains*Nerd*" 2>/dev/null | wc -l)
    local victor_count=$(find "$fonts_dir" -name "*Victor*Mono*" 2>/dev/null | wc -l)
    
    echo "Installed fonts:"
    [[ $cascadia_count -gt 0 ]] && echo "  ✓ CascadiaMono Nerd Font ($cascadia_count variants)"
    [[ $jetbrains_count -gt 0 ]] && echo "  ✓ JetBrainsMono Nerd Font ($jetbrains_count variants)"
    [[ $victor_count -gt 0 ]] && echo "  ✓ VictorMono Font ($victor_count variants)"
    
    if [[ $cascadia_count -eq 0 ]] && [[ $jetbrains_count -eq 0 ]] && [[ $victor_count -eq 0 ]]; then
        echo "  No Nerd Fonts installed yet"
    fi
    echo ""
}

# Main installation
main() {
    local action="${1:-install}"
    
    case "$action" in
        --list|-l)
            local fonts_dir=$(get_fonts_dir)
            list_fonts "$fonts_dir"
            exit 0
            ;;
        --help|-h)
            cat << EOF
Usage: $(basename "$0") [OPTIONS]

Install modern Nerd Fonts for development environments.

Fonts installed:
  - CascadiaMono Nerd Font (Cascadia Code + icons)
  - JetBrainsMono Nerd Font (JetBrains Mono + icons)
  - VictorMono Font (Victor Mono - cursive italics)

Options:
  --list, -l      List currently installed fonts
  --help, -h      Show this help message

Examples:
  # Install all fonts
  $(basename "$0")
  
  # List installed fonts
  $(basename "$0") --list

Font locations:
  macOS:  ~/Library/Fonts
  Linux:  ~/.local/share/fonts

After installation:
  1. Restart your terminal or IDE
  2. Select font in terminal settings:
     - CaskaydiaMono Nerd Font
     - JetBrainsMono Nerd Font
     - VictorMono Nerd Font
  3. Enable ligatures for best experience

EOF
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
    
    log_step "Installing modern Nerd Fonts..."
    echo ""
    
    # Check prerequisites
    check_prerequisites
    echo ""
    
    # Get fonts directory
    local fonts_dir=$(get_fonts_dir)
    log_info "Fonts directory: $fonts_dir"
    
    # Create fonts directory if needed
    mkdir -p "$fonts_dir"
    echo ""
    
    # Track installation results
    local total=0
    local success=0
    local failed=0
    
    # Install CascadiaMono Nerd Font
    total=$((total + 1))
    if install_font "CascadiaMono" "$CASCADIA_URL" "$fonts_dir"; then
        success=$((success + 1))
    else
        failed=$((failed + 1))
    fi
    echo ""
    
    # Install JetBrainsMono Nerd Font
    total=$((total + 1))
    if install_font "JetBrainsMono" "$JETBRAINS_URL" "$fonts_dir"; then
        success=$((success + 1))
    else
        failed=$((failed + 1))
    fi
    echo ""
    
    # Install VictorMono Font
    total=$((total + 1))
    if install_font "VictorMono" "$VICTOR_MONO_URL" "$fonts_dir"; then
        success=$((success + 1))
    else
        failed=$((failed + 1))
    fi
    echo ""
    
    # Update font cache on Linux
    update_font_cache "$fonts_dir"
    echo ""
    
    # Summary
    log_success "Font installation complete!"
    echo ""
    echo "Summary:"
    echo "  ✓ Installed: $success"
    echo "  ✗ Failed: $failed"
    echo "  Total: $total"
    echo ""
    
    # Next steps
    echo "Next steps:"
    echo ""
    echo "  1. Restart your terminal or IDE"
    echo ""
    echo "  2. Configure your terminal to use one of these fonts:"
    echo "     - CaskaydiaMono Nerd Font Mono"
    echo "     - JetBrainsMono Nerd Font Mono"
    echo "     - VictorMono Nerd Font"
    echo ""
    echo "  3. Enable font ligatures for better code rendering"
    echo ""
    echo "  4. Verify icons are displaying:"
    echo "     echo '    '"
    echo ""
    
    if [[ $(detect_os) == "macos" ]]; then
        echo "macOS: Fonts available in all applications immediately"
    else
        echo "Linux: If fonts don't appear, run: fc-cache -f -v"
    fi
    echo ""
}

main "$@"
