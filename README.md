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
- Windows with WSL

Includes configurations for:

- Shell (`zsh` and some `bash`, but mainly using `zsh` with `zinit`), next is to pick `nushell`.
- Terminal and multiplexer (`alacritty`, `ghostty` and `zellij`)
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

### Quick Start

```bash
# Clone this repository
git clone https://github.com/mombe090/.files.git ~/.dotfiles

# Enter the directory
cd ~/.dotfiles

# Run the interactive install script
./install.sh
```

The install script will:

1. ✅ Automatically backup your existing configurations
2. ✅ Detect your operating system
3. ✅ Install required dependencies
4. ✅ Install mise and modern CLI tools
5. ✅ Create symlinks using GNU Stow
6. ✅ Set up shell configurations

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

### Post-Installation

After installation:

```bash
# 1. Restart your shell or source the config
source ~/.zshrc

# 2. Edit your personal git information
nano ~/.gitconfig.local
# Add your name and email

# 3. Install mise tools (if using mise)
mise install

# 4. Verify installation
which zsh bat eza fzf
```

### Manual Backup (Optional)

The install script backs up automatically, but you can also backup manually:

```bash
# Use the backup script
./scripts/backup.sh

# Or manual backup
cp ~/.zshrc ~/.zshrc.backup
cp -r ~/.config/ ~/.config.backup
```

### Customization

> **Note:** Fork this repository to customize for your needs.

1. Fork on GitHub
2. Clone your fork: `git clone https://github.com/<your-username>/.files.git ~/.dotfiles`
3. Make changes
4. Run `./install.sh` to apply

### Uninstallation

To remove dotfiles and restore backups:

```bash
cd ~/.dotfiles
./scripts/uninstall.sh
```

## Features

These dotfiles include:

### Shell Configuration

- ⚡ **Zsh** with [Zinit](https://github.com/zdharma-continuum/zinit) plugin manager
- 🎨 **Starship** prompt with custom configuration
- 📝 Custom aliases for git, kubernetes, terraform, and more
- 🔍 **fzf** integration for fuzzy finding
- 📂 **zoxide** for smart directory jumping
- 🔧 Modular configuration split into logical files

### Development Tools

- 📦 **mise** - Universal tool version manager (preferred over asdf/nvm)
- 🔨 Language support: Node.js, Python, Go, Rust, Java
- ☁️  Infrastructure tools: kubectl, helm, terraform, ansible
- 🐳 Container tools: docker, k9s, kubecolor

### Terminal & Editor

- 🖥️  **Alacritty** and **Ghostty** terminal configurations
- ✏️  **Neovim** with [LazyVim](https://www.lazyvim.org/) distribution
- 🪟 **Zellij** terminal multiplexer configuration
- 🎨 Consistent **Catppuccin** theme across all tools

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
| **zellij**   | Terminal multiplexer         | `zellij/.config/`            |

## Scripts

Utility scripts in `scripts/`:

- **`install-homebrew.sh`** - Install Homebrew (macOS)
- **`install-mise.sh`** - Install mise version manager
- **`install-zsh.sh`** - Install and set zsh as default
- **`install-stow.sh`** - Install GNU Stow
- **`backup.sh`** - Backup existing configurations
- **`uninstall.sh`** - Remove dotfiles and restore backups

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
