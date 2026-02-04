# =============================================================================
# install.just - Installation recipes
# =============================================================================

# Install everything (full installation)
[unix]
install_full:
    @just _log_step "Running full installation..."
    @{{dotfiles_root}}/install.sh --full

# Install minimal setup (core tools only)
[unix]
install_minimal:
    @just _log_step "Running minimal installation..."
    @{{dotfiles_root}}/install.sh --minimal

# Install specific component
[unix]
install_component COMP:
    #!/usr/bin/env bash
    set -euo pipefail

    INSTALLER="{{installers}}/install-{{COMP}}.sh"

    if [ ! -f "$INSTALLER" ]; then
        echo -e "{{color_red}}[ERROR]{{color_reset}} Unknown component: {{COMP}}"
        echo ""
        echo "Available components:"
        echo "  - homebrew      (macOS package manager)"
        echo "  - mise          (version manager)"
        echo "  - essentials    (build tools: gcc, make, cmake)"
        echo "  - zsh           (shell)"
        echo "  - stow          (symlink manager)"
        echo "  - fonts         (modern Nerd Fonts)"
        echo "  - dotnet        (.NET SDK)"
        echo "  - docker        (Docker Engine)"
        echo "  - js-packages   (JavaScript/TypeScript packages)"
        echo "  - lazyvim       (LazyVim Neovim distribution)"
        echo "  - nushell       (Nushell shell)"
        echo "  - uv-tools      (UV Python tools)"
        echo "  - clawdbot      (Clawdbot CLI - optional)"
        exit 1
    fi

    echo -e "{{color_blue}}[STEP]{{color_reset}} Installing {{COMP}}..."
    if bash "$INSTALLER"; then
        echo -e "{{color_green}}[✓]{{color_reset}} {{COMP}} installed successfully"
    else
        echo -e "{{color_red}}[ERROR]{{color_reset}} Failed to install {{COMP}}"
        exit 1
    fi

# Install Homebrew (macOS only)
[macos]
install_homebrew:
    @just _log_step "Installing Homebrew..."
    @{{installers}}/install-homebrew.sh

# Install mise version manager
[unix]
install_mise:
    @just _log_step "Installing mise..."
    @{{installers}}/install-mise.sh

# Install essential build tools (gcc, make, cmake, etc.)
[unix]
install_essentials:
    @just _log_step "Installing essential build tools..."
    @{{installers}}/install-essentials.sh

# Install zsh shell
[unix]
install_zsh:
    @just _log_step "Installing zsh..."
    @{{installers}}/install-zsh.sh

# Install GNU Stow
[unix]
install_stow:
    @just _log_step "Installing GNU Stow..."
    @{{installers}}/install-stow.sh

# Install modern Nerd Fonts
[unix]
install_fonts:
    @just _log_step "Installing modern fonts..."
    @{{installers}}/install-modern-fonts.sh

# Install .NET SDK
[unix]
install_dotnet:
    @just _log_step "Installing .NET SDK..."
    @AUTO_INSTALL=true {{installers}}/install-dotnet.sh

# Install Docker Engine (Ubuntu only)
[linux]
install_docker:
    @just _log_step "Installing Docker..."
    @{{installers}}/install-docker.sh

# Install JavaScript/TypeScript packages
[unix]
install_js_packages TYPE="pro":
    @just _log_step "Installing JavaScript packages ({{TYPE}})..."
    @AUTO_CONFIRM=true {{installers}}/install-js-packages.sh --{{TYPE}}

# Install LazyVim Neovim distribution
[unix]
install_lazyvim:
    @just _log_step "Installing LazyVim..."
    @{{installers}}/install-lazyvim.sh

# Install Nushell
[unix]
install_nushell:
    @just _log_step "Installing Nushell..."
    @{{installers}}/install-nushell.sh

# Install UV Python tools
[unix]
install_uv_tools:
    @just _log_step "Installing UV tools..."
    @{{installers}}/install-uv-tools.sh

# Install Clawdbot CLI (optional)
[unix]
install_clawdbot:
    @just _log_step "Installing Clawdbot CLI..."
    @{{installers}}/install-clawdbot.sh
