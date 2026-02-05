# =============================================================================
# packages.just - Package management recipes
# =============================================================================

# Install packages using YAML-based package system (pro profile, minimal mode)
[unix]
packages_minimal:
    @just _log_step "Installing minimal packages (essentials only)..."
    @bash {{installers}}/install-packages.sh --pro --minimal

# Install all packages from pro profile
[unix]
packages_pro:
    @just _log_step "Installing professional packages..."
    @bash {{installers}}/install-packages.sh --pro

# Install all packages from perso profile (personal + professional)
[unix]
packages_perso:
    @just _log_step "Installing personal packages..."
    @bash {{installers}}/install-packages.sh --perso

# Install packages from specific category (essentials | development | build_tools | libraries | cloud | fonts | shell_tools | monitoring | runtimes)
[unix]
packages_category CATEGORY:
    #!/usr/bin/env bash
    set -euo pipefail

    VALID_CATEGORIES=("essentials" "development" "build_tools" "libraries" "cloud" "fonts" "shell_tools" "monitoring" "runtimes")

    if [[ ! " ${VALID_CATEGORIES[@]} " =~ " {{CATEGORY}} " ]]; then
        echo -e "{{color_red}}[ERROR]{{color_reset}} Invalid category: {{CATEGORY}}"
        echo ""
        echo "Available categories:"
        echo "  - essentials    (git, curl, wget, stow, zsh)"
        echo "  - development   (neovim, ripgrep, fd, fzf)"
        echo "  - build_tools   (gcc, make, cmake)"
        echo "  - libraries     (openssl, libffi, zlib)"
        echo "  - cloud         (aws-cli, azure-cli, gcloud)"
        echo "  - fonts         (Nerd Fonts)"
        echo "  - shell_tools   (bat, eza, zoxide, starship)"
        echo "  - monitoring    (btop, htop)"
        echo "  - runtimes      (language runtimes)"
        exit 1
    fi

    echo -e "{{color_blue}}[STEP]{{color_reset}} Installing {{CATEGORY}} packages..."
    if bash {{installers}}/install-packages.sh --pro --category {{CATEGORY}}; then
        echo -e "{{color_green}}[✓]{{color_reset}} {{CATEGORY}} packages installed"
    else
        echo -e "{{color_red}}[ERROR]{{color_reset}} Failed to install {{CATEGORY}} packages"
        exit 1
    fi

# Dry-run: Show what packages would be installed (pro profile)
[unix]
packages_dry_run PROFILE="pro":
    @just _log_info "Dry-run mode: showing packages for {{PROFILE}} profile..."
    @bash {{installers}}/install-packages.sh --{{PROFILE}} --dry-run

# List all available package categories
[unix]
packages_list_categories:
    @echo -e "{{color_bold}}Available Package Categories:{{color_reset}}"
    @echo ""
    @echo -e "{{color_green}}1. essentials{{color_reset}}    - Core tools (git, curl, wget, stow, zsh)"
    @echo -e "{{color_green}}2. development{{color_reset}}   - Dev tools (neovim, ripgrep, fd, fzf)"
    @echo -e "{{color_green}}3. build_tools{{color_reset}}   - Compilers and build systems (gcc, make, cmake)"
    @echo -e "{{color_green}}4. libraries{{color_reset}}     - Development libraries (openssl, libffi, zlib)"
    @echo -e "{{color_green}}5. cloud{{color_reset}}         - Cloud CLIs (aws-cli, azure-cli, gcloud)"
    @echo -e "{{color_green}}6. fonts{{color_reset}}         - Nerd Fonts for terminal icons"
    @echo -e "{{color_green}}7. shell_tools{{color_reset}}   - Shell enhancements (bat, eza, zoxide, starship)"
    @echo -e "{{color_green}}8. monitoring{{color_reset}}    - System monitors (btop, htop)"
    @echo -e "{{color_green}}9. runtimes{{color_reset}}      - Language runtimes and interpreters"
    @echo ""
    @echo -e "{{color_blue}}Usage:{{color_reset}}"
    @echo "  just packages_category essentials"
    @echo "  just packages_category development"

# Show package configuration info
[unix]
packages_info:
    @echo -e "{{color_bold}}Package System Information:{{color_reset}}"
    @echo ""
    @echo -e "{{color_green}}Config Location:{{color_reset}} {{scripts_dir}}/configs/unix/packages/"
    @echo ""
    @echo -e "{{color_green}}Profiles:{{color_reset}}"
    @echo "  - pro    (Professional: macOS + Ubuntu/Debian only)"
    @echo "  - perso  (Personal: all platforms + distros)"
    @echo ""
    @echo -e "{{color_green}}Package Managers:{{color_reset}}"
    @echo "  - APT      (Ubuntu/Debian)"
    @echo "  - Homebrew (macOS)"
    @echo "  - DNF      (Fedora/RHEL - perso only)"
    @echo "  - Pacman   (Arch Linux - perso only)"
    @echo "  - Mise     (Cross-platform tools)"
    @echo ""
    @echo -e "{{color_green}}Commands:{{color_reset}}"
    @echo "  just packages_minimal              # Install essentials only"
    @echo "  just packages_pro                  # Install all pro packages"
    @echo "  just packages_perso                # Install all personal packages"
    @echo "  just packages_category <name>      # Install specific category"
    @echo "  just packages_dry_run pro          # Show what would be installed"
    @echo "  just packages_list_categories      # List all categories"

# Update all installed packages via package managers
[unix]
packages_update:
    #!/usr/bin/env bash
    set -euo pipefail

    echo -e "{{color_blue}}[STEP]{{color_reset}} Updating packages via package managers..."

    # Detect OS and package manager
    if command -v brew &>/dev/null; then
        echo -e "{{color_green}}[INFO]{{color_reset}} Updating Homebrew packages..."
        brew update && brew upgrade
    fi

    if command -v apt &>/dev/null && [[ -f /etc/debian_version ]]; then
        echo -e "{{color_green}}[INFO]{{color_reset}} Updating APT packages..."
        sudo apt update && sudo apt upgrade -y
    fi

    if command -v dnf &>/dev/null; then
        echo -e "{{color_green}}[INFO]{{color_reset}} Updating DNF packages..."
        sudo dnf upgrade -y
    fi

    if command -v pacman &>/dev/null; then
        echo -e "{{color_green}}[INFO]{{color_reset}} Updating Pacman packages..."
        sudo pacman -Syu --noconfirm
    fi

    if command -v mise &>/dev/null; then
        echo -e "{{color_green}}[INFO]{{color_reset}} Updating mise tools..."
        mise upgrade
    fi

    echo -e "{{color_green}}[✓]{{color_reset}} Package updates complete"

# Clean package manager caches
[unix]
packages_clean:
    #!/usr/bin/env bash
    set -euo pipefail

    echo -e "{{color_blue}}[STEP]{{color_reset}} Cleaning package manager caches..."

    if command -v brew &>/dev/null; then
        echo -e "{{color_green}}[INFO]{{color_reset}} Cleaning Homebrew cache..."
        brew cleanup -s
        brew autoremove
    fi

    if command -v apt &>/dev/null && [[ -f /etc/debian_version ]]; then
        echo -e "{{color_green}}[INFO]{{color_reset}} Cleaning APT cache..."
        sudo apt autoremove -y
        sudo apt clean
    fi

    if command -v dnf &>/dev/null; then
        echo -e "{{color_green}}[INFO]{{color_reset}} Cleaning DNF cache..."
        sudo dnf autoremove -y
        sudo dnf clean all
    fi

    if command -v pacman &>/dev/null; then
        echo -e "{{color_green}}[INFO]{{color_reset}} Cleaning Pacman cache..."
        sudo pacman -Sc --noconfirm
    fi

    echo -e "{{color_green}}[✓]{{color_reset}} Cache cleanup complete"

# Search for packages in package manager
[unix]
packages_search QUERY:
    #!/usr/bin/env bash
    set -euo pipefail

    echo -e "{{color_blue}}[STEP]{{color_reset}} Searching for: {{QUERY}}"
    echo ""

    if command -v brew &>/dev/null; then
        echo -e "{{color_green}}Homebrew:{{color_reset}}"
        brew search {{QUERY}} | head -10
        echo ""
    fi

    if command -v apt &>/dev/null && [[ -f /etc/debian_version ]]; then
        echo -e "{{color_green}}APT:{{color_reset}}"
        apt-cache search {{QUERY}} | head -10
        echo ""
    fi

    if command -v dnf &>/dev/null; then
        echo -e "{{color_green}}DNF:{{color_reset}}"
        dnf search {{QUERY}} | head -10
        echo ""
    fi

    if command -v pacman &>/dev/null; then
        echo -e "{{color_green}}Pacman:{{color_reset}}"
        pacman -Ss {{QUERY}} | head -10
        echo ""
    fi

# Show installed packages from package managers
[unix]
packages_installed:
    #!/usr/bin/env bash
    set -euo pipefail

    echo -e "{{color_bold}}Installed Packages:{{color_reset}}"
    echo ""

    if command -v brew &>/dev/null; then
        echo -e "{{color_green}}Homebrew ($(brew list --formula | wc -l | tr -d ' ') packages):{{color_reset}}"
        brew list --formula | column
        echo ""
    fi

    if command -v apt &>/dev/null && [[ -f /etc/debian_version ]]; then
        echo -e "{{color_green}}APT:{{color_reset}}"
        dpkg -l | grep '^ii' | wc -l | xargs echo "Installed packages:"
        echo ""
    fi

    if command -v mise &>/dev/null; then
        echo -e "{{color_green}}Mise tools:{{color_reset}}"
        mise list
        echo ""
    fi
