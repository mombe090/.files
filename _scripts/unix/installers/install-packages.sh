#!/usr/bin/env bash
# =============================================================================
# Package Installation Parser
# =============================================================================
# Parses YAML package configuration files and installs packages based on the
# detected OS and package manager. Supports category-based installation,
# optional packages, and dry-run mode.
#
# Usage:
#   bash install-packages.sh                    # Auto-detect OS, install all
#   bash install-packages.sh --minimal          # Install essentials only
#   bash install-packages.sh --category dev     # Install specific category
#   bash install-packages.sh --dry-run          # Show what would be installed
#   bash install-packages.sh --config path.yml  # Use specific config file
#   bash install-packages.sh --help             # Show this help
# =============================================================================

set -euo pipefail

# Get script directory and dotfiles root (3 levels deep: _scripts/unix/installers/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Source Unix libraries
source "$DOTFILES_ROOT/_scripts/unix/lib/init.sh"

# =============================================================================
# Configuration
# =============================================================================

CONFIG_DIR="$DOTFILES_ROOT/_scripts/configs/unix/packages"
DRY_RUN=false
MINIMAL_MODE=false
CATEGORY_FILTER=""
CONFIG_FILE=""
SKIP_OPTIONAL=false
PACKAGE_TYPE="pro"  # Default to professional packages

# =============================================================================
# Functions
# =============================================================================

show_help() {
    cat << EOF
Package Installation Parser

USAGE:
    bash install-packages.sh [OPTIONS]

OPTIONS:
    --pro                  Install professional/work-safe packages (default)
    --perso                Install personal packages (pro + personal tools)
    --minimal              Install only essential packages (skip optional)
    --full                 Install all packages including optional ones
    --category <name>      Install only packages from specific category
    --config <file>        Use specific YAML config file
    --skip-optional        Skip packages marked as optional
    --dry-run              Show what would be installed without installing
    --help                 Show this help message

PACKAGE TYPES:
    pro                   Professional/work-safe packages for company PCs
                          Supported: macOS (Homebrew), Ubuntu/Debian (APT)
    perso                 Personal packages (includes pro + personal tools)
                          Supported: macOS (Homebrew), Ubuntu/Debian (APT),
                                    Fedora/RHEL (DNF), Arch Linux (Pacman)

CATEGORIES:
    essentials            Core utilities (git, curl, stow, etc.)
    development           Development tools (neovim, tmux, fzf, etc.)
    build_tools           Build systems (cmake, ninja, etc.)
    libraries             Development libraries (openssl, libffi, etc.)
    cloud                 DevOps tools (kubectl, helm, terraform, etc.)
    fonts                 Programming fonts
    shell_tools           Modern CLI tools (mise)
    monitoring            Resource monitors (mise)

EXAMPLES:
    # Install professional packages (default)
    bash install-packages.sh

    # Install personal packages
    bash install-packages.sh --perso

    # Install only essentials (minimal install)
    bash install-packages.sh --minimal

    # Install specific category
    bash install-packages.sh --category development

    # Show what would be installed (dry run)
    bash install-packages.sh --dry-run

    # Use custom config file
    bash install-packages.sh --config /path/to/custom.yml

EOF
}

check_dependencies() {
    local missing=()

    # Activate mise if available (to access mise-installed tools)
    if has_command mise; then
        # Add mise shims to PATH
        export PATH="$HOME/.local/share/mise/shims:$PATH"
    fi

    # Check for yq (YAML parser) - need mikefarah's yq, not python yq
    if ! has_command yq; then
        missing+=("yq")
    else
        # Check if it's the correct yq (mikefarah's version)
        local yq_version
        yq_version=$(yq --version 2>&1 || echo "")
        if [[ ! "$yq_version" =~ "mikefarah" ]]; then
            log_warning "Found python yq, but need mikefarah's yq"
            missing+=("yq")
        fi
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing[*]}"
        log_info "Installing yq..."

        # Helper function to install yq binary
        install_yq_binary() {
            local install_dir="$HOME/.local/bin"
            mkdir -p "$install_dir"

            log_info "Downloading mikefarah's yq binary..."

            # Detect architecture
            local arch
            arch=$(uname -m)
            case "$arch" in
                x86_64)
                    arch="amd64"
                    ;;
                aarch64|arm64)
                    arch="arm64"
                    ;;
                *)
                    log_error "Unsupported architecture: $arch"
                    return 1
                    ;;
            esac

            # Download latest yq binary
            local yq_url="https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${arch}"

            if curl -fsSL "$yq_url" -o "$install_dir/yq"; then
                chmod +x "$install_dir/yq"
                log_success "yq binary installed to $install_dir/yq"

                # Add to PATH if not already there
                if [[ ":$PATH:" != *":$install_dir:"* ]]; then
                    export PATH="$install_dir:$PATH"
                    log_info "Added $install_dir to PATH for this session"
                fi
                return 0
            else
                log_error "Failed to download yq binary"
                return 1
            fi
        }

        # Install yq based on OS
        if is_macos; then
            if has_command brew; then
                brew install yq
            else
                log_error "Homebrew not found. Please install yq manually"
                log_info "Visit: https://github.com/mikefarah/yq"
                exit 1
            fi
        elif is_linux; then
            local pm
            pm=$(get_package_manager)

            case "$pm" in
                apt)
                    # Ubuntu's apt has old python yq - download binary instead
                    install_yq_binary || {
                        log_warning "Binary installation failed, trying mise..."
                        if has_command mise; then
                            mise install yq@latest
                        else
                            log_error "All installation methods failed"
                            log_info "Visit: https://github.com/mikefarah/yq"
                            exit 1
                        fi
                    }
                    ;;
                dnf)
                    log_info "Installing yq via DNF..."
                    sudo dnf install -y yq || {
                        log_warning "DNF installation failed, trying mise..."
                        if has_command mise; then
                            mise install yq@latest
                        else
                            log_error "DNF installation failed and mise not available"
                            log_info "Visit: https://github.com/mikefarah/yq"
                            exit 1
                        fi
                    }
                    ;;
                pacman)
                    log_info "Installing yq via Pacman..."
                    sudo pacman -S --noconfirm yq || {
                        log_warning "Pacman installation failed, trying mise..."
                        if has_command mise; then
                            mise install yq@latest
                        else
                            log_error "Pacman installation failed and mise not available"
                            log_info "Visit: https://github.com/mikefarah/yq"
                            exit 1
                        fi
                    }
                    ;;
                *)
                    log_warning "Unsupported package manager: $pm, trying binary install..."
                    install_yq_binary || {
                        log_warning "Binary installation failed, trying mise..."
                        if has_command mise; then
                            mise install yq@latest
                        else
                            log_error "Please install 'yq' manually"
                            log_info "Visit: https://github.com/mikefarah/yq"
                            exit 1
                        fi
                    }
                    ;;
            esac
        else
            log_error "Unsupported OS for automatic yq installation"
            log_info "Visit: https://github.com/mikefarah/yq"
            exit 1
        fi
    fi
}

detect_config_file() {
    local os
    os=$(detect_os)

    # Use pro or perso directory based on PACKAGE_TYPE
    local type_dir="$CONFIG_DIR/$PACKAGE_TYPE"

    case "$os" in
        macos)
            echo "$type_dir/brew.pkg.yml"
            ;;
        linux)
            local pm
            pm=$(get_package_manager)
            case "$pm" in
                apt)
                    echo "$type_dir/apt.pkg.yml"
                    ;;
                dnf)
                    if [[ "$PACKAGE_TYPE" == "pro" ]]; then
                        log_error "DNF package manager not supported for professional packages"
                        log_info "Professional packages are limited to macOS (Homebrew) and Ubuntu/Debian (APT)"
                        log_info "Use --perso for personal packages on Fedora/RHEL systems"
                        exit 1
                    fi
                    echo "$type_dir/dnf.pkg.yml"
                    ;;
                pacman)
                    if [[ "$PACKAGE_TYPE" == "pro" ]]; then
                        log_error "Pacman package manager not supported for professional packages"
                        log_info "Professional packages are limited to macOS (Homebrew) and Ubuntu/Debian (APT)"
                        log_info "Use --perso for personal packages on Arch Linux systems"
                        exit 1
                    fi
                    echo "$type_dir/pacman.pkg.yml"
                    ;;
                *)
                    log_error "Unsupported package manager: $pm"
                    exit 1
                    ;;
            esac
            ;;
        *)
            log_error "Unsupported OS: $os"
            exit 1
            ;;
    esac
}

get_categories() {
    local config_file="$1"

    # Extract top-level keys (categories) from YAML
    yq eval 'keys | .[]' "$config_file"
}

get_packages_in_category() {
    local config_file="$1"
    local category="$2"

    # Get all packages in the category
    yq eval ".${category}[]" "$config_file" -o json
}

is_package_optional() {
    local package_json="$1"

    # Check if package has optional: true
    local optional
    optional=$(echo "$package_json" | yq eval '.optional // false' -)

    [[ "$optional" == "true" ]]
}

get_package_name() {
    local package_json="$1"

    echo "$package_json" | yq eval '.name' -
}

get_package_description() {
    local package_json="$1"

    echo "$package_json" | yq eval '.description // ""' -
}

get_package_tap() {
    local package_json="$1"

    echo "$package_json" | yq eval '.tap // ""' -
}

should_install_package() {
    local package_json="$1"

    # Skip if minimal mode and package is optional
    if [[ "$MINIMAL_MODE" == "true" ]] && is_package_optional "$package_json"; then
        return 1
    fi

    # Skip if skip-optional flag and package is optional
    if [[ "$SKIP_OPTIONAL" == "true" ]] && is_package_optional "$package_json"; then
        return 1
    fi

    return 0
}

install_package_from_json() {
    local package_json="$1"
    local pm="$2"

    local name desc tap
    name=$(get_package_name "$package_json")
    desc=$(get_package_description "$package_json")
    tap=$(get_package_tap "$package_json")

    # Skip if already installed
    if check_package_installed "$name" "$pm"; then
        log_info "✓ $name already installed"
        return 0
    fi

    log_step "Installing $name"
    if [[ -n "$desc" ]]; then
        log_info "  Description: $desc"
    fi

    # Handle Homebrew taps
    if [[ -n "$tap" ]] && [[ "$pm" == "brew" ]]; then
        if ! brew tap | grep -q "^${tap}$" 2>/dev/null; then
            log_info "  Adding tap: $tap"
            if [[ "$DRY_RUN" == "false" ]]; then
                brew tap "$tap" || true
            fi
        fi
    fi

    # Install package
    if [[ "$DRY_RUN" == "false" ]]; then
        install_package "$name" "$pm"
    else
        log_info "  [DRY RUN] Would install: $name"
    fi
}

install_packages_from_config() {
    local config_file="$1"
    local pm="$2"

    log_header "Installing packages from: $(basename "$config_file")"
    log_info "Package manager: $pm"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_warning "DRY RUN MODE - No packages will be installed"
    fi

    # Get categories
    local categories
    mapfile -t categories < <(get_categories "$config_file")

    for category in "${categories[@]}"; do
        # Skip if category filter is set and doesn't match
        if [[ -n "$CATEGORY_FILTER" ]] && [[ "$category" != "$CATEGORY_FILTER" ]]; then
            continue
        fi

        log_header "Category: $category"

        # Get packages in category
        local package_count=0
        local installed_count=0
        local skipped_count=0

        # Get packages in category (store in variable to avoid subshell PATH issues)
        local packages_json
        packages_json=$(yq eval ".${category}[] | @json" "$config_file")

        while IFS= read -r package_json; do
            [[ -z "$package_json" ]] && continue  # Skip empty lines

            : $((package_count++))  # : prefix prevents set -e exit when count is 0

            # Check if should install
            if ! should_install_package "$package_json"; then
                local name
                name=$(get_package_name "$package_json")
                log_info "⊘ $name (optional, skipped)"
                : $((skipped_count++))
                continue
            fi

            # Install package
            install_package_from_json "$package_json" "$pm"
            : $((installed_count++))
        done <<< "$packages_json"

        log_success "Processed $package_count packages ($installed_count installed, $skipped_count skipped)"
        echo ""
    done
}

install_mise_tools() {
    local mise_config="$CONFIG_DIR/$PACKAGE_TYPE/mise.pkg.yml"

    if [[ ! -f "$mise_config" ]]; then
        log_warning "Mise config not found: $mise_config"
        return 0
    fi

    if ! has_command mise; then
        log_warning "Mise not installed, skipping mise tools"
        return 0
    fi

    log_header "Installing mise tools"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_warning "DRY RUN MODE - No tools will be installed"
    fi

    # Get categories
    local categories
    mapfile -t categories < <(get_categories "$mise_config")

    for category in "${categories[@]}"; do
        # Skip if category filter is set and doesn't match
        if [[ -n "$CATEGORY_FILTER" ]] && [[ "$category" != "$CATEGORY_FILTER" ]]; then
            continue
        fi

        log_header "Mise Category: $category"

        # Get tools in category
        local tool_count=0
        local installed_count=0
        local skipped_count=0

        # Get tools in category (store in variable to avoid subshell PATH issues)
        local tools_json
        tools_json=$(yq eval ".${category}[] | @json" "$mise_config")

        while IFS= read -r tool_json; do
            [[ -z "$tool_json" ]] && continue  # Skip empty lines

            : $((tool_count++))  # : prefix prevents set -e exit when count is 0

            # Check if should install
            if ! should_install_package "$tool_json"; then
                local name
                name=$(get_package_name "$tool_json")
                log_info "⊘ $name (optional, skipped)"
                : $((skipped_count++))
                continue
            fi

            local name version desc
            name=$(get_package_name "$tool_json")
            version=$(echo "$tool_json" | yq eval '.version // "latest"' -)
            desc=$(get_package_description "$tool_json")

            log_step "Installing $name@$version"
            if [[ -n "$desc" ]]; then
                log_info "  Description: $desc"
            fi

            if [[ "$DRY_RUN" == "false" ]]; then
                mise install "$name@$version"
            else
                log_info "  [DRY RUN] Would install: $name@$version"
            fi

            : $((installed_count++))
        done <<< "$tools_json"

        log_success "Processed $tool_count tools ($installed_count installed, $skipped_count skipped)"
        echo ""
    done
}

# =============================================================================
# Main
# =============================================================================

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --pro)
                PACKAGE_TYPE="pro"
                shift
                ;;
            --perso)
                PACKAGE_TYPE="perso"
                shift
                ;;
            --minimal)
                MINIMAL_MODE=true
                SKIP_OPTIONAL=true
                shift
                ;;
            --full)
                MINIMAL_MODE=false
                SKIP_OPTIONAL=false
                shift
                ;;
            --category)
                CATEGORY_FILTER="$2"
                shift 2
                ;;
            --config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            --skip-optional)
                SKIP_OPTIONAL=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    log_header "Package Installation Parser"

    # Check dependencies
    check_dependencies

    # Detect or use provided config file
    if [[ -z "$CONFIG_FILE" ]]; then
        CONFIG_FILE=$(detect_config_file)
    fi

    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "Config file not found: $CONFIG_FILE"
        exit 1
    fi

    log_info "Using config: $CONFIG_FILE"
    log_info "Package type: $PACKAGE_TYPE"

    if [[ "$MINIMAL_MODE" == "true" ]]; then
        log_info "Mode: MINIMAL (essentials only)"
    else
        log_info "Mode: FULL (all packages)"
    fi

    if [[ -n "$CATEGORY_FILTER" ]]; then
        log_info "Category filter: $CATEGORY_FILTER"
    fi

    echo ""

    # Get package manager
    local pm
    pm=$(get_package_manager)

    # Install packages from main config
    install_packages_from_config "$CONFIG_FILE" "$pm"

    # Install mise tools (if available)
    install_mise_tools

    log_success "Package installation complete!"
}

main "$@"
