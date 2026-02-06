# Installation Profiles

## Overview

The dotfiles now support **profile-based installations** similar to Windows, allowing you to choose between different package sets based on your needs.

## Available Profiles

### 1. Full Installation (`install_full`)

**Everything included** - all tools and packages.

```bash
just install_full
```

**What's installed:**

- ✅ Homebrew (macOS) / native package managers (Linux)
- ✅ mise version manager
- ✅ Essential build tools (gcc, make, cmake, etc.)
- ✅ Core tools (zsh, stow, git configs)
- ✅ Optional CLI tools (bat, eza, fzf, ripgrep, fd, zoxide, etc.)
- ✅ Modern fonts (CascadiaMono, JetBrainsMono, VictorMono)
- ✅ .NET SDK
- ✅ Mise tools from config
- ✅ **JavaScript packages** (pro + personal via bun)
- ✅ All configurations stowed

### 2. Professional Installation (`install_pro`)

**Work-safe packages only** - suitable for company/work computers.

```bash
just install_pro
```

**What's installed:**

- ✅ Homebrew (macOS) / native package managers (Linux)
- ✅ mise version manager
- ✅ Essential build tools (gcc, make, cmake, etc.)
- ✅ **Professional packages** from `_scripts/configs/unix/packages/pro/`
  - Essential development tools
  - Standard language runtimes
  - Common DevOps tools
  - No experimental or personal tools
- ✅ Core tools (zsh, stow, git configs)
- ✅ Mise tools from config
- ✅ **JavaScript packages** (professional only via bun)
- ✅ All configurations stowed

**Platforms supported:**

- macOS (Homebrew)
- Ubuntu/Debian (APT)

### 3. Personal Installation (`install_perso`)

**Professional + personal packages** - for personal machines.

```bash
just install_perso
```

**What's installed:**

- ✅ Homebrew (macOS) / native package managers (Linux)
- ✅ mise version manager
- ✅ Essential build tools (gcc, make, cmake, etc.)
- ✅ **Personal packages** from `_scripts/configs/unix/packages/perso/`
  - All professional packages
  - Experimental runtimes (Deno, Bun)
  - Additional cloud tools
  - Personal productivity tools
  - Media/entertainment tools
- ✅ Core tools (zsh, stow, git configs)
- ✅ Optional CLI tools (bat, eza, fzf, etc.)
- ✅ Modern fonts
- ✅ .NET SDK
- ✅ Personal tools (clawdbot, etc.)
- ✅ Mise tools from config
- ✅ All configurations stowed

**Platforms supported:**

- macOS (Homebrew)
- Ubuntu/Debian (APT)
- Fedora/RHEL (DNF)
- Arch Linux (Pacman)

### 4. Minimal Installation (`install_minimal`)

**Core tools only** - quickest setup.

```bash
just install_minimal
```

**What's installed:**

- ✅ Homebrew (macOS)
- ✅ Core tools (zsh, stow)
- ✅ Basic configurations (zsh, git)

## Quick Comparison

| Feature | Full | Pro | Perso | Minimal |
|---------|------|-----|-------|---------|
| Homebrew/Package Managers | ✅ | ✅ | ✅ | ✅ |
| mise version manager | ✅ | ✅ | ✅ | ❌ |
| Build tools | ✅ | ✅ | ✅ | ❌ |
| Professional packages | ✅ | ✅ | ✅ | ❌ |
| Personal packages | ✅ | ❌ | ✅ | ❌ |
| Optional CLI tools | ✅ | ❌ | ✅ | ❌ |
| Modern fonts | ✅ | ❌ | ✅ | ❌ |
| .NET SDK | ✅ | ❌ | ✅ | ❌ |
| Personal tools | ✅ | ❌ | ✅ | ❌ |
| Mise tools | ✅ | ✅ | ✅ | ❌ |
| All configs stowed | ✅ | ✅ | ✅ | Partial |

## Package Locations

### Professional Packages (`pro/`)

Located in: `_scripts/configs/unix/packages/pro/`

**Files:**

- `apt.pkg.yml` - Debian/Ubuntu packages
- `brew.pkg.yml` - macOS Homebrew packages

**Categories:**

1. `essentials` - Core tools (git, curl, wget, stow, zsh)
2. `development` - Dev tools (neovim, ripgrep, fd, fzf)
3. `build_tools` - Compilers and build systems (gcc, make, cmake)
4. `libraries` - Development libraries (openssl, libffi, zlib)
5. `cloud` - Cloud CLIs (aws-cli, azure-cli, gcloud)
6. `fonts` - Nerd Fonts for terminal icons
7. `shell_tools` - Shell enhancements (bat, eza, zoxide, starship)
8. `monitoring` - System monitors (btop, htop)
9. `runtimes` - Language runtimes and interpreters

### Personal Packages (`perso/`)

Located in: `_scripts/configs/unix/packages/perso/`

**Files:**

- `apt.pkg.yml` - Debian/Ubuntu packages
- `brew.pkg.yml` - macOS Homebrew packages
- `dnf.pkg.yml` - Fedora/RHEL packages
- `pacman.pkg.yml` - Arch Linux packages

**Includes all professional packages PLUS:**

- Experimental runtimes (Deno, Bun)
- Additional cloud tools
- Personal productivity tools
- Media/entertainment tools

## Usage Examples

### Work Machine

```bash
# Clone dotfiles
git clone https://github.com/mombe090/.files.git ~/.dotfiles
cd ~/.dotfiles

# Bootstrap (install mise, just, essential tools)
bash _scripts/bootstrap.sh

# Install work-safe packages
just install_pro
```

### Personal Machine

```bash
# Clone dotfiles
git clone https://github.com/mombe090/.files.git ~/.dotfiles
cd ~/.dotfiles

# Bootstrap
bash _scripts/bootstrap.sh

# Install all packages (pro + personal)
just install_perso
```

### Quick Setup (Minimal)

```bash
# Clone dotfiles
git clone https://github.com/mombe090/.files.git ~/.dotfiles
cd ~/.dotfiles

# Minimal setup (no bootstrap needed)
bash _scripts/install.sh --minimal
```

## Interactive Menu

Run the installer without arguments for an interactive menu:

```bash
cd ~/.dotfiles
bash _scripts/install.sh
```

You'll see:

```text
==================================
   Dotfiles Installation Menu
==================================

Choose installation type:

  1) Full installation (recommended)
     - Installs everything including optional tools

  2) Professional installation
     - Work-safe packages only (no personal tools)

  3) Personal installation
     - Professional + personal packages

  4) Minimal installation
     - Only core tools (zsh, stow, git configs)

  5) Custom installation
     - Choose what to install

  6) Exit

Enter choice [1-6]:
```

## Package Management Commands

### Install Packages by Profile

```bash
# Install professional packages only
just packages_pro

# Install personal packages (includes pro)
just packages_perso

# Install minimal packages (essentials only)
just packages_minimal
```

### Install Packages by Category

```bash
# Install specific category
just packages_category essentials
just packages_category development
just packages_category cloud

# See all categories
just packages_list_categories
```

### Dry Run

```bash
# See what would be installed (pro)
just packages_dry_run pro

# See what would be installed (perso)
just packages_dry_run perso
```

## Windows Compatibility

The profile system matches Windows behavior:

**Windows:**

```powershell
.\\_scripts\install.ps1 -Type pro
.\\_scripts\install.ps1 -Type perso
```

**Unix/macOS:**

```bash
just install_pro
just install_perso
```

## See Also

- [Package System Documentation](_scripts/configs/unix/packages/README.md)
- [Package Categories](package-system.md)
- [Windows Installation](_scripts/windows/README.md)
