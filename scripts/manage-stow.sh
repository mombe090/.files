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

# ===== BACKUP CONFLICTING FILES =====
backup_conflicts() {
    local pkg="$1"
    local backup_dir="$HOME/.dotfiles-stow-backup-$(date +%Y%m%d-%H%M%S)"
    local backed_up=false
    
    # Special handling for zsh package - only backup .zshrc
    if [[ "$pkg" == "zsh" ]]; then
        local zshrc="$HOME/.zshrc"
        
        # Only backup if .zshrc exists and is NOT a symlink to our dotfiles
        if [[ -f "$zshrc" ]] && [[ ! -L "$zshrc" ]]; then
            mkdir -p "$backup_dir"
            cp -a "$zshrc" "$backup_dir/.zshrc"
            log_warn "Backed up: ~/.zshrc"
            rm -f "$zshrc"
            backed_up=true
        elif [[ -L "$zshrc" ]]; then
            # Resolve the symlink to absolute path
            local resolved=$(readlink -f "$zshrc" 2>/dev/null || echo "")
            # If symlink exists but doesn't point to our dotfiles, back it up
            if [[ -n "$resolved" ]] && [[ "$resolved" != *"$DOTFILES_ROOT/zsh"* ]]; then
                local link_target=$(readlink "$zshrc")
                mkdir -p "$backup_dir"
                echo "$link_target" > "$backup_dir/.zshrc.symlink-info"
                log_warn "Backed up symlink: ~/.zshrc → $link_target"
                rm -f "$zshrc"
                backed_up=true
            fi
        fi
        
        # For .config/zsh, only backup if it's NOT a symlink to our dotfiles
        local config_zsh="$HOME/.config/zsh"
        if [[ -d "$config_zsh" ]] && [[ ! -L "$config_zsh" ]]; then
            # It's a real directory, backup it
            mkdir -p "$backup_dir/.config"
            cp -a "$config_zsh" "$backup_dir/.config/"
            log_warn "Backed up: ~/.config/zsh (was a directory)"
            rm -rf "$config_zsh"
            backed_up=true
        elif [[ -L "$config_zsh" ]]; then
            # Resolve the symlink to absolute path
            local resolved=$(readlink -f "$config_zsh" 2>/dev/null || echo "")
            # If symlink exists but doesn't point to our dotfiles, back it up
            if [[ -n "$resolved" ]] && [[ "$resolved" != *"$DOTFILES_ROOT/zsh"* ]]; then
                local link_target=$(readlink "$config_zsh")
                mkdir -p "$backup_dir/.config"
                echo "$link_target" > "$backup_dir/.config/zsh.symlink-info"
                log_warn "Backed up symlink: ~/.config/zsh → $link_target"
                rm -f "$config_zsh"
                backed_up=true
            fi
        fi
        
        if [[ "$backed_up" == true ]]; then
            echo "$backup_dir" >> "$HOME/.dotfiles-backup-location"
            log_success "Backup complete: $backup_dir"
        fi
        return 0
    fi
    
    # General backup logic for other packages
    local files_to_stow=$(cd "$DOTFILES_ROOT/$pkg" && find . -type f -o -type l 2>/dev/null | sed 's|^\./||')
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        local target="$HOME/$file"
        
        # Skip if target doesn't exist
        [[ ! -e "$target" ]] && continue
        
        # If target is a symlink, check where it points
        if [[ -L "$target" ]]; then
            local link_target=$(readlink "$target")
            local resolved_target=$(readlink -f "$target" 2>/dev/null || echo "")
            
            # Skip if symlink already points to our dotfiles
            if [[ "$link_target" == *"$DOTFILES_ROOT/$pkg"* ]] || [[ "$resolved_target" == *"$DOTFILES_ROOT/$pkg"* ]]; then
                continue
            fi
            
            # Symlink exists but points elsewhere, back it up
            if [[ "$backed_up" == false ]]; then
                mkdir -p "$backup_dir"
                backed_up=true
                log_info "Creating backup at: $backup_dir"
            fi
            
            local backup_target="$backup_dir/${target#$HOME/}.symlink-info"
            local backup_target_dir=$(dirname "$backup_target")
            mkdir -p "$backup_target_dir"
            echo "$link_target" > "$backup_target"
            log_warn "Backed up symlink: ~/${target#$HOME/} → $link_target"
            rm -f "$target"
            
        # If target is a regular file or directory (not a symlink)
        elif [[ -f "$target" ]] || [[ -d "$target" ]]; then
            # Create backup directory if needed
            if [[ "$backed_up" == false ]]; then
                mkdir -p "$backup_dir"
                backed_up=true
                log_info "Creating backup at: $backup_dir"
            fi
            
            # Backup the file/directory
            local backup_target="$backup_dir/${target#$HOME/}"
            local backup_target_dir=$(dirname "$backup_target")
            
            mkdir -p "$backup_target_dir"
            cp -a "$target" "$backup_target"
            log_warn "Backed up: ~/${target#$HOME/}"
            
            # Remove the original so stow can create symlink
            rm -rf "$target"
        fi
    done <<< "$files_to_stow"
    
    if [[ "$backed_up" == true ]]; then
        echo "$backup_dir" >> "$HOME/.dotfiles-backup-location"
        log_success "Backup complete: $backup_dir"
    fi
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
            skipped=$((skipped + 1))
            continue
        fi
        
        log_info "Stowing: $pkg"
        
        # Check for conflicts and backup if needed
        backup_conflicts "$pkg"
        
        # Stow the package (suppress BUG message but keep other output)
        stow -v -t "$HOME" "$pkg" 2>&1 | grep -v "BUG in find_stowed_path" || true
        
        # Check if stow succeeded by running it again without verbose
        if stow -t "$HOME" "$pkg" 2>/dev/null; then
            log_success "$pkg stowed"
            stowed=$((stowed + 1))
        else
            log_error "Failed to stow $pkg"
            failed=$((failed + 1))
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
