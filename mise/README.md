# Mise Configuration

[Mise](https://mise.jdx.dev) is a universal tool version manager that replaces tools like asdf, nvm, pyenv, rbenv, etc.

## Overview

This directory contains the mise configuration that will be symlinked to `~/.config/mise/` using GNU Stow.

## Configuration File

- **`.config/mise/config.toml`** - Main mise configuration

## What's Included

### Language Runtimes

- **Node.js** (LTS) - JavaScript runtime
- **Bun** (latest) - Fast JavaScript runtime
- **Python** (latest) - Python interpreter
- **Go** (latest) - Go compiler
- **Rust** (latest) - Rust toolchain
- **Ruby** (latest) - Ruby interpreter

### Modern CLI Tools

| Tool | Replaces | Purpose |
|------|----------|---------|
| bat | cat | Syntax highlighting viewer |
| eza | ls | Modern file listing |
| fd | find | Fast file finder |
| ripgrep | grep | Fast text search |
| fzf | - | Fuzzy finder |
| zoxide | cd | Smart directory jumper |

### Shell & System

- **starship** - Cross-shell prompt
- **direnv** - Per-directory environment variables
- **zellij** - Modern terminal multiplexer
- **tmux** - Classic terminal multiplexer
- **btop** - Resource monitor
- **jq** - JSON processor
- **yq** - YAML processor

**Note:** Zinit (Zsh plugin manager) is not available in mise and is automatically installed via git clone in `.zshrc`.

### DevOps & Cloud

#### Kubernetes

- kubectl - Kubernetes CLI
- helm - Package manager
- k9s - Terminal UI
- kind - Local clusters

#### Infrastructure as Code

- terraform - HashiCorp's IaC tool
- opentofu - Open-source Terraform alternative

#### Cloud & GitOps

- awscli - AWS command line
- argocd - GitOps CD tool

### Git & Version Control

- **github-cli** - GitHub CLI (gh command)
- **lazygit** - Terminal UI for git

### Editor & Dev Tools

- **neovim** - Modern vim-based editor
- **vivid** - LS_COLORS generator
- **uv** - Fast Python package installer
- **task** - Task runner (go-task)

## Installation

### Install mise

```bash
# Using the dotfiles install script
cd ~/.dotfiles
./install.sh

# Or manually
./_scripts/linux/sh/installers/install-mise.sh
```

### Stow the Configuration

```bash
cd ~/.dotfiles
stow mise
```

This creates a symlink: `~/.config/mise/config.toml` → `~/.dotfiles/mise/.config/mise/config.toml`

### Install Tools

```bash
# Install all tools from config
mise install

# Install specific tool
mise install node@20

# Install and set as global default
mise use -g node@20
```

## Usage

### Common Commands

```bash
# List installed tools
mise list

# List all available tools
mise ls-remote node

# Update all tools
mise upgrade

# Check for outdated tools
mise outdated

# Verify installation
mise doctor

# Show current environment
mise current
```

### Per-Project Versions

Create `.mise.toml` in your project:

```toml
[tools]
node = "20.10.0"
python = "3.11"
```

Mise automatically switches to these versions when you `cd` into the directory.

### Global vs Local

```bash
# Set global version (affects all projects)
mise use -g node@20

# Set local version (current directory only)
mise use node@18

# Pin exact version
mise use node@20.10.0
```

## Configuration

### Edit the Config

```bash
# Edit using your editor
nvim ~/.config/mise/config.toml

# Or edit the source
nvim ~/.dotfiles/mise/.config/mise/config.toml
```

### Add a New Tool

```toml
[tools]
"deno" = "latest"
```

Then run:

```bash
mise install deno
```

### Pin Specific Versions

```toml
[tools]
node = "20.10.0"        # Exact version
python = "3.11"         # Minor version (latest patch)
go = "latest"           # Always use latest
```

### Settings

```toml
[settings]
experimental = true          # Enable experimental features
verbose = false              # Verbose output
always_keep_download = false # Keep downloaded archives
```

## Troubleshooting

### Tools Not Found After Install

Ensure mise is activated in your shell:

```bash
# Check if mise is in PATH
which mise

# Manually activate
eval "$(mise activate zsh)"

# Or restart shell
exec zsh
```

### Permission Issues

```bash
# Install to ~/.local/bin instead of /usr/local/bin
curl https://mise.run | sh

# Add to PATH
export PATH="$HOME/.local/bin:$PATH"
```

### Conflicting Version Managers

If you have nvm, asdf, or other version managers:

```bash
# Remove from PATH and shell config
# Comment out in ~/.zshrc:
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Migrate existing versions
mise install node@$(node --version)
```

### Update mise Itself

```bash
mise self-update
```

## Advanced

### Trusted Config Paths

Config includes trusted paths for automatic activation:

```toml
[settings]
trusted_config_paths = [
    '~/.config/mise',
]
```

### Environment Variables

```bash
# Set via environment
MISE_NODE_VERSION=20 node --version

# Or in config
[env]
NODE_ENV = "development"
```

### Shell Integration

The mise activation in `~/.zshrc`:

```bash
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi
```

## Resources

- [Official Documentation](https://mise.jdx.dev)
- [Configuration Reference](https://mise.jdx.dev/configuration.html)
- [Available Tools Registry](https://mise.jdx.dev/registry.html)
- [GitHub Repository](https://github.com/jdx/mise)

## Why mise?

- ✅ **Faster** than asdf (written in Rust)
- ✅ **One tool** replaces nvm, pyenv, rbenv, etc.
- ✅ **Per-directory** versions with auto-switching
- ✅ **Task runner** built-in (like make/npm scripts)
- ✅ **Environment management** (like direnv)
- ✅ **Compatible** with asdf plugins
- ✅ **Active development** and community support
