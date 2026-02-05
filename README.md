# Mombe090 Public dotfiles 💻

This is a collection of my personal dotfiles and configurations to set up quickly a machine ready for my day to day development work.

---

## ⚡ Quick Installation

### Unix (Linux/macOS)

**Method 1: Bootstrap (Recommended for new machines)**
```bash
# 1. Clone the repository
git clone https://github.com/mombe090/.files.git ~/.dotfiles
cd ~/.dotfiles

# 2. Run bootstrap (installs curl, git, just)
bash _scripts/bootstrap.sh

# 3. Install dotfiles
just install_full                 # Full installation
# OR
just install_minimal              # Minimal installation
```

**Method 2: Direct installation**
```bash
# 1. Clone the repository
git clone https://github.com/mombe090/.files.git ~/.dotfiles
cd ~/.dotfiles

# 2. Run the installer (interactive)
bash _scripts/install.sh
```

### Windows (PowerShell 7+)

```powershell
# 1. Clone the repository
git clone https://github.com/mombe090/.files.git $HOME\.dotfiles
cd $HOME\.dotfiles

# 2. Run the installer
.\\_scripts\install.ps1 -Type pro

# Or for personal + professional packages
.\\_scripts\install.ps1 -Type perso
```

**That's it!** 🎉 Your development environment is ready.

---

## Table of Contents

- [Overview](#overview)
- [Quick Installation](#-quick-installation)
- [Installation Methods](#installation-methods)
- [Features](#features)
- [Software & Tools](#software--tools)
- [Structure](#structure)
- [Scripts](#scripts)
- [Documentation](#documentation)

---

## Overview

These dotfiles aim to provide a **clean, efficient, and customizable development environment** for all platforms:

- **Unix**: Linux (Debian, RHEL, Arch, NixOS) and macOS
- **Windows**: Native PowerShell 7 / Nushell support
- **WSL**: Windows Subsystem for Linux

**Platform Detection**: Automatically detects Windows vs Unix at entry point, with OS-specific detection (macOS/Linux distributions) handled internally.

### Included Configurations

- **Shell**: `zsh` with `zinit` (Unix), `PowerShell 7` and `Nushell` (Windows)
- **Terminal**: `alacritty`, `ghostty`, `wezterm`, `zellij`
- **Editor**: `Neovim` (LazyVim), `VSCode`, `IntelliJ`
- **Window Manager**: `hyprland` (Linux)
- **Omarchy**: Custom Arch-based Linux distribution configurations
- **System**: Aliases, environment variables, functions, and more

---

## Installation Methods

### Method 1: Bootstrap (Recommended for New Machines)

The fastest way to set up a new machine with essential tools and Just command runner:

```bash
# Clone the repository
git clone https://github.com/mombe090/.files.git ~/.dotfiles
cd ~/.dotfiles

# Run bootstrap (installs curl, git, just)
bash _scripts/bootstrap.sh

# See all available commands
just --list

# Full installation
just install_full

# Minimal installation (core tools only)
just install_minimal

# Check system health
just doctor
```

**What bootstrap.sh does:**
- ✅ Detects your OS (macOS, Ubuntu, Fedora, Arch, etc.)
- ✅ Installs essential tools: `curl`, `git`
- ✅ Installs latest `just` binary (not outdated apt version)
- ✅ Sets up PATH if needed
- ✅ Interactive or non-interactive mode (`--yes` flag)

### Method 2: Just Command Runner (Already Have Essentials)

If you already have curl and git installed:

```bash
# Clone and install just
git clone https://github.com/mombe090/.files.git ~/.dotfiles
cd ~/.dotfiles
bash _scripts/just/install-just.sh

# See all available commands
just --list

# Full installation
just install_full

# Minimal installation (core tools only)
just install_minimal

# Check system health
just doctor
```

**Common Just Commands:**

```bash
just install_full        # Install everything
just install_minimal     # Core tools only
just update              # Update all (git pull + mise + packages + restow)
just doctor              # Check system health
just verify              # Verify installations
just stow nvim           # Stow specific package
just deploy_gitconfig    # Deploy git configuration
just mise_upgrade        # Upgrade mise tools
```

### Method 3: Direct Script Installation

#### Unix (Linux/macOS)

```bash
# Clone repository
git clone https://github.com/mombe090/.files.git ~/.dotfiles
cd ~/.dotfiles

# Interactive installer (choose full/minimal/custom)
bash _scripts/install.sh

# Or non-interactive
bash _scripts/install.sh --full     # Full installation
bash _scripts/install.sh --minimal  # Minimal installation
```

**Installation Process:**
1. Detects your OS (macOS, Debian, RHEL, Arch, NixOS)
2. Installs package managers (Homebrew for macOS, uses native PM for Linux)
3. Installs mise (universal tool version manager)
4. Installs core tools (git, zsh, stow)
5. Symlinks configurations using GNU Stow
6. Deploys git configuration with your name/email
7. Installs mise tools (node, python, rust, etc.)

#### Windows (PowerShell 7+)

```powershell
# Prerequisites: PowerShell 7 and Git
# Install if needed:
winget install Microsoft.PowerShell
winget install Git.Git

# Clone repository
git clone https://github.com/mombe090/.files.git $HOME\.dotfiles
cd $HOME\.dotfiles\_scripts

# Interactive installer
.\install.ps1

# Or specify package type
.\install.ps1 -Type pro     # Professional packages only
.\install.ps1 -Type perso   # Professional + personal packages
.\install.ps1 -Type all     # Same as perso
```

**Installation Process:**
1. Installs package managers (WinGet + Chocolatey)
2. Installs system packages (Git, VSCode, Docker, etc.)
3. Installs JavaScript packages via Bun
4. Installs PowerShell modules (PSReadLine, Terminal-Icons, posh-git)
5. Sets up PowerShell/Nushell profiles with Starship prompt

**Windows Package Types:**
- **Pro**: Professional development tools (Git, Docker, kubectl, Terraform, VSCode, etc.)
- **Perso**: Professional + personal tools (VLC, Discord, Spotify, etc.)

For detailed Windows setup, see [_scripts/windows/README.md](_scripts/windows/README.md)

### Method 3: Omarchy Linux (Arch-based)

For Omarchy Linux users, use the specialized installer that injects custom configs without replacing defaults:

```bash
cd ~/.dotfiles
bash _scripts/omarchy/install.sh

# Or dry-run to see what would change
bash _scripts/omarchy/install.sh --dry-run
```

**Omarchy Features:**
- Non-destructive injection-based configuration
- Comprehensive backups before changes
- Modular phases (preflight/packages/config/themes/post-install)
- Hyprland, Zsh, and Git customizations

---

## Structure

### Configuration Packages

Each directory represents a stowable package that can be symlinked independently:

```text
~/.dotfiles/
├── alacritty/          # Alacritty terminal config
├── bat/                # Bat (cat replacement) config
├── ghostty/            # Ghostty terminal config
├── git/                # Git config template
├── hypr/               # Hyprland window manager
├── k9s/                # Kubernetes TUI config
├── mise/               # Mise version manager config
├── nvim/               # Neovim/LazyVim config
├── nushell/            # Nushell config (modular)
├── omarchy/            # Omarchy Linux theming
├── powershell/         # PowerShell 7 profile
├── starship/           # Starship prompt config
├── wezterm/            # WezTerm terminal config
├── zellij/             # Zellij multiplexer config
└── zsh/                # Zsh shell config
```

### Scripts Directory

Platform-organized automation scripts:

```text
_scripts/
├── unix/               # Unix-like systems (Linux/macOS)
│   ├── installers/     # Tool installation scripts (13)
│   ├── tools/          # Utility scripts (4)
│   ├── checkers/       # Validation scripts (1)
│   └── lib/            # Shared shell libraries (5)
│       ├── init.sh     # Load all libraries
│       ├── colors.sh   # Logging functions
│       ├── common.sh   # Utility functions
│       ├── detect.sh   # OS/system detection
│       └── package-managers.sh  # Package manager abstraction
├── windows/            # Windows-specific (PowerShell 7+)
│   ├── installers/     # Installation scripts (6)
│   ├── tools/          # Utility scripts (2)
│   ├── managers/       # Package manager installers (3)
│   └── lib/            # PowerShell libraries (4)
├── omarchy/            # Omarchy Linux specialized installer
├── just/               # Just command runner bootstrap
└── configs/            # Configuration files (YAML)
    ├── unix/packages/  # Unix package configs (2)
    └── windows/
        ├── packages/   # Windows package configs (6)
        └── platform/   # Platform config (1)
```

---

## Dependencies

### Required

These are automatically installed by the install script:

- **git** - Version control
- **curl** - Download tool
- **zsh** - Shell
- **stow** - Symlink manager

### Build Essentials (Optional but Recommended)

For compiling software from source and building native extensions:

- **build-essential** (Debian) / **base-devel** (Arch) / **Development Tools** (RHEL)
- **gcc/g++** - C/C++ compilers
- **make** - Build automation tool
- **cmake** - Cross-platform build system
- **pkg-config** - Package configuration tool
- Development libraries: OpenSSL, libffi, readline, zlib, SQLite, ncurses, etc.
- Python development headers and pip

Use `bash _scripts/unix/installers/install-essentials.sh` to install these automatically.

### Optional (Recommended)

The install script will attempt to install these via mise or your system package manager:

- **mise** - Universal tool version manager (preferred)
- **bat** - Modern cat replacement with syntax highlighting
- **eza** - Modern ls replacement with icons
- **fzf** - Fuzzy finder for command history and files
- **ripgrep** - Fast grep alternative
- **fd** - Fast find alternative
- **zoxide** - Smart cd replacement
- **starship** - Fast, customizable prompt
- **neovim** - Modern vim-based editor
- **direnv** - Environment variable manager
- **delta** - Beautiful git diffs
- **jq/yq** - JSON/YAML processors
- **btop** - Resource monitor

### System-Specific

- **macOS**: Homebrew (automatically installed)
- **Linux**: System package manager (apt/yum/pacman)

---

## Features

These dotfiles include:

### Shell Configuration

**Linux & macOS:**
- ⚡ **Zsh** with [Zinit](https://github.com/zdharma-continuum/zinit) plugin manager
- 🎨 **Starship** prompt with custom configuration
- 📝 Custom aliases for git, kubernetes, terraform, and more
- 🔍 **fzf** integration for fuzzy finding
- 📂 **zoxide** for smart directory jumping
- 🔧 Modular configuration split into logical files

**Windows:**
- 🪟 **PowerShell 7** with custom profile and Starship prompt
- 🐚 **Nushell** with Starship prompt and vi mode
- 📝 Git and Kubernetes aliases in both shells
- 🎨 Catppuccin-inspired color themes
- 🔧 Enhanced commands (cx for cd + ls)

### Development Tools

- 📦 **mise** - Universal tool version manager (preferred over asdf/nvm)
- 🔨 Language support: Node.js, Python, Go, Rust, Java
- ☁️  Infrastructure tools: kubectl, helm, terraform, ansible
- 🐳 Container tools: docker, k9s, kubecolor

### Terminal & Editor

- 🖥️  **Alacritty**, **Ghostty**, and **WezTerm** terminal configurations
- ✏️  **Neovim** with [LazyVim](https://www.lazyvim.org/) distribution
- 🪟 **Zellij** terminal multiplexer configuration
- 🎨 Consistent **Catppuccin** theme across all tools
- 🔤 **Nerd Fonts** (CascadiaMono, JetBrainsMono, VictorMono) for icon support

### Window Manager (Linux)

- 🪟 **Hyprland** tiling window manager configuration
- 🎨 Custom [Omarchy](https://omarchy.org) theming
- ⚙️  Waybar and other Wayland tools

### Version Control

- 🔀 **Git** with sensible aliases and delta integration
- 📊 **Delta** for beautiful git diffs
- 🔐 GitHub CLI credential helper
- 📝 Separate `.gitconfig.local` for personal information

### Package Management

- 🍺 **Homebrew** (macOS)
- 📦 **mise** (cross-platform, preferred)
- 🐧 Native package managers (apt/yum/pacman on Linux)
- ❄️  **Nix** support with:
  - [NixDarwin](https://nix-darwin.github.io/) on macOS
  - [home-manager](https://nix-community.github.io/home-manager/) on Linux

## Software & Tools

### Core Tools

| Tool        | Purpose                      | Config Location              |
| ----------- | ---------------------------- | ---------------------------- |
| **zsh**     | Shell                        | `zsh/.config/zsh/`           |
| **git**     | Version control              | `git/.gitconfig`             |
| **neovim**  | Text editor                  | `nvim/.config/nvim/`         |
| **starship**| Shell prompt                 | `starship/starship.toml`     |

### Modern CLI Replacements

| Tool        | Replaces | Purpose                      |
| ----------- | -------- | ---------------------------- |
| **bat**     | cat      | Syntax highlighting viewer   |
| **eza**     | ls       | Modern file listing          |
| **fd**      | find     | Fast file finder             |
| **ripgrep** | grep     | Fast text search             |
| **zoxide**  | cd       | Smart directory jumper       |
| **delta**   | diff     | Beautiful git diffs          |
| **btop**    | top      | Resource monitor             |

### Development Tools

| Tool         | Purpose                           |
| ------------ | --------------------------------- |
| **mise**     | Version manager (replaces asdf)   |
| **direnv**   | Per-directory environment vars    |
| **fzf**      | Fuzzy finder                      |
| **jq/yq**    | JSON/YAML processors              |

### Infrastructure & DevOps

| Tool          | Purpose                          |
| ------------- | -------------------------------- |
| **kubectl**   | Kubernetes CLI                   |
| **k9s**       | Kubernetes TUI                   |
| **kubecolor** | Colored kubectl output           |
| **helm**      | Kubernetes package manager       |
| **terraform** | Infrastructure as code           |
| **ansible**   | Configuration management         |
| **docker**    | Container runtime                |

### Terminal & Multiplexer

| Tool         | Purpose                      | Config Location              |
| ------------ | ---------------------------- | ---------------------------- |
| **alacritty**| GPU-accelerated terminal     | `alacritty/.config/`         |
| **ghostty**  | Modern terminal emulator     | `ghostty/.config/`           |
| **wezterm**  | GPU-accelerated terminal     | `wezterm/.config/wezterm/`   |
| **zellij**   | Terminal multiplexer         | `zellij/.config/`            |

## Scripts

All automation scripts are organized under `_scripts/` with platform-specific subdirectories.

### Unix Scripts (Linux & macOS)

Located in `_scripts/unix/`, using Bash with **shared libraries** to eliminate code duplication:

#### Shared Libraries (`lib/`)

- **`init.sh`** - Load all libraries at once
- **`colors.sh`** - Logging functions (log_info, log_success, log_error, log_warning, etc.)
- **`common.sh`** - Utilities (has_command, retry, backup_file, confirm_prompt, etc.)
- **`detect.sh`** - OS detection (detect_os, get_distro, is_macos, get_package_manager, etc.)
- **`package-managers.sh`** - Package manager abstraction (install_package, update_packages, etc.)

**Usage in scripts:**
```bash
source "$DOTFILES_ROOT/_scripts/unix/lib/init.sh"  # Load all libraries
log_info "Installing package..."
install_package git  # Automatically uses correct PM for your OS
```

#### Installers (`installers/`)

- **`install-homebrew.sh`** - Install Homebrew (macOS)
- **`install-mise.sh`** - Install mise version manager
- **`install-essentials.sh`** - Install build tools (gcc, make, cmake, dev libraries)
- **`install-docker.sh`** - Install Docker Engine (Ubuntu)
- **`install-zsh.sh`** - Install and set zsh as default shell
- **`install-stow.sh`** - Install GNU Stow symlink manager
- **`install-dotnet.sh`** - Install .NET SDK/Runtime (cross-platform)
- **`install-nushell.sh`** - Install Nushell shell
- **`install-js-packages.sh`** - Install JS/TS packages via Bun
- **`install-lazyvim.sh`** - Install LazyVim Neovim distribution
- **`install-modern-fonts.sh`** - Install Nerd Fonts
- **`install-uv-tools.sh`** - Install UV Python tools
- **`install-clawdbot.sh`** - Install Clawdbot CLI (optional)

#### Tools (`tools/`)

- **`manage-stow.sh`** - Manage stow packages (stow/unstow/restow)
- **`backup.sh`** - Backup existing configurations
- **`uninstall.sh`** - Remove dotfiles and restore backups
- **`deploy-gitconfig.sh`** - Deploy git config with token replacement

#### Checkers (`checkers/`)

- **`check-dotnet.sh`** - Diagnostic tool for .NET PATH issues

### Windows Scripts (PowerShell 7+)

Located in `_scripts/windows/`, using PowerShell 7 conventions (Verb-Noun naming):

#### Package Manager Installers (`managers/`)

- **`Install-Choco.ps1`** - Install Chocolatey package manager
- **`Install-WinGet.ps1`** - Install/update WinGet package manager
- **`Install-PowerShell.ps1`** - Install PowerShell 7

#### Application Installers (`installers/`)

- **`Install-Packages.ps1`** - System packages via Choco/WinGet
- **`Install-JsPackages.ps1`** - JavaScript packages via Bun
- **`Install-PwshModules.ps1`** - PowerShell modules (PSReadLine, posh-git, Terminal-Icons)
- **`Install-ModernFonts.ps1`** - Nerd Fonts installer (requires admin)
- **`Install-LazyVim.ps1`** - LazyVim Neovim distribution
- **`Install-Neovim.ps1`** - Neovim standalone installer

#### Tools (`tools/`)

- **`Invoke-Stow.ps1`** - GNU Stow-like symlink manager for Windows
- **`Test-StowLocalAppData.ps1`** - Test stowing to LocalAppData

#### Libraries (`lib/`)

- **`colors.ps1`** - Logging functions (Write-Info, Write-Success, Write-Error, Write-Warning, etc.)
- **`common.ps1`** - Common utilities
- **`detect.ps1`** - System detection (Get-WindowsVersion, Test-IsAdmin, etc.)
- **`package-managers.ps1`** - Package manager functions

#### Entry Points

- **`_scripts/install.ps1`** - Main Windows installer
- **`_scripts/uninstall.ps1`** - Uninstaller for all packages
- **`_scripts/stow.ps1`** - Stow wrapper script

### Configuration Files

YAML package configurations in `_scripts/configs/`:

#### Unix Configs (`unix/packages/`)

- **`js.pkg.yml`** - JavaScript packages for Unix
- **`uv-tools.pkg.yml`** - UV Python tools

#### Windows Configs (`windows/packages/`)

**Professional** (`pro/`):
- **`choco.pkg.yml`** - Professional Chocolatey packages
- **`winget.pkg.yml`** - Professional WinGet packages  
- **`js.pkg.yml`** - Professional JavaScript packages

**Personal** (`perso/`):
- **`choco.pkg.yml`** - Personal Chocolatey packages
- **`winget.pkg.yml`** - Personal WinGet packages
- **`js.pkg.yml`** - Personal JavaScript packages

#### Platform Config (`windows/platform/`)

- **`pwsh-modules.pkg.yml`** - PowerShell module list

### Omarchy Linux Scripts

Specialized installer for [Omarchy Linux](https://omarchy.org) (Arch-based):

- **`_scripts/omarchy/install.sh`** - Non-destructive injection-based installer
- Modular phases: `preflight/`, `packages/`, `config/`, `themes/`, `post-install/`

For detailed documentation:
- **Unix**: [_scripts/unix/README.md](_scripts/unix/README.md) (if exists)
- **Windows**: [_scripts/windows/QUICK-START.md](_scripts/windows/QUICK-START.md)

## Documentation

### Architecture & Design

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Detailed architecture documentation
  - Simplified, delegated design principles
  - Script responsibilities and flow
  - Installation process breakdown
  - Error handling and logging
  - Best practices for contributors
- **[docs/SIMPLIFIED_ARCHITECTURE.md](docs/SIMPLIFIED_ARCHITECTURE.md)** - Visual architecture guide
  - Before/after comparison
  - Function simplification breakdown
  - Visual flow diagrams
  - Testing strategies

### Installation Guides

- **[INSTALLATION_FLOW.md](INSTALLATION_FLOW.md)** - Visual installation flow diagram (Linux/macOS)
- **[_scripts/unix/README.md](_scripts/unix/README.md)** - Unix script documentation (if exists)
- **[_scripts/windows/QUICK-START.md](_scripts/windows/QUICK-START.md)** - Windows quick start guide
- **[TESTING.md](TESTING.md)** - Windows testing and verification guide

### Troubleshooting Guides

- **[DOTNET_TROUBLESHOOTING.md](DOTNET_TROUBLESHOOTING.md)** - .NET SDK PATH issues
- **[VM_DOTNET_FIX.md](VM_DOTNET_FIX.md)** - .NET fixes for VMs
- **[_scripts/unix/docs/INSTALL_JS_PACKAGES_GUIDE.md](_scripts/unix/docs/INSTALL_JS_PACKAGES_GUIDE.md)** - JavaScript package installation (if exists)
- **[_scripts/unix/MANAGE_STOW_GUIDE.md](_scripts/unix/MANAGE_STOW_GUIDE.md)** - GNU Stow management (if exists)

### Changelog

- **[CHANGELOG.md](CHANGELOG.md)** - Version history and changes

## Troubleshooting

### Zinit not loading plugins

```bash
rm -rf ~/.local/share/zinit
source ~/.zshrc
```

### Stow conflicts

```bash
# Backup and remove conflicting files first
bash _scripts/unix/tools/backup.sh
rm ~/.zshrc
cd ~/.dotfiles && stow zsh
```

### Mise not activating

Ensure mise is in PATH:

```bash
export PATH="$HOME/.local/bin:$PATH"
eval "$(mise activate zsh)"
```

### Git personal info not set

Edit `~/.gitconfig.local`:

```gitconfig
[user]
    name = Your Name
    email = your.email@example.com
```

## Contributing

Contributions are welcome! Feel free to:

1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - Feel free to use and modify for your own needs.

## Acknowledgments

- [Catppuccin](https://github.com/catppuccin) - Beautiful pastel theme
- [LazyVim](https://www.lazyvim.org/) - Neovim distribution
- [Zinit](https://github.com/zdharma-continuum/zinit) - Zsh plugin manager
- [Starship](https://starship.rs/) - Cross-shell prompt
- [mise](https://mise.jdx.dev/) - Universal tool version manager
