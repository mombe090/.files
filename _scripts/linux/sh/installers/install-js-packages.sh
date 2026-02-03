#!/usr/bin/env bash
# Install JavaScript/TypeScript packages globally using bun
# Reads package list from scripts/config/js.pkg.yml (professional) and js.pkg.personal.yml (personal)

set -e

# Activate mise if available (needed for bun installed via mise)
if command -v mise &> /dev/null; then
  eval "$(mise activate bash)"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE_PRO="$SCRIPT_DIR/config/js.pkg.yml"
CONFIG_FILE_PERSONAL="$SCRIPT_DIR/config/js.pkg.personal.yml"

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
    local config_type="$1"  # "pro" or "personal"
    local config_file=""
    
    if [[ "$config_type" == "personal" ]]; then
        config_file="$CONFIG_FILE_PERSONAL"
    else
        config_file="$CONFIG_FILE_PRO"
    fi
    
    if [[ ! -f "$config_file" ]]; then
        log_warn "Config file not found: $config_file"
        log_info "Creating default config file..."
        mkdir -p "$SCRIPT_DIR/config"
        create_default_config "$config_type"
        log_success "Created default config at: $config_file"
        log_info "Edit the file to customize packages, then re-run this script"
        return 1
    fi
    
    echo "$config_file"
}

# ===== CREATE DEFAULT CONFIG =====
create_default_config() {
    local config_type="${1:-pro}"  # Default to professional
    
    if [[ "$config_type" == "personal" ]]; then
        # Personal/optional packages
        cat > "$CONFIG_FILE_PERSONAL" << 'EOF'
# Personal JavaScript/TypeScript packages (optional)
# These packages are for personal projects and won't be installed on company PCs
# Format: YAML list of package names

packages:
  # Personal CLI tools
  - vercel
  - netlify-cli
  - firebase-tools
  
  # Personal frameworks/tools
  - next
  - nuxt
  - "@angular/cli"
  - "@vue/cli"
  - create-react-app
  - gatsby-cli
  - astro
  
  # Personal development
  - ngrok
  - localtunnel
  - pm2
  
  # Add your personal packages here
  # - your-package-name

EOF
    else
        # Professional/work packages
        cat > "$CONFIG_FILE_PRO" << 'EOF'
# Professional JavaScript/TypeScript packages
# These packages are safe to install on any machine (personal or company PC)
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
  
  # CLI tools
  - http-server
  - serve
  - npm-check-updates
  - depcheck
  
  # Documentation
  - typedoc
  - jsdoc

EOF
    fi
}

# ===== PARSE YAML FILE =====
parse_yaml() {
    local config_file="$1"
    
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
    done < "$config_file"
    
    # Return packages as array
    printf '%s\n' "${packages[@]}"
}

# ===== INSTALL PACKAGES =====
install_packages() {
    local config_type="${1:-pro}"  # Default to professional packages
    
    log_step "Installing $config_type packages..."
    
    # Check config file exists (creates if missing)
    local config_file=$(check_config "$config_type")
    if [[ -z "$config_file" ]]; then
        log_info "Config file was just created. Edit it and re-run this script."
        return 0
    fi
    
    log_info "Reading package list from: $config_file"
    
    # Parse YAML and get packages
    local packages=($(parse_yaml "$config_file"))
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        log_warn "No packages found in config file"
        return 0
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
        read -p "Install these $config_type packages globally with bun? [Y/n]: " confirm
        if [[ "$confirm" =~ ^[Nn]$ ]]; then
            log_info "Installation cancelled"
            return 0
        fi
    fi
    
    log_step "Installing $config_type packages globally..."
    echo ""
    
    local installed=0
    local failed=0
    local skipped=0
    
    for pkg in "${packages[@]}"; do
        log_info "Installing: $pkg"
        
        # Check if already installed
        if bun pm ls -g 2>/dev/null | grep -q "^$pkg@"; then
            log_warn "$pkg is already installed (skipping)"
            skipped=$((skipped + 1))
            continue
        fi
        
        # Install package
        if bun add -g "$pkg" &> /dev/null; then
            log_success "$pkg installed"
            installed=$((installed + 1))
        else
            log_error "Failed to install $pkg"
            failed=$((failed + 1))
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
    local config_type="${1:-pro}"  # Default to professional packages
    
    log_step "Updating $config_type packages..."
    echo ""
    
    # Check config file exists
    local config_file=$(check_config "$config_type")
    if [[ -z "$config_file" ]]; then
        log_info "Config file was just created. Edit it and re-run this script."
        return 0
    fi
    
    # Parse packages from config
    local packages=($(parse_yaml "$config_file"))
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        log_warn "No packages found in config file"
        return 0
    fi
    
    log_info "Updating ${#packages[@]} $config_type packages..."
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
Supports two separate config files:
  - Professional: $CONFIG_FILE_PRO (safe for work/company PCs)
  - Personal: $CONFIG_FILE_PERSONAL (personal projects only)

Options:
  --install, -i       Install professional packages (default)
  --personal, -p      Install personal packages
  --all, -a           Install both professional AND personal packages
  --list, -l          List globally installed packages
  --update, -u        Update professional packages to latest versions
  --update-personal   Update personal packages to latest versions
  --yes, -y           Auto-confirm installation (no prompts)
  --help, -h          Show this help message

Examples:
  # Install professional packages only (safe for work PC)
  $0
  $0 --install

  # Install personal packages only
  $0 --personal

  # Install both professional AND personal packages
  $0 --all

  # Install without confirmation prompt
  $0 --yes

  # List installed packages
  $0 --list

  # Update professional packages
  $0 --update

  # Update personal packages
  $0 --update-personal

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
    local config_type="pro"
    local install_all=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --install|-i)
                action="install"
                config_type="pro"
                shift
                ;;
            --personal|-p)
                action="install"
                config_type="personal"
                shift
                ;;
            --all|-a)
                action="install"
                install_all=true
                shift
                ;;
            --list|-l)
                action="list"
                shift
                ;;
            --update|-u)
                action="update"
                config_type="pro"
                shift
                ;;
            --update-personal)
                action="update"
                config_type="personal"
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
            if [[ "$install_all" == true ]]; then
                log_info "Installing BOTH professional and personal packages"
                echo ""
                install_packages "pro"
                echo ""
                echo "================================================"
                echo ""
                install_packages "personal"
            else
                install_packages "$config_type"
            fi
            ;;
        list)
            list_packages
            ;;
        update)
            check_bun
            update_packages "$config_type"
            ;;
    esac
}

main "$@"
