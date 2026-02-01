# Mombe090 Public dotfiles 💻

This is a collection of my personal dotfiles and configurations to set up quickly a machine ready for my day to day development work.

---

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Features](#features)
- [Software & Tools](#software--tools)

---

## Overview

These dotfiles aim to provide a **clean, efficient, and customizable development environment** for all OS i am using :

- Linux [debian based, rehat based, arch base and nix os],
- macOS
- Windows (native PowerShell/Nushell support)
- Windows with WSL

Includes configurations for:

- Shell (`zsh` and some `bash`, but mainly using `zsh` with `zinit`). Windows native support for `PowerShell 7` and `Nushell`.
- Terminal and multiplexer (`alacritty`, `ghostty`, `wezterm` and `zellij`)
- Editor (`Neovim`, `Vscode` and `Intellij`)
- Tiling window manager (`hyprland`)
- Omarchy Customization
- System aliases, environment variables, functions and more.

---

## Structure

```text
├── alacritty
│   └── .config
│       └── alacritty
│           └── themes
├── bat
├── ghostty
│   └── .config
│       └── ghostty
├── hypr
│   └── .config
│       └── hypr
│           └── scripts
├── k9s
├── nvim
│   └── .config
│       └── nvim
│           ├── lua
│           │   ├── config
│           │   └── plugins
│           └── plugin
│               └── after
├── omarchy
│   ├── branding -> .config/omarchy/branding
│   ├── .config
│   │   └── omarchy
│   │       ├── branding
│   │       ├── current
│   │       └── themes
│   ├── current -> .config/omarchy/current
│   └── themes -> .config/omarchy/themes
├── starship
├── walker
│   └── .config
├── waybar
│   └── .config
└── zsh
    └── .config
        └── zsh
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

Use `./scripts/install-essentials.sh` to install these automatically.

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

## Installation

### Linux & macOS

### Quick Start

```bash
# Clone this repository
git clone https://github.com/mombe090/.files.git ~/.dotfiles

# Enter the directory
cd ~/.dotfiles

# Run the interactive install script
./install.sh
```

### Windows (Native PowerShell/Nushell)

See **[_scripts/windows/QUICK-START.md](_scripts/windows/QUICK-START.md)** for detailed Windows installation guide.

**Quick Setup:**

```powershell
# 1. Clone repository
git clone https://github.com/mombe090/.files.git C:\Users\<username>\.files

# 2. Install fonts (as Administrator)
cd C:\Users\<username>\.files\_scripts\windows\pwsh
Start-Process pwsh -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File .\Install-ModernFonts.ps1' -Verb RunAs

# 3. Install packages
cd C:\Users\<username>\.files\_scripts
.\install.ps1 -Type pro

# 4. Stow dotfiles
cd C:\Users\<username>\.files
.\stow.ps1 wezterm
.\stow.ps1 nu
.\stow.ps1 starship
.\stow.ps1 powershell -Target C:\Users\<username>

# 5. Restart terminal to see Starship prompt
```

**What you get on Windows:**
- 🪟 **PowerShell 7** with Starship prompt and custom aliases
- 🐚 **Nushell** with Starship prompt and custom configurations
- 🖥️ **WezTerm** terminal with WebGpu rendering and Catppuccin theme
- 🔤 **Nerd Fonts** (CascadiaMono, JetBrainsMono) for icon support
- 📦 **Package managers**: Chocolatey (primary), winget (fallback), Bun (JavaScript)
- 🔧 **Development tools**: Git, VSCode, IntelliJ, Neovim, kubectl, Terraform, Docker, and more

**Windows Documentation:**
- **[QUICK-START.md](_scripts/windows/QUICK-START.md)** - Quick reference guide
- **[TESTING.md](TESTING.md)** - Comprehensive testing guide
- **[_scripts/README.md](_scripts/README.md)** - Script documentation

---

### Post-Installation (Linux & macOS)

After installation:

```bash

### Installation Options

**Interactive Mode** (recommended):

```bash
./install.sh
```

Choose from:

- **Full installation** - Everything including optional tools
- **Minimal installation** - Only core tools (zsh, git configs)
- **Custom installation** - Pick what to install

**Non-Interactive Mode**:

```bash
# Full installation
./install.sh --full

# Minimal installation
./install.sh --minimal
```

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

### Linux & macOS Scripts

Utility scripts in `scripts/`:

- **`install-homebrew.sh`** - Install Homebrew (macOS)
- **`install-mise.sh`** - Install mise version manager
- **`install-essentials.sh`** - Install essential build tools (gcc, make, cmake, dev libraries)
- **`install-zsh.sh`** - Install and set zsh as default
- **`install-stow.sh`** - Install GNU Stow
- **`install-dotnet.sh`** - Install .NET SDK/Runtime (cross-platform)
- **`install-js-packages.sh`** - Install JS/TS packages globally via bun
- **`install-modern-fonts.sh`** - Install modern Nerd Fonts (CascadiaMono, JetBrainsMono, VictorMono)
- **`manage-stow.sh`** - Manage stow packages (stow/unstow/restow)
- **`check-dotnet.sh`** - Diagnostic tool for .NET PATH issues
- **`backup.sh`** - Backup existing configurations
- **`uninstall.sh`** - Remove dotfiles and restore backups

For detailed documentation, see: [scripts/README.md](scripts/README.md)

### Windows Scripts

PowerShell scripts in `_scripts/`:

- **`install.ps1`** - Main installer (Chocolatey/winget packages)
- **`uninstall.ps1`** - Uninstaller for all packages
- **`stow.ps1`** - GNU Stow-like symlink manager for Windows
- **`windows/pwsh/install-packages.ps1`** - System package installer
- **`windows/pwsh/install-js-packages.ps1`** - Bun global package installer
- **`windows/pwsh/setup-windows.ps1`** - PowerShell modules installer
- **`windows/pwsh/Install-ModernFonts.ps1`** - Nerd Fonts installer

Package configurations in `_scripts/configs/packages/`:
- **`pro/choco.pkg.yml`** - Professional Chocolatey packages
- **`pro/winget.pkg.yml`** - Professional winget packages
- **`pro/js.pkg.yml`** - Professional JavaScript packages
- **`perso/js.pkg.yml`** - Personal JavaScript packages

For detailed documentation, see: [_scripts/windows/QUICK-START.md](_scripts/windows/QUICK-START.md)

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
- **[scripts/README.md](scripts/README.md)** - Detailed script documentation (Linux/macOS)
- **[_scripts/windows/QUICK-START.md](_scripts/windows/QUICK-START.md)** - Windows quick start guide
- **[TESTING.md](TESTING.md)** - Windows testing and verification guide

### Troubleshooting Guides

- **[DOTNET_TROUBLESHOOTING.md](DOTNET_TROUBLESHOOTING.md)** - .NET SDK PATH issues
- **[VM_DOTNET_FIX.md](VM_DOTNET_FIX.md)** - .NET fixes for VMs
- **[scripts/INSTALL_JS_PACKAGES_GUIDE.md](scripts/INSTALL_JS_PACKAGES_GUIDE.md)** - JavaScript package installation
- **[scripts/MANAGE_STOW_GUIDE.md](scripts/MANAGE_STOW_GUIDE.md)** - GNU Stow management

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
./scripts/backup.sh
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
