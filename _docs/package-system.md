# Package Management System

The dotfiles repository includes a comprehensive YAML-based package management system that supports multiple package managers across different operating systems.

## Overview

The package system provides a unified way to install and manage packages across:

- **Homebrew** (macOS)
- **APT** (Ubuntu/Debian)
- **DNF** (Fedora/RHEL)
- **Pacman** (Arch Linux)
- **Mise** (Cross-platform version manager)

## Quick Start

### Install Essential Packages Only

```bash
just packages_minimal
```

This installs only the `essentials` category (git, curl, wget, stow, zsh).

### Install All Professional Packages

```bash
just packages_pro
```

Installs all packages from the professional profile (macOS + Ubuntu/Debian).

### Install All Personal Packages

```bash
just packages_perso
```

Installs all packages from the personal profile (all platforms + distros).

### Install Specific Category

```bash
just packages_category development
```

Available categories:

1. **essentials** - Core tools (git, curl, wget, stow, zsh)
2. **development** - Dev tools (neovim, ripgrep, fd, fzf)
3. **build_tools** - Compilers and build systems (gcc, make, cmake)
4. **libraries** - Development libraries (openssl, libffi, zlib)
5. **cloud** - Cloud CLIs (aws-cli, azure-cli, gcloud)
6. **fonts** - Nerd Fonts for terminal icons
7. **shell_tools** - Shell enhancements (bat, eza, zoxide, starship)
8. **monitoring** - System monitors (btop, htop)
9. **runtimes** - Language runtimes and interpreters

## Configuration Files

### Location

```text
_scripts/configs/unix/packages/
├── pro/                        # Professional packages
│   ├── apt.pkg.yml            # APT packages (Ubuntu/Debian)
│   ├── brew.pkg.yml           # Homebrew packages (macOS)
│   └── mise.pkg.yml           # Mise tools
└── perso/                      # Personal packages
    ├── apt.pkg.yml            # APT packages
    ├── brew.pkg.yml           # Homebrew packages
    ├── dnf.pkg.yml            # DNF packages (Fedora/RHEL)
    ├── pacman.pkg.yml         # Pacman packages (Arch)
    └── mise.pkg.yml           # Mise tools
```

### Profile Differences

**Professional (`pro/`)**:

- Targets: macOS + Ubuntu/Debian only
- Use case: Work machines, consistent environment
- Package managers: Homebrew, APT, Mise

**Personal (`perso/`)**:

- Targets: All platforms and distributions
- Use case: Personal machines, home servers
- Package managers: Homebrew, APT, DNF, Pacman, Mise

### YAML Structure

```yaml
category:
  - name: package-name
    description: "Package description"
    optional: false  # Optional field, default false
```

Example:

```yaml
essentials:
  - name: git
    description: "Distributed revision control system"
  - name: curl
    description: "Get a file from an HTTP, HTTPS or FTP server"
  - name: zsh
    description: "UNIX shell (command interpreter)"
```

## Just Commands

### Installation

```bash
# Install essentials only
just packages_minimal

# Install all pro packages
just packages_pro

# Install all personal packages
just packages_perso

# Install specific category
just packages_category essentials
```

### Discovery

```bash
# Show package system info
just packages_info

# List all categories
just packages_list_categories

# Preview what would be installed
just packages_dry_run pro

# Search for packages
just packages_search neovim
```

### Maintenance

```bash
# Update all packages via all package managers
just packages_update

# Clean package manager caches
just packages_clean

# Show installed packages
just packages_installed
```

## Direct Script Usage

You can also call the package installer directly:

```bash
# Install pro packages (minimal mode)
bash _scripts/unix/installers/install-packages.sh --pro --minimal

# Install all pro packages
bash _scripts/unix/installers/install-packages.sh --pro

# Install personal packages
bash _scripts/unix/installers/install-packages.sh --perso

# Install specific category
bash _scripts/unix/installers/install-packages.sh --pro --category development

# Dry-run mode (show what would be installed)
bash _scripts/unix/installers/install-packages.sh --pro --dry-run
```

## Installation Process

### 1. OS Detection

The installer automatically detects your operating system and selects the appropriate package configuration file:

- **macOS** → `brew.pkg.yml`
- **Ubuntu/Debian** → `apt.pkg.yml`
- **Fedora/RHEL** → `dnf.pkg.yml` (perso only)
- **Arch Linux** → `pacman.pkg.yml` (perso only)

### 2. Package Manager Selection

Based on OS detection, the installer uses the native package manager:

- **macOS**: Homebrew (`brew`)
- **Debian/Ubuntu**: APT (`apt`)
- **Fedora/RHEL**: DNF (`dnf`)
- **Arch Linux**: Pacman (`pacman`)

### 3. Category Processing

Packages are organized into categories for selective installation:

```bash
# Process only essentials
--minimal

# Process all categories
(default when --minimal not specified)

# Process specific category
--category development
```

### 4. Package Installation

For each package:

1. Check if already installed
2. If not installed:
   - Show description
   - Install via package manager
3. Track success/failure counts

### 5. Mise Tools

After system packages, install mise tools:

```bash
# Mise tools are installed separately
mise install node@latest
mise install python@latest
```

## Bootstrap Integration

The bootstrap script (`_scripts/bootstrap.sh`) uses the package system to install essential tools during initial setup:

```bash
# Phase 5: Install essential packages
bash _scripts/unix/installers/install-packages.sh --pro --minimal --category essentials
```

This ensures a consistent base environment before proceeding with dotfiles installation.

## Update Workflow

The `just update` command integrates package updates:

```bash
just update
```

This runs:

1. `git pull` - Update dotfiles
2. `just packages_update` - Update all packages
3. `mise upgrade` - Update mise tools
4. JavaScript package updates
5. `just restow` - Refresh symlinks

## Adding New Packages

### 1. Choose Configuration File

Decide which profile and OS:

- Professional macOS: `pro/brew.pkg.yml`
- Professional Ubuntu: `pro/apt.pkg.yml`
- Personal Fedora: `perso/dnf.pkg.yml`
- etc.

### 2. Add Package Entry

```yaml
category_name:
  - name: package-name
    description: "Package description"
    optional: false  # Set true for optional packages
```

### 3. Find Package Name

**Homebrew**:

```bash
brew search <query>
```

**APT**:

```bash
apt search <query>
```

**DNF**:

```bash
dnf search <query>
```

**Pacman**:

```bash
pacman -Ss <query>
```

### 4. Test Installation

```bash
# Dry-run to verify
just packages_dry_run pro

# Install category
just packages_category <category>
```

## Troubleshooting

### YQ Not Found

The package system requires `yq` (mikefarah's version):

```bash
# Install via mise
mise install yq@latest
mise use -g yq@latest
```

### Package Not Found

If a package isn't found:

1. Verify package name for your OS
2. Check if package is in correct category
3. Try searching: `just packages_search <name>`

### Wrong Package Manager

The installer auto-detects your OS. If it chooses the wrong package manager:

```bash
# Check OS detection
bash -c 'source _scripts/unix/lib/detect.sh && detect_os'
```

### Mise Tools Not Installing

Ensure mise is in PATH:

```bash
export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"
eval "$(mise activate bash)"  # or zsh
```

## Advanced Usage

### Custom Categories

You can create custom categories in the YAML files:

```yaml
my_custom_tools:
  - name: tool1
    description: "My custom tool"
  - name: tool2
    description: "Another tool"
```

Then install with:

```bash
bash _scripts/unix/installers/install-packages.sh --pro --category my_custom_tools
```

### Multiple Categories

Install multiple categories in sequence:

```bash
just packages_category essentials
just packages_category development
just packages_category shell_tools
```

### Platform-Specific Packages

Add packages only to specific platform configs:

- Want tool on macOS only? → Add to `brew.pkg.yml` only
- Want tool on Ubuntu only? → Add to `apt.pkg.yml` only
- Want tool everywhere? → Add to all configs

## Best Practices

1. **Use profiles correctly**:
   - `pro` for work machines (limited platforms)
   - `perso` for personal machines (all platforms)

2. **Categorize properly**:
   - `essentials` for must-have tools
   - `development` for dev tools
   - Use `optional: true` for nice-to-have packages

3. **Test before committing**:
   - Always dry-run first: `just packages_dry_run pro`
   - Test on your OS before adding to config

4. **Keep descriptions helpful**:
   - Use official package descriptions
   - Be concise but informative

5. **Update regularly**:
   - Run `just packages_update` periodically
   - Keep package lists current

## Examples

### Install Development Environment

```bash
# 1. Bootstrap essential tools
bash _scripts/bootstrap.sh

# 2. Install development packages
just packages_category development

# 3. Install build tools
just packages_category build_tools

# 4. Install cloud tools
just packages_category cloud
```

### Set Up New Machine

```bash
# 1. Clone dotfiles
git clone https://github.com/mombe090/.files.git ~/.dotfiles
cd ~/.dotfiles

# 2. Bootstrap (installs mise, yq, just, essentials)
bash _scripts/bootstrap.sh

# 3. Install all professional packages
just packages_pro

# 4. Install dotfiles
just install_full
```

### Update Everything

```bash
# One command to update all
just update

# Or manually:
git pull
just packages_update
mise upgrade
just restow
```

## See Also

- [Bootstrap Documentation](../README.md#method-1-bootstrap-recommended-for-new-machines)
- [Just Recipes](../README.md#common-just-commands)
- [Package Configs](_scripts/configs/unix/packages/)
