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
        log_info "Installing yq via mise..."

        # Install yq via mise (preferred method)
        if has_command mise; then
            mise install yq@latest
            log_success "yq installed via mise"
        else
            log_error "mise not available, cannot install yq"
            log_info "Please run bootstrap script first to install mise"
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

install_packages_with_common() {
    local pm="$1"
    local pm_name=""

    # Determine package manager config name
    case "$pm" in
        brew) pm_name="brew" ;;
        apt-get) pm_name="apt" ;;
        dnf) pm_name="dnf" ;;
        pacman) pm_name="pacman" ;;
        *) pm_name="brew" ;;
    esac

    local common_config="$CONFIG_DIR/common/${pm_name}.pkg.yml"
    local profile_config="$CONFIG_DIR/$PACKAGE_TYPE/${pm_name}.pkg.yml"

    # Install common packages first (if exists)
    if [[ -f "$common_config" ]]; then
        log_info "Installing common packages shared across profiles..."
        install_packages_from_config "$common_config" "$pm"
    fi

    # Install profile-specific packages (if exists)
    if [[ -f "$profile_config" ]]; then
        log_info "Installing $PACKAGE_TYPE profile-specific packages..."
        install_packages_from_config "$profile_config" "$pm"
    elif [[ ! -f "$common_config" ]]; then
        log_warning "No package config found for $pm_name (checked common and $PACKAGE_TYPE)"
    fi
}

install_mise_tools() {
    local mise_config="$CONFIG_DIR/$PACKAGE_TYPE/mise.pkg.yml"

    if [[ ! -f "$mise_config" ]]; then
        log_info "Mise config not found at: $mise_config"
        log_info "Mise tools are now managed via mise/.config/mise/config.toml"
        log_info "Run 'mise install' to install tools from mise config"
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

    # Get package manager
    local pm
    pm=$(get_package_manager)


    # If custom config file provided, use it directly
    if [[ -n "$CONFIG_FILE" ]]; then
        if [[ ! -f "$CONFIG_FILE" ]]; then
            log_error "Config file not found: $CONFIG_FILE"
            exit 1
        fi

        log_info "Using custom config: $CONFIG_FILE"
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

        # Install packages from custom config
        install_packages_from_config "$CONFIG_FILE" "$pm"
    else
        # Use common + profile-specific configs
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

        # Install packages from common + profile configs
        install_packages_with_common "$pm"
    fi

    # Install mise tools (if available)
    install_mise_tools

    log_success "Package installation complete!"
}

main "$@"
