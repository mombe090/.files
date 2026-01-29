#!/usr/bin/env bash
# Install JavaScript/TypeScript packages globally using bun
# Reads package list from scripts/config/js.pkg.yml

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config/js.pkg.yml"

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

# ===== CHECK BUN INSTALLATION =====
check_bun() {
    if ! command -v bun &> /dev/null; then
        log_warn "bun is not installed - skipping JavaScript packages"
        log_info "To install JavaScript packages later:"
        echo ""
        echo "  1. Install bun:"
        echo "     curl -fsSL https://bun.sh/install | bash"
        echo ""
        echo "  2. Restart shell:"
        echo "     exec \$SHELL -l"
        echo ""
        echo "  3. Install packages:"
        echo "     ./scripts/install-js-packages.sh"
        echo ""
        exit 0
    fi
    
    local bun_version=$(bun --version)
    log_info "Using bun version: $bun_version"
}

# ===== CHECK CONFIG FILE =====
check_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "Config file not found: $CONFIG_FILE"
        log_info "Creating default config file..."
        mkdir -p "$SCRIPT_DIR/config"
        create_default_config
        log_success "Created default config at: $CONFIG_FILE"
        log_info "Edit the file to customize packages, then re-run this script"
        exit 0
    fi
}

# ===== CREATE DEFAULT CONFIG =====
create_default_config() {
    cat > "$CONFIG_FILE" << 'EOF'
# JavaScript/TypeScript packages to install globally via bun
# Format: YAML list of package names

packages:
  # Package managers & tools
  - pnpm
  - yarn
  
  # TypeScript & Type checking
  - typescript
  - tsx
  - ts-node
  - "@types/node"
  
  # Linting & Formatting
  - eslint
  - prettier
  
  # Build tools
  - vite
  - esbuild
  - tsup
  
  # Testing
  - vitest
  - jest
  
  # Development tools
  - nodemon
  - concurrently
  - rimraf
  - dotenv-cli
  
  # Documentation
  - typedoc
  - jsdoc

# Optional: Packages to install only if specified
# Uncomment to enable
# optional:
#   - next
#   - nuxt
#   - "@angular/cli"
#   - "@vue/cli"
#   - create-react-app
#   - gatsby-cli
EOF
}

# ===== PARSE YAML FILE =====
parse_yaml() {
    # Simple YAML parser for package list
    # Extracts packages from "packages:" section
    
    local in_packages=false
    local packages=()
    
    while IFS= read -r line; do
        # Remove leading/trailing whitespace
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # Skip empty lines and comments
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^# ]] && continue
        
        # Check for packages section
        if [[ "$line" == "packages:" ]]; then
            in_packages=true
            continue
        fi
        
        # Check for optional section (stop parsing packages)
        if [[ "$line" == "optional:" ]]; then
            in_packages=false
            continue
        fi
        
        # Parse package entries (lines starting with -)
        if [[ "$in_packages" == true ]] && [[ "$line" =~ ^-[[:space:]]* ]]; then
            # Extract package name (remove leading -, whitespace, and quotes)
            local pkg=$(echo "$line" | sed 's/^-[[:space:]]*//;s/^["'\'']\(.*\)["'\'']$/\1/')
            [[ -n "$pkg" ]] && packages+=("$pkg")
        fi
    done < "$CONFIG_FILE"
    
    # Return packages as array
    printf '%s\n' "${packages[@]}"
}

# ===== INSTALL PACKAGES =====
install_packages() {
    log_step "Reading package list from: $CONFIG_FILE"
    
    # Parse YAML and get packages
    local packages=($(parse_yaml))
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        log_warn "No packages found in config file"
        exit 0
    fi
    
    log_info "Found ${#packages[@]} packages to install"
    echo ""
    
    # Show package list
    log_info "Packages:"
    for pkg in "${packages[@]}"; do
        echo "  - $pkg"
    done
    echo ""
    
    # Ask for confirmation unless --yes flag
    if [[ "$AUTO_CONFIRM" != "true" ]]; then
        read -p "Install these packages globally with bun? [Y/n]: " confirm
        if [[ "$confirm" =~ ^[Nn]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi
    
    log_step "Installing packages globally..."
    echo ""
    
    local installed=0
    local failed=0
    local skipped=0
    
    for pkg in "${packages[@]}"; do
        log_info "Installing: $pkg"
        
        # Check if already installed
        if bun pm ls -g 2>/dev/null | grep -q "^$pkg@"; then
            log_warn "$pkg is already installed (skipping)"
            ((skipped++))
            continue
        fi
        
        # Install package
        if bun add -g "$pkg" &> /dev/null; then
            log_success "$pkg installed"
            ((installed++))
        else
            log_error "Failed to install $pkg"
            ((failed++))
        fi
        
        echo ""
    done
    
    # Summary
    echo ""
    log_success "Installation complete!"
    echo ""
    echo "Summary:"
    echo "  ✓ Installed: $installed"
    echo "  ⊗ Failed: $failed"
    echo "  → Skipped: $skipped"
    echo "  Total: ${#packages[@]}"
    echo ""
}

# ===== LIST INSTALLED PACKAGES =====
list_packages() {
    log_step "Listing globally installed packages..."
    echo ""
    
    if command -v bun &> /dev/null; then
        bun pm ls -g
    else
        log_error "bun is not installed"
        exit 1
    fi
}

# ===== UPDATE ALL PACKAGES =====
update_packages() {
    log_step "Updating globally installed packages..."
    echo ""
    
    # Parse packages from config
    local packages=($(parse_yaml))
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        log_warn "No packages found in config file"
        exit 0
    fi
    
    log_info "Updating ${#packages[@]} packages..."
    echo ""
    
    for pkg in "${packages[@]}"; do
        log_info "Updating: $pkg"
        bun add -g "$pkg@latest" || log_warn "Failed to update $pkg"
        echo ""
    done
    
    log_success "Update complete!"
}

# ===== SHOW HELP =====
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Install JavaScript/TypeScript packages globally using bun.
Reads package list from: $CONFIG_FILE

Options:
  --install, -i       Install packages from config (default)
  --list, -l          List globally installed packages
  --update, -u        Update all packages to latest versions
  --yes, -y           Auto-confirm installation (no prompts)
  --help, -h          Show this help message

Examples:
  # Install packages from config
  $0

  # Install without confirmation prompt
  $0 --yes

  # List installed packages
  $0 --list

  # Update all packages
  $0 --update

Config file format (YAML):
  packages:
    - typescript
    - prettier
    - eslint
    - vite

EOF
}

# ===== MAIN =====
main() {
    local action="install"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --install|-i)
                action="install"
                shift
                ;;
            --list|-l)
                action="list"
                shift
                ;;
            --update|-u)
                action="update"
                shift
                ;;
            --yes|-y)
                AUTO_CONFIRM="true"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    # Execute action
    case $action in
        install)
            check_bun
            check_config
            install_packages
            ;;
        list)
            list_packages
            ;;
        update)
            check_bun
            check_config
            update_packages
            ;;
    esac
}

main "$@"
