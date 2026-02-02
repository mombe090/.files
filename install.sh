#!/usr/bin/env bash
# Master installation script for dotfiles
# Prioritizes mise, falls back to OS package managers
set -e

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$DOTFILES_ROOT/scripts"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} ${BOLD}$1${NC}"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} ${BOLD}$1${NC}"; }

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
    elif [[ -f /etc/nixos/configuration.nix ]]; then
        echo "nixos"
    else
        echo "unknown"
    fi
}

# ===== CHECK PREREQUISITES =====
check_prerequisites() {
    log_step "Checking prerequisites..."
    
    local missing=()
    
    # Check for git
    if ! command -v git &> /dev/null; then
        missing+=("git")
    fi
    
    # Check for curl
    if ! command -v curl &> /dev/null; then
        missing+=("curl")
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing[*]}"
        log_info "Please install them first:"
        
        local os=$(detect_os)
        case $os in
            macos)
                echo "  xcode-select --install"
                ;;
            debian)
                echo "  sudo apt-get update && sudo apt-get install -y ${missing[*]}"
                ;;
            redhat)
                echo "  sudo yum install -y ${missing[*]}"
                ;;
            arch)
                echo "  sudo pacman -S --noconfirm ${missing[*]}"
                ;;
        esac
        exit 1
    fi
    
    log_success "Prerequisites satisfied"
}

# ===== BACKUP EXISTING CONFIGS =====
backup_configs() {
    log_step "Backing up existing configurations..."
    
    local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    local backed_up=false
    
    # Files to backup
    local files=(
        "$HOME/.zshrc"
        "$HOME/.bashrc"
        "$HOME/.gitconfig"
        "$HOME/.config/nvim"
        "$HOME/.config/alacritty"
        "$HOME/.config/ghostty"
        "$HOME/.config/starship.toml"
        "$HOME/.config/zsh"
    )
    
    for file in "${files[@]}"; do
        if [[ -e "$file" ]] && [[ ! -L "$file" ]]; then
            if [[ "$backed_up" == false ]]; then
                mkdir -p "$backup_dir"
                backed_up=true
            fi
            
            local relative_path="${file#$HOME/}"
            local backup_path="$backup_dir/$relative_path"
            mkdir -p "$(dirname "$backup_path")"
            cp -r "$file" "$backup_path"
            log_info "Backed up: $file"
        fi
    done
    
    if [[ "$backed_up" == true ]]; then
        log_success "Backup created at: $backup_dir"
        echo "$backup_dir" > "$HOME/.dotfiles-backup-location"
    else
        log_info "No existing configs to backup"
    fi
}

# ===== INSTALL PACKAGE =====
# Tries mise first, falls back to OS package manager
install_package() {
    local package="$1"
    local mise_name="${2:-$package}"  # mise name might differ from system package name
    
    # Check if already installed
    if command -v "$package" &> /dev/null; then
        log_info "$package already installed"
        return 0
    fi
    
    # Try mise first
    if command -v mise &> /dev/null; then
        log_info "Installing $package via mise..."
        if mise use -g "$mise_name@latest" 2>/dev/null; then
            log_success "$package installed via mise"
            return 0
        else
            log_warn "Failed to install $package via mise, trying system package manager..."
        fi
    fi
    
    # Fall back to system package manager
    local os=$(detect_os)
    log_info "Installing $package via system package manager..."
    
    case $os in
        macos)
            if command -v brew &> /dev/null; then
                brew install "$package"
            else
                log_error "Homebrew not found. Please install it first."
                return 1
            fi
            ;;
        debian)
            sudo apt-get update
            sudo apt-get install -y "$package"
            ;;
        redhat)
            sudo yum install -y "$package"
            ;;
        arch)
            sudo pacman -S --noconfirm "$package"
            ;;
        nixos)
            log_warn "On NixOS, please add $package to your configuration.nix"
            return 1
            ;;
        *)
            log_error "Unsupported OS for automatic installation"
            return 1
            ;;
    esac
    
    log_success "$package installed"
}

# ===== INSTALL HOMEBREW =====
install_homebrew() {
    local os=$(detect_os)
    
    # Only install Homebrew on macOS
    if [[ "$os" != "macos" ]]; then
        log_info "Skipping Homebrew installation (not macOS)"
        return 0
    fi
    
    log_step "Installing Homebrew..."
    if [[ -x "$SCRIPTS_DIR/install-homebrew.sh" ]]; then
        bash "$SCRIPTS_DIR/install-homebrew.sh"
    else
        log_warn "install-homebrew.sh not found or not executable"
    fi
}

# ===== INSTALL MISE =====
install_mise() {
    log_step "Installing mise..."
    if [[ -x "$SCRIPTS_DIR/install-mise.sh" ]]; then
        bash "$SCRIPTS_DIR/install-mise.sh"
        
        # Activate mise in current shell session for subsequent commands
        if command -v mise &> /dev/null; then
            eval "$(mise activate bash)" 2>/dev/null || true
        fi
    else
        log_warn "install-mise.sh not found or not executable"
    fi
}

# ===== INSTALL ESSENTIAL BUILD TOOLS =====
install_essentials() {
    log_step "Installing essential build tools..."
    if [[ -x "$SCRIPTS_DIR/install-essentials.sh" ]]; then
        bash "$SCRIPTS_DIR/install-essentials.sh"
    else
        log_warn "install-essentials.sh not found or not executable"
    fi
}

# ===== INSTALL CORE TOOLS =====
install_core_tools() {
    log_step "Installing core tools..."
    
    if [[ -x "$SCRIPTS_DIR/install-zsh.sh" ]]; then
        bash "$SCRIPTS_DIR/install-zsh.sh"
    fi
    
    if [[ -x "$SCRIPTS_DIR/install-stow.sh" ]]; then
        bash "$SCRIPTS_DIR/install-stow.sh"
    fi
    
    log_success "Core tools installed"
}

# ===== INSTALL OPTIONAL TOOLS =====
install_optional_tools() {
    log_step "Installing optional modern CLI tools..."
    
    # Define tools with their mise package names
    declare -A tools=(
        ["bat"]="bat"
        ["eza"]="eza"
        ["fzf"]="fzf"
        ["rg"]="ripgrep"
        ["fd"]="fd"
        ["zoxide"]="zoxide"
        ["starship"]="starship"
        ["nvim"]="neovim"
        ["direnv"]="direnv"
        ["delta"]="delta"
        ["jq"]="jq"
        ["yq"]="yq"
        ["btop"]="btop"
    )
    
    for cmd in "${!tools[@]}"; do
        install_package "$cmd" "${tools[$cmd]}" || log_warn "Failed to install $cmd (optional)"
    done
    
    log_success "Optional tools installation complete"
}

# ===== INSTALL DOTNET =====
install_dotnet() {
    log_step "Installing .NET SDK..."
    if [[ -x "$SCRIPTS_DIR/install-dotnet.sh" ]]; then
        AUTO_INSTALL=true bash "$SCRIPTS_DIR/install-dotnet.sh"
    else
        log_warn "install-dotnet.sh not found or not executable"
    fi
}

# ===== INSTALL PERSONAL TOOLS (OPTIONAL) =====
install_personal_tools() {
    log_step "Installing personal/optional tools..."
    echo ""
    
    # Clawdbot CLI - Optional personal tool
    if [[ -x "$SCRIPTS_DIR/install-clawdbot.sh" ]]; then
        log_info "Installing Clawdbot CLI..."
        bash "$SCRIPTS_DIR/install-clawdbot.sh" || log_warn "Failed to install clawdbot (optional)"
    fi
    
    # Add more personal tools here in the future
    # if [[ -x "$SCRIPTS_DIR/install-xyz.sh" ]]; then
    #     bash "$SCRIPTS_DIR/install-xyz.sh" || log_warn "Failed to install xyz (optional)"
    # fi
    
    log_success "Personal tools installation complete"
}

# ===== INSTALL MISE TOOLS FROM CONFIG =====
install_mise_tools() {
    log_step "Installing tools from mise config..."
    
    if command -v mise &> /dev/null; then
        mise install
        log_success "Mise tools installed"
    else
        log_info "mise not available, skipping mise tool installation"
    fi
}

# ===== STOW CONFIGURATIONS =====
stow_configs() {
    log_step "Stowing configurations..."
    if [[ -x "$SCRIPTS_DIR/manage-stow.sh" ]]; then
        bash "$SCRIPTS_DIR/manage-stow.sh" stow
    else
        log_warn "manage-stow.sh not found or not executable"
        log_info "Falling back to manual stow..."
        cd "$DOTFILES_ROOT"
        stow -v -t "$HOME" zsh bash mise zellij bat nvim starship wezterm nushell powershell 2>&1 | grep -v "BUG in find_stowed_path" || true
    fi
}


# ===== INSTALL MODERN FONTS =====
install_modern_fonts() {
    log_step "Installing modern fonts..."
    if [[ -x "$SCRIPTS_DIR/install-modern-fonts.sh" ]]; then
        bash "$SCRIPTS_DIR/install-modern-fonts.sh"
    else
        log_warn "install-modern-fonts.sh not found or not executable"
    fi
}

# ===== POST-INSTALL SETUP =====
post_install() {
    log_step "Running post-install setup..."
    echo ""
    
    # Create local gitconfig if it doesn't exist
    if [[ ! -f "$HOME/.gitconfig.local" ]]; then
        log_info "Creating ~/.gitconfig.local for personal git settings..."
        cat > "$HOME/.gitconfig.local" << 'EOF'
# Local git configuration (not tracked)
[user]
    name = Your Name
    email = your.email@example.com
EOF
        log_warn "Please edit ~/.gitconfig.local with your personal information"
    fi
    
    # Create env files if they don't exist
    if [[ ! -f "$HOME/.env" ]]; then
        touch "$HOME/.env"
        log_info "Created ~/.env for environment variables"
    fi
    
    if [[ ! -f "$HOME/.envrc" ]]; then
        touch "$HOME/.envrc"
        log_info "Created ~/.envrc for direnv"
    fi
    
    # Install JavaScript/TypeScript packages via bun (if available)
    echo ""
    log_info "Installing JavaScript/TypeScript packages..."
    if [[ -x "$SCRIPTS_DIR/install-js-packages.sh" ]]; then
        AUTO_CONFIRM=true bash "$SCRIPTS_DIR/install-js-packages.sh" --yes || true
    else
        log_warn "install-js-packages.sh not found or not executable"
    fi
    
    echo ""
    log_success "Post-install setup complete"
}

# ===== INTERACTIVE MENU =====
interactive_install() {
    echo ""
    echo -e "${BOLD}==================================${NC}"
    echo -e "${BOLD}   Dotfiles Installation Menu${NC}"
    echo -e "${BOLD}==================================${NC}"
    echo ""
    echo "Choose installation type:"
    echo ""
    echo "  1) Full installation (recommended)"
    echo "     - Installs everything including optional tools"
    echo ""
    echo "  2) Minimal installation"
    echo "     - Only core tools (zsh, stow, git configs)"
    echo ""
    echo "  3) Custom installation"
    echo "     - Choose what to install"
    echo ""
    echo "  4) Exit"
    echo ""
    read -p "Enter choice [1-4]: " choice
    
    case $choice in
        1)
            full_install
            ;;
        2)
            minimal_install
            ;;
        3)
            custom_install
            ;;
        4)
            log_info "Installation cancelled"
            exit 0
            ;;
        *)
            log_error "Invalid choice"
            exit 1
            ;;
    esac
}

# ===== FULL INSTALLATION =====
full_install() {
    log_info "Starting FULL installation..."
    echo ""
    
    check_prerequisites
    backup_configs
    install_homebrew
    install_mise
    install_essentials
    install_core_tools
    install_optional_tools
    install_modern_fonts
    install_dotnet true  # Pass 'true' for auto-install
    install_mise_tools
    stow_configs
    post_install
    
    show_completion_message
}

# ===== MINIMAL INSTALLATION =====
minimal_install() {
    log_info "Starting MINIMAL installation..."
    echo ""
    
    check_prerequisites
    backup_configs
    install_homebrew
    install_core_tools
    
    # Only stow essential configs (zsh and git)
    log_step "Stowing minimal configurations..."
    if [[ -x "$SCRIPTS_DIR/manage-stow.sh" ]]; then
        bash "$SCRIPTS_DIR/manage-stow.sh" stow zsh git
    else
        cd "$DOTFILES_ROOT"
        stow -v -t "$HOME" zsh git 2>&1 | grep -v "BUG in find_stowed_path" || true
    fi
    
    post_install
    
    show_completion_message
}

# ===== CUSTOM INSTALLATION =====
custom_install() {
    log_info "Starting CUSTOM installation..."
    echo ""
    
    local os=$(detect_os)
    
    check_prerequisites
    backup_configs
    
    # Only ask about Homebrew on macOS
    if [[ "$os" == "macos" ]]; then
        read -p "Install Homebrew? [Y/n]: " install_brew
        if [[ ! "$install_brew" =~ ^[Nn]$ ]]; then
            install_homebrew
        fi
    fi
    
    read -p "Install mise? [Y/n]: " install_mise_choice
    if [[ ! "$install_mise_choice" =~ ^[Nn]$ ]]; then
        install_mise
    fi
    
    read -p "Install essential build tools (gcc, make, cmake, etc.)? [Y/n]: " install_essentials_choice
    if [[ ! "$install_essentials_choice" =~ ^[Nn]$ ]]; then
        install_essentials
    fi
    
    read -p "Install core tools (zsh, stow)? [Y/n]: " install_core
    if [[ ! "$install_core" =~ ^[Nn]$ ]]; then
        install_core_tools
    fi
    
    read -p "Install optional CLI tools (bat, eza, fzf, etc.)? [Y/n]: " install_optional
    if [[ ! "$install_optional" =~ ^[Nn]$ ]]; then
        install_optional_tools
    fi
    
    read -p "Install modern fonts (CascadiaMono, JetBrainsMono, VictorMono)? [Y/n]: " install_fonts
    if [[ ! "$install_fonts" =~ ^[Nn]$ ]]; then
        install_modern_fonts
    fi
    
    read -p "Install .NET SDK? [Y/n]: " install_dotnet_choice
    if [[ ! "$install_dotnet_choice" =~ ^[Nn]$ ]]; then
        install_dotnet
    fi
    
    read -p "Install personal tools (clawdbot, etc.)? [y/N]: " install_personal
    if [[ "$install_personal" =~ ^[Yy]$ ]]; then
        install_personal_tools
    fi
    
    read -p "Install mise tools from config? [Y/n]: " install_mise_tools_choice
    if [[ ! "$install_mise_tools_choice" =~ ^[Nn]$ ]]; then
        install_mise_tools
    fi
    
    read -p "Stow configurations? [Y/n]: " stow_choice
    if [[ ! "$stow_choice" =~ ^[Nn]$ ]]; then
        stow_configs
    fi
    
    post_install
    
    show_completion_message
}

# ===== COMPLETION MESSAGE =====
show_completion_message() {
    echo ""
    echo -e "${GREEN}==================================${NC}"
    echo -e "${GREEN}✓ Installation Complete!${NC}"
    echo -e "${GREEN}==================================${NC}"
    echo ""
    echo "Next steps:"
    echo ""
    echo "  1. Restart your shell to load new configurations:"
    echo "     exec \$SHELL -l"
    echo ""
    echo "  2. Or source your shell config:"
    echo "     source ~/.zshrc"
    echo ""
    echo "  3. If you installed mise, install tools from config:"
    echo "     mise install"
    echo ""
    echo "  4. Edit ~/.gitconfig.local with your personal git information"
    echo ""
    echo "  5. Verify installations:"
    echo "     gcc --version     # C compiler (build-essential)"
    echo "     make --version    # Build tool"
    echo "     dotnet --version  # .NET SDK"
    echo "     bun --version     # Bun runtime"
    echo "     tsc --version     # TypeScript (after shell restart)"
    echo "     # If 'command not found', restart shell first!"
    echo ""
    echo "  6. Verify bun global packages are in PATH:"
    echo "     echo \$PATH | grep '.bun/bin'  # Should show ~/.bun/bin"
    echo ""
    echo "  7. Install/update JavaScript packages:"
    echo "     ./scripts/install-js-packages.sh           # Professional packages only"
    echo "     ./scripts/install-js-packages.sh --personal # Personal packages"
    echo "     ./scripts/install-js-packages.sh --all      # Both pro & personal"
    echo ""
    echo "  8. Install modern fonts (if not already installed):"
    echo "     ./scripts/install-modern-fonts.sh           # CascadiaMono, JetBrainsMono, VictorMono"
    echo "     ./scripts/install-modern-fonts.sh --list    # List installed fonts"
    echo ""
    echo "  9. Install essential build tools (if not already installed):"
    echo "     ./scripts/install-essentials.sh             # gcc, make, cmake, dev libraries"
    echo "     ./scripts/install-essentials.sh --list      # List installed tools"
    echo ""
    echo "  10. Optional: Install personal tools (not included by default):"
    echo "      ./scripts/install-clawdbot.sh              # Clawdbot CLI"
    echo ""
    
    if [[ -f "$HOME/.dotfiles-backup-location" ]]; then
        local backup_location=$(cat "$HOME/.dotfiles-backup-location")
        echo "Backup of old configs: $backup_location"
        echo ""
    fi
    
    echo "For troubleshooting:"
    echo "  - .NET issues: cat $DOTFILES_ROOT/DOTNET_TROUBLESHOOTING.md"
    echo "  - JS packages: cat $DOTFILES_ROOT/scripts/INSTALL_JS_PACKAGES_GUIDE.md"
    echo "  - General help: cat $DOTFILES_ROOT/README.md"
    echo ""
}

# ===== MAIN =====
main() {
    # Check if running with arguments
    if [[ $# -gt 0 ]]; then
        case "$1" in
            --full|-f)
                full_install
                ;;
            --minimal|-m)
                minimal_install
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --full, -f      Full installation (all tools)"
                echo "  --minimal, -m   Minimal installation (core only)"
                echo "  --help, -h      Show this help message"
                echo ""
                echo "Run without arguments for interactive menu."
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    else
        # Interactive mode
        interactive_install
    fi
}

main "$@"
