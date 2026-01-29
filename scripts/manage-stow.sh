#!/usr/bin/env bash
# Manage GNU Stow packages for dotfiles
# Usage: ./scripts/manage-stow.sh [OPTIONS] [PACKAGES...]

set -e

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} ${BOLD}$1${NC}"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} ${BOLD}$1${NC}"; }

# Default packages to stow
DEFAULT_PACKAGES=(
    "zsh"
    "mise"
    "zellij"
    "bat"
    "nvim"
    "starship"
)

# All available packages (auto-detect from directories)
get_available_packages() {
    local packages=()
    for dir in "$DOTFILES_ROOT"/*; do
        if [[ -d "$dir" ]] && [[ ! "$dir" =~ /\. ]] && [[ "$(basename "$dir")" != "scripts" ]]; then
            packages+=("$(basename "$dir")")
        fi
    done
    printf '%s\n' "${packages[@]}" | sort
}

# ===== CHECK STOW INSTALLATION =====
check_stow() {
    if ! command -v stow &> /dev/null; then
        log_error "GNU Stow is not installed"
        log_info "Install it first:"
        echo ""
        echo "  # Via package manager"
        echo "  sudo apt install stow      # Debian/Ubuntu"
        echo "  sudo yum install stow      # RHEL/Fedora"
        echo "  brew install stow          # macOS"
        echo ""
        echo "  # Or use the install script"
        echo "  ./scripts/install-stow.sh"
        echo ""
        exit 1
    fi
}

# ===== STOW PACKAGES =====
stow_packages() {
    local packages=("$@")
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        packages=("${DEFAULT_PACKAGES[@]}")
        log_info "No packages specified, using defaults: ${packages[*]}"
    fi
    
    log_step "Stowing packages..."
    echo ""
    
    cd "$DOTFILES_ROOT"
    
    local stowed=0
    local failed=0
    local skipped=0
    
    for pkg in "${packages[@]}"; do
        if [[ ! -d "$DOTFILES_ROOT/$pkg" ]]; then
            log_warn "Package '$pkg' not found in $DOTFILES_ROOT (skipping)"
            ((skipped++))
            continue
        fi
        
        log_info "Stowing: $pkg"
        
        # Stow with verbose output, filter out the BUG message
        if stow -v -t "$HOME" "$pkg" 2>&1 | grep -v "BUG in find_stowed_path"; then
            log_success "$pkg stowed"
            ((stowed++))
        else
            log_error "Failed to stow $pkg"
            ((failed++))
        fi
        
        echo ""
    done
    
    # Summary
    echo ""
    log_success "Stow operation complete!"
    echo ""
    echo "Summary:"
    echo "  ✓ Stowed: $stowed"
    echo "  ✗ Failed: $failed"
    echo "  → Skipped: $skipped"
    echo "  Total: ${#packages[@]}"
    echo ""
}

# ===== RESTOW PACKAGES (update symlinks) =====
restow_packages() {
    local packages=("$@")
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        packages=("${DEFAULT_PACKAGES[@]}")
        log_info "No packages specified, using defaults: ${packages[*]}"
    fi
    
    log_step "Re-stowing packages (update symlinks)..."
    echo ""
    
    cd "$DOTFILES_ROOT"
    
    for pkg in "${packages[@]}"; do
        if [[ ! -d "$DOTFILES_ROOT/$pkg" ]]; then
            log_warn "Package '$pkg' not found (skipping)"
            continue
        fi
        
        log_info "Re-stowing: $pkg"
        stow -R -v -t "$HOME" "$pkg" 2>&1 | grep -v "BUG in find_stowed_path" || true
        log_success "$pkg re-stowed"
        echo ""
    done
    
    log_success "Re-stow complete!"
}

# ===== UNSTOW PACKAGES (remove symlinks) =====
unstow_packages() {
    local packages=("$@")
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        packages=("${DEFAULT_PACKAGES[@]}")
        log_info "No packages specified, using defaults: ${packages[*]}"
    fi
    
    log_step "Unstowing packages (remove symlinks)..."
    echo ""
    
    cd "$DOTFILES_ROOT"
    
    for pkg in "${packages[@]}"; do
        if [[ ! -d "$DOTFILES_ROOT/$pkg" ]]; then
            log_warn "Package '$pkg' not found (skipping)"
            continue
        fi
        
        log_info "Unstowing: $pkg"
        stow -D -v -t "$HOME" "$pkg" 2>&1 | grep -v "BUG in find_stowed_path" || true
        log_success "$pkg unstowed"
        echo ""
    done
    
    log_success "Unstow complete!"
}

# ===== LIST PACKAGES =====
list_packages() {
    log_step "Available packages in $DOTFILES_ROOT:"
    echo ""
    
    local available=($(get_available_packages))
    
    for pkg in "${available[@]}"; do
        # Check if it's a default package
        if [[ " ${DEFAULT_PACKAGES[*]} " =~ " ${pkg} " ]]; then
            echo -e "  ${GREEN}✓${NC} $pkg ${BLUE}(default)${NC}"
        else
            echo "  - $pkg"
        fi
    done
    
    echo ""
    log_info "Default packages: ${DEFAULT_PACKAGES[*]}"
}

# ===== SHOW STATUS =====
show_status() {
    log_step "Stow status for default packages:"
    echo ""
    
    cd "$DOTFILES_ROOT"
    
    for pkg in "${DEFAULT_PACKAGES[@]}"; do
        if [[ ! -d "$DOTFILES_ROOT/$pkg" ]]; then
            echo -e "  ${RED}✗${NC} $pkg ${RED}(not found)${NC}"
            continue
        fi
        
        # Check if package is stowed by looking for symlinks
        local stowed=false
        local config_file=""
        
        # Check common config locations based on package
        case "$pkg" in
            zsh)
                config_file="$HOME/.zshrc"
                ;;
            mise)
                config_file="$HOME/.config/mise/config.toml"
                ;;
            zellij)
                config_file="$HOME/.config/zellij/config.kdl"
                ;;
            bat)
                config_file="$HOME/.config/bat/config"
                ;;
            nvim)
                config_file="$HOME/.config/nvim/init.lua"
                ;;
            starship)
                config_file="$HOME/.config/starship.toml"
                ;;
        esac
        
        if [[ -n "$config_file" ]] && [[ -L "$config_file" ]]; then
            local target=$(readlink "$config_file")
            if [[ "$target" == *"$pkg"* ]]; then
                stowed=true
            fi
        fi
        
        if [[ "$stowed" == true ]]; then
            echo -e "  ${GREEN}✓${NC} $pkg ${GREEN}(stowed)${NC}"
        else
            echo -e "  ${YELLOW}○${NC} $pkg ${YELLOW}(not stowed)${NC}"
        fi
    done
    
    echo ""
}

# ===== SHOW HELP =====
show_help() {
    cat << EOF
Usage: $0 [COMMAND] [OPTIONS] [PACKAGES...]

Manage GNU Stow packages for dotfiles.

Commands:
  stow, -s              Stow packages (create symlinks)
  restow, -r            Re-stow packages (update symlinks)
  unstow, -u            Unstow packages (remove symlinks)
  list, -l              List available packages
  status                Show stow status for default packages
  help, -h              Show this help message

Options:
  [PACKAGES...]         Specific packages to stow/unstow
                        If not specified, uses default packages

Default Packages:
  ${DEFAULT_PACKAGES[*]}

Examples:
  # Stow default packages
  $0 stow

  # Stow specific packages
  $0 stow zsh nvim git

  # Re-stow all defaults (update symlinks)
  $0 restow

  # Unstow a specific package
  $0 unstow zellij

  # List all available packages
  $0 list

  # Show stow status
  $0 status

Package Structure:
  Each package is a directory containing dotfiles to be symlinked.
  Example:
    zsh/
      .zshrc -> ~/zshrc
      .config/
        zsh/ -> ~/.config/zsh/

Notes:
  - Stow creates symlinks from package directories to your home directory
  - Use 'restow' after updating dotfiles to refresh symlinks
  - Use 'unstow' before removing packages

EOF
}

# ===== MAIN =====
main() {
    local command="${1:-stow}"
    shift || true
    
    # Parse command
    case "$command" in
        stow|-s)
            check_stow
            stow_packages "$@"
            ;;
        restow|-r)
            check_stow
            restow_packages "$@"
            ;;
        unstow|-u)
            check_stow
            unstow_packages "$@"
            ;;
        list|-l)
            list_packages
            ;;
        status)
            show_status
            ;;
        help|-h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown command: $command"
            echo ""
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

main "$@"
