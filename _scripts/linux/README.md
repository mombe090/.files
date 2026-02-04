# Linux Scripts

This directory contains all Linux/macOS shell scripts for the dotfiles repository.

## Directory Structure

```
_scripts/linux/
├── sh/
│   ├── installers/      # Installation scripts (install-*.sh)
│   ├── tools/           # Utility scripts (manage-stow, backup, etc.)
│   └── checkers/        # Validation scripts (check-*.sh)
├── config/              # Configuration files for installers
├── docs/                # Documentation
├── README.md            # This file
└── MANAGE_STOW_GUIDE.md # Stow management guide
```

## Scripts Organization

### Installers (`sh/installers/`)

Installation scripts for various tools and applications:

#### `install-mise.sh`

Install [mise](https://mise.jdx.dev) universal tool version manager.

```bash
./scripts/install-mise.sh
```

**What it does:**

- Installs mise globally or to ~/.local/bin
- Configures shell integration (zsh/bash)
- Supports sudo and non-sudo installations

**After installation:**

```bash
source ~/.zshrc
cd ~/.dotfiles && mise install
```

---

#### `install-homebrew.sh`

Install Homebrew package manager (macOS/Linux).

```bash
./scripts/install-homebrew.sh
```

**What it does:**

- Installs Homebrew if not present
- Configures shell PATH for Homebrew
- Detects architecture (Apple Silicon vs Intel)

---

#### `install-zsh.sh`

Install zsh and set as default shell.

```bash
./scripts/install-zsh.sh
```

**What it does:**

- Installs zsh via system package manager
- Adds zsh to /etc/shells
- Changes default shell to zsh

---

#### `install-stow.sh`

Install GNU Stow for dotfiles management.

```bash
./scripts/install-stow.sh
```

**What it does:**

- Installs GNU Stow via system package manager
- Used by main install.sh for symlinking

---

#### `install-dotnet.sh`

Install .NET SDK and/or Runtime (cross-platform).

```bash
./scripts/install-dotnet.sh [OPTIONS]
```

**What it does:**

- Detects OS and installs .NET appropriately
- **macOS**: Uses Homebrew to install dotnet-sdk
- **Ubuntu/Debian**: Uses apt with version-specific packages
- **RHEL/Fedora**: Uses yum/dnf
- **Arch Linux**: Uses pacman
- **Fallback**: Uses Microsoft's official install script
- Verifies installation after completion

**Options:**

```bash
--version VERSION    .NET version (default: 10.0)
--sdk-only           Install only SDK
--runtime-only       Install only Runtime
--help, -h           Show help message
```

**Examples:**

```bash
# Install latest version (.NET 10.0 SDK)
./scripts/install-dotnet.sh

# Install .NET 8 LTS SDK
./scripts/install-dotnet.sh --version 8.0

# Install only runtime
./scripts/install-dotnet.sh --runtime-only

# Install specific version via environment variable
DOTNET_VERSION=9.0 ./scripts/install-dotnet.sh
```

**Supported .NET Versions:**

- .NET 10 (latest - default)
- .NET 9
- .NET 8 (LTS)

**After Installation:**

```bash
# Verify installation
dotnet --version
dotnet --info

# If dotnet command not found, try these:
# 1. Restart your shell
exec $SHELL -l

# 2. Or reload your shell config
source ~/.zshrc  # or ~/.bashrc

# 3. Or clear command hash (bash/zsh)
hash -r

# 4. Run diagnostics
./scripts/check-dotnet.sh

# Create test app
dotnet new console -n MyApp
```

---

#### `check-dotnet.sh`

Diagnostic tool to troubleshoot .NET installation and PATH issues.

```bash
./scripts/check-dotnet.sh
```

**What it does:**

- Shows current PATH and checks if dotnet is in it
- Searches for dotnet binary in common locations
- Lists installed .NET packages (apt/brew/yum/pacman)
- Checks shell profile files for dotnet configuration
- Provides actionable troubleshooting steps

**When to use:**

- After installing .NET but getting "command not found"
- When dotnet works in one shell but not another
- To verify .NET installation locations
- To debug PATH configuration issues

**Example output:**

```bash
=== .NET Installation Diagnostics ===

Current PATH:
     1  /usr/local/bin
     2  /usr/bin
     3  /bin
     ...

Checking 'dotnet' command:
✓ dotnet found in PATH
Location: /usr/bin/dotnet
Version: 10.0.101

Searching for dotnet binary:
✓ Found: /usr/bin/dotnet
  Version: 10.0.101
```

---

#### `install-js-packages.sh`

Install JavaScript/TypeScript packages globally using bun from a YAML config file.

```bash
./scripts/install-js-packages.sh [OPTIONS]
```

**What it does:**

- Reads package list from `scripts/config/js.pkg.yml`
- Installs packages globally using bun
- Supports install, list, and update operations
- Auto-creates default config if missing

**Prerequisites:**

Install bun first:

```bash
# Via mise (recommended)
mise use -g bun@latest

# Or direct install
curl -fsSL https://bun.sh/install | bash
```

**Options:**

```bash
--install, -i       Install packages from config (default)
--list, -l          List globally installed packages
--update, -u        Update all packages to latest versions
--yes, -y           Auto-confirm installation (no prompts)
--help, -h          Show help message
```

**Examples:**

```bash
# Install packages from config (interactive)
./scripts/install-js-packages.sh

# Install without confirmation
./scripts/install-js-packages.sh --yes

# List installed packages
./scripts/install-js-packages.sh --list

# Update all packages to latest
./scripts/install-js-packages.sh --update
```

**Config file:** `scripts/config/js.pkg.yml`

```yaml
packages:
  - typescript
  - tsx
  - prettier
  - eslint
  - vite
  - vitest
  # ... more packages
```

**Customize packages:**

```bash
# Edit config file
nano scripts/config/js.pkg.yml

# Then install
./scripts/install-js-packages.sh
```

**Default packages included:**

- Package managers: pnpm, yarn
- TypeScript: typescript, tsx, ts-node
- Linting/Formatting: eslint, prettier, biome
- Build tools: vite, esbuild, tsup
- Testing: vitest, jest
- Dev tools: nodemon, concurrently, rimraf
- CLI tools: http-server, serve, npm-check-updates
- Documentation: typedoc, jsdoc

---

---

#### `install-lazyvim.sh`

Install [LazyVim](https://www.lazyvim.org/) - A Neovim distribution with pre-configured plugins and LSP support.

```bash
./scripts/install-lazyvim.sh [OPTIONS]
```

**What it does:**

- Backs up existing Neovim configuration
- Clones the LazyVim starter template
- Removes .git folder for customization
- Checks for required and optional dependencies

**Prerequisites:**

- Neovim (>= 0.9.0)
- Git
- Optional: ripgrep, fd, lazygit (recommended for full features)

**Options:**

```bash
--no-backup    Skip backing up existing configuration
--force        Force reinstall even if already installed
--help         Show help message
```

**Examples:**

```bash
# Install with backup (recommended)
./scripts/install-lazyvim.sh

# Install without backup
./scripts/install-lazyvim.sh --no-backup

# Force reinstall
./scripts/install-lazyvim.sh --force
```

**After installation:**

```bash
# Start Neovim
nvim

# LazyVim will automatically install plugins on first launch
# Run health check
:LazyHealth

# Open Lazy plugin manager
# Press <leader>l
```

**Configuration location:**

- Config: `~/.config/nvim`
- Backup: `~/.config/nvim.bak`
- Data: `~/.local/share/nvim`
- State: `~/.local/state/nvim`

**Key features:**

- Pre-configured LSP, treesitter, completion
- File explorer, fuzzy finder, git integration
- Beautiful UI with statusline and bufferline
- Extensive keymaps (<leader> = space by default)
- Easy customization via lua config

**Documentation:** https://www.lazyvim.org/

---

### Utility Scripts

#### `manage-stow.sh`

Manage GNU Stow packages for dotfiles (stow/unstow/restow configurations).

```bash
./scripts/manage-stow.sh [COMMAND] [OPTIONS] [PACKAGES...]
```

**What it does:**

- Stows (symlinks) dotfiles packages to home directory
- Manages symlinks for configuration files
- Supports stow, unstow, and restow operations
- Auto-detects available packages
- Shows stow status

**Commands:**

```bash
stow, -s              Stow packages (create symlinks)
restow, -r            Re-stow packages (update symlinks)
unstow, -u            Unstow packages (remove symlinks)
list, -l              List available packages
status                Show stow status for default packages
help, -h              Show help message
```

**Default Packages:**

- zsh - Zsh shell configuration
- mise - Mise version manager config
- zellij - Zellij terminal multiplexer
- bat - Bat (cat replacement) config
- nvim - Neovim configuration
- starship - Starship prompt config

**Examples:**

```bash
# Stow default packages
./scripts/manage-stow.sh stow

# Stow specific packages
./scripts/manage-stow.sh stow zsh nvim git

# Re-stow all defaults (update symlinks after changes)
./scripts/manage-stow.sh restow

# Unstow a specific package
./scripts/manage-stow.sh unstow zellij

# List all available packages
./scripts/manage-stow.sh list

# Show stow status
./scripts/manage-stow.sh status
```

**Common workflows:**

```bash
# After editing dotfiles, update symlinks
git pull
./scripts/manage-stow.sh restow

# Install new package
./scripts/manage-stow.sh stow alacritty

# Remove package symlinks before deletion
./scripts/manage-stow.sh unstow old-package
rm -rf old-package
```

---

#### `backup.sh`

Backup existing configurations before installing dotfiles.

```bash
./scripts/backup.sh [BACKUP_DIR]
```

**What it does:**

- Creates timestamped backup directory
- Backs up existing config files
- Skips symlinks (already managed by stow)
- Saves backup location for restore

**Usage:**

```bash
# Automatic backup location
./scripts/backup.sh

# Custom backup location
./scripts/backup.sh ~/my-backup

# Or set via environment
BACKUP_DIR=~/my-backup ./scripts/backup.sh
```

---

#### `uninstall.sh`

Remove dotfiles and optionally restore backups.

```bash
./scripts/uninstall.sh
```

**What it does:**

- Removes all symlinks created by stow
- Offers to restore from backup
- Offers to remove Zinit plugins
- Does NOT remove installed packages

---

### Other Scripts

#### `install-clawdbot.sh`

Install clawdbot (custom tool).

```bash
./scripts/install-clawdbot.sh
```

---

## Main Installation Script

The master installation script is located in the root: `../install.sh`

```bash
# Interactive mode (recommended)
./install.sh

# Non-interactive modes
./install.sh --full      # Full installation
./install.sh --minimal   # Minimal installation
./install.sh --help      # Show help
```

See main [README](../README.md) for full installation instructions.

---

## Mise Configuration

### Quick Start

```bash
# 1. Install mise
./scripts/install-mise.sh

# 2. Activate in current shell
source ~/.zshrc

# 3. Install all tools from config
mise install
```

### Configuration File

The mise configuration is in `mise/.config/mise/config.toml` and will be symlinked to `~/.config/mise/config.toml` when you stow the mise package.

### Common Commands

```bash
mise install           # Install all tools from .mise.toml
mise list              # Show installed tools
mise upgrade           # Update all tools
mise use node@20       # Pin specific version globally
mise use -g python@3.12  # Pin version globally
mise doctor            # Verify installation
mise outdated          # Check for updates
```

### Customization

Edit `mise/.config/mise/config.toml` to add/remove tools or pin versions:

```toml
[tools]
node = "20.10.0"       # Pin specific version
python = "latest"      # Use latest stable
go = "1.21"            # Pin to 1.21.x
```

After editing, run:
```bash
cd ~/.dotfiles
stow mise              # Symlink the config
mise install           # Install tools
```

---

## OS Detection

All scripts detect the operating system and use appropriate package managers:

- **macOS**: Homebrew
- **Debian/Ubuntu**: apt-get
- **RHEL/CentOS/Fedora**: yum/dnf
- **Arch Linux**: pacman
- **NixOS**: Warns to add to configuration.nix

---

## Script Features

All scripts include:

- ✅ Color-coded logging (INFO/WARN/ERROR)
- ✅ Idempotent (safe to run multiple times)
- ✅ OS detection and adaptation
- ✅ Error handling with `set -e`
- ✅ Help text with `--help` flag

---

## Troubleshooting

### Permission Issues

If scripts fail due to permissions:

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Or run with bash
bash scripts/install-mise.sh
```

### Sudo Password

Some scripts require sudo. Ensure you have sudo access:

```bash
sudo -v
```

### PATH Issues

If tools aren't found after installation:

```bash
# Reload shell configuration
source ~/.zshrc

# Or restart terminal
exec zsh
```
