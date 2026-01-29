# Installation Scripts

Collection of utility scripts for setting up and managing dotfiles.

## Available Scripts

### Core Installation Scripts

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
--version VERSION    .NET version (default: 8.0)
--sdk-only           Install only SDK
--runtime-only       Install only Runtime
--help, -h           Show help message
```

**Examples:**

```bash
# Install latest LTS (.NET 8.0 SDK)
./scripts/install-dotnet.sh

# Install .NET 10 SDK
./scripts/install-dotnet.sh --version 10.0

# Install only runtime
./scripts/install-dotnet.sh --runtime-only

# Install specific version via environment variable
DOTNET_VERSION=9.0 ./scripts/install-dotnet.sh
```

**Supported .NET Versions:**

- .NET 10 (latest)
- .NET 9
- .NET 8 (LTS - recommended)

**After Installation:**

```bash
dotnet --version
dotnet --info
dotnet new console -n MyApp
```

---

### Utility Scripts

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
