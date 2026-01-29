# Changelog

All notable changes to this dotfiles repository will be documented in this file.

## [Unreleased] - 2026-01-29

### Major Refactor: Simplified Architecture (v2.0)

#### Changed

- **Simplified `install.sh`** - Complete refactor to thin orchestrator pattern
  - **Removed ALL duplicate logic** - Scripts now handle their own checks
  - **Removed ~40 lines of duplicate code**
  - Each function now just delegates to appropriate script
  - No more duplicate checks for brew, mise, zsh, stow, dotnet, bun
  - Scripts are now fully responsible for their own logic:
    - OS detection
    - Installation checks
    - PATH configuration
    - Error handling
  - install.sh functions now 3-8 lines each (down from 15-25 lines)
  - Better error messages from scripts (clearer source of errors)
  - Added fallback logging when scripts not found/executable

- **Enhanced all scripts for self-containment**
  - Each script now includes its own logging functions
  - Each script handles its own prerequisite checks
  - Scripts exit gracefully when not applicable
  - Consistent exit codes across all scripts (0 = success/skip, 1 = error)
  - Scripts can be tested independently without install.sh

#### Added

- **`ARCHITECTURE.md`** - Comprehensive architecture documentation
  - Detailed explanation of simplified architecture principles
  - Script responsibilities and workflows
  - Installation flow breakdown
  - Error handling strategies
  - Cross-platform support details
  - Best practices for contributors
  - Future improvement roadmap

- **`docs/SIMPLIFIED_ARCHITECTURE.md`** - Visual architecture guide
  - Before/after code comparison
  - Visual flow diagrams
  - Function simplification breakdown (line count savings)
  - Benefits of simplified architecture
  - Testing strategies and examples
  - Future improvements section

- **Documentation section in README.md**
  - Links to all architecture docs
  - Links to troubleshooting guides
  - Links to installation guides
  - Better organized documentation structure

#### Benefits of v2.0

- ✅ **Single Responsibility**: Each script does ONE thing
- ✅ **No Duplication**: Logic exists in ONE place only
- ✅ **Easier Testing**: Scripts can be tested independently
- ✅ **Better Maintainability**: Edit one file to fix one thing
- ✅ **Clearer Errors**: Know exactly which script failed
- ✅ **Graceful Degradation**: Scripts handle edge cases internally
- ✅ **Self-Documenting**: Each script is self-contained and readable

### Added

- **`scripts/manage-stow.sh`** - Centralized GNU Stow package management
  - Stow/unstow/restow operations for dotfiles packages
  - Default packages: zsh, mise, zellij, bat, nvim, starship
  - **Auto-backup conflicting files before stowing** ✨
    - Automatically detects existing files that would conflict
    - Creates timestamped backups before removing conflicts
    - Backs up both regular files and symlinks
    - Tracks backup location in `~/.dotfiles-backup-location`
  - Auto-detects available packages in dotfiles repo
  - Shows stow status for packages
  - List available packages with default indicators
  - Supports custom package selection
  - Better error handling and user feedback
  - Summary statistics (stowed/failed/skipped)

- **`scripts/install-js-packages.sh`** - Install JavaScript/TypeScript packages globally via bun
  - Reads package list from YAML config file (`scripts/config/js.pkg.yml`)
  - Supports install, list, and update operations
  - Interactive confirmation (can skip with `--yes` flag)
  - Auto-creates default config with common packages
  - Simple YAML parser (no external dependencies)
  - Tracks installed/failed/skipped packages
  - Default packages: TypeScript, ESLint, Prettier, Vite, Vitest, and more

- **`scripts/config/js.pkg.yml`** - Package list configuration
  - YAML format for easy editing
  - Pre-configured with common JavaScript/TypeScript tools
  - Organized by category (package managers, build tools, testing, etc.)
  - Optional packages section for framework CLIs

- **`scripts/check-dotnet.sh`** - New diagnostic tool for .NET installation issues
  - Checks if dotnet is in PATH
  - Searches for dotnet binary in common locations (/usr/bin, /usr/local/bin, ~/.dotnet)
  - Shows installed .NET packages (OS-specific: apt/brew/yum/pacman)
  - Checks shell profile files for dotnet configuration
  - Provides actionable troubleshooting steps
  - Helps diagnose PATH configuration problems

- **`DOTNET_TROUBLESHOOTING.md`** - Comprehensive troubleshooting guide
  - Common issues and solutions
  - Platform-specific notes (Ubuntu/Debian, macOS, RHEL/Fedora)
  - PATH configuration instructions
  - Manual installation fallback steps
  - Quick reference commands

- **`VM_DOTNET_FIX.md`** - Quick fix guide for VM installations
  - TL;DR solution for "command not found" errors
  - Why the issue happens (shell command caching)
  - Multiple solution options
  - Verification steps

- **`INSTALLATION_FLOW.md`** - Complete installation flow documentation
  - Step-by-step flow diagram
  - JavaScript packages integration explanation
  - Different installation scenarios
  - Customization options

### Changed

- **`scripts/install-js-packages.sh`** - Install JavaScript/TypeScript packages globally via bun
  - Reads package list from YAML config file (`scripts/config/js.pkg.yml`)
  - Supports install, list, and update operations
  - Interactive confirmation (can skip with `--yes` flag)
  - Auto-creates default config with common packages
  - Simple YAML parser (no external dependencies)
  - Tracks installed/failed/skipped packages
  - Default packages: TypeScript, ESLint, Prettier, Vite, Vitest, and more

- **`scripts/config/js.pkg.yml`** - Package list configuration
  - YAML format for easy editing
  - Pre-configured with common JavaScript/TypeScript tools
  - Organized by category (package managers, build tools, testing, etc.)
  - Optional packages section for framework CLIs

- **`scripts/check-dotnet.sh`** - New diagnostic tool for .NET installation issues
  - Checks if dotnet is in PATH
  - Searches for dotnet binary in common locations (/usr/bin, /usr/local/bin, ~/.dotnet)
  - Shows installed .NET packages (OS-specific: apt/brew/yum/pacman)
  - Checks shell profile files for dotnet configuration
  - Provides actionable troubleshooting steps
  - Helps diagnose PATH configuration problems

- **`DOTNET_TROUBLESHOOTING.md`** - Comprehensive troubleshooting guide
  - Common issues and solutions
  - Platform-specific notes (Ubuntu/Debian, macOS, RHEL/Fedora)
  - PATH configuration instructions
  - Manual installation fallback steps
  - Quick reference commands

- **`VM_DOTNET_FIX.md`** - Quick fix guide for VM installations
  - TL;DR solution for "command not found" errors
  - Why the issue happens (shell command caching)
  - Multiple solution options
  - Verification steps

### Changed

- **`install.sh`** - Enhanced installation process
  - Fixed .NET installation step visibility (shows even when already installed)
  - Better feedback during full installation mode
  - Clearer success/skip messages
  - Enhanced completion message with troubleshooting tips
  - **Integrated manage-stow.sh for package management**
    - Uses new manage-stow.sh script for stowing packages
    - Default packages reduced to core set: zsh, mise, zellij, bat, nvim, starship
    - Minimal install now stows only zsh and git
    - Fallback to manual stow if script not found
  - **Simplified JavaScript packages installation**
    - Delegates all logic to install-js-packages.sh script
    - No duplicate bun checks in main installer
    - Single responsibility: just call the script
    - Script handles all bun detection, messaging, and installation

- **`scripts/install-js-packages.sh`** - Improved messaging
  - Changed "error" to "warning" when bun not found
  - More helpful instructions for post-install
  - Graceful exit when bun unavailable (exit 0 instead of exit 1)
  - Better suited for automated installation flows

- **`scripts/install-dotnet.sh`** - Updated default .NET version from 8.0 to 10.0
  - Default installation now uses .NET 10 (latest stable)
  - Updated help documentation and examples
  - Improved verification with better PATH troubleshooting
  - Added detailed diagnostics for PATH issues
  - Better instructions referencing dotfiles env config

- **`zsh/.config/zsh/env.zsh`** - Added .NET PATH configuration
  - macOS: Sets DOTNET_ROOT for Homebrew installations
  - Linux: Automatically adds ~/.dotnet to PATH if manually installed
  - WSL: Configures PATH for manual installations
  - Smart detection: Only adds to PATH if not already available via package manager

### Added

- **`scripts/check-dotnet.sh`** - New diagnostic tool for .NET installation issues
  - Checks if dotnet is in PATH
  - Searches for dotnet binary in common locations (/usr/bin, /usr/local/bin, ~/.dotnet)
  - Shows installed .NET packages (OS-specific: apt/brew/yum/pacman)
  - Checks shell profile files for dotnet configuration
  - Provides actionable troubleshooting steps
  - Helps diagnose PATH configuration problems

- **`DOTNET_TROUBLESHOOTING.md`** - Comprehensive troubleshooting guide
  - Common issues and solutions
  - Platform-specific notes (Ubuntu/Debian, macOS, RHEL/Fedora)
  - PATH configuration instructions
  - Manual installation fallback steps
  - Quick reference commands

- **`VM_DOTNET_FIX.md`** - Quick fix guide for VM installations
  - TL;DR solution for "command not found" errors
  - Why the issue happens (shell command caching)
  - Multiple solution options
  - Verification steps

### Documentation

- **`scripts/README.md`** - Updated .NET installation docs
  - Changed default version from 8.0 to 10.0
  - Added check-dotnet.sh documentation
  - Better post-installation instructions
  - Shell reload commands for fixing PATH issues

## [1.0.0] - 2026-01-27

### Added

#### Installation System

- **`install.sh`** - Master installation script with interactive menu
  - Three installation modes: Full, Minimal, and Custom
  - Automatic backup of existing configurations
  - mise-first approach with fallback to system package managers
  - OS detection (macOS, Debian, RHEL, Arch, NixOS)
  - Intelligent package installation via mise or Homebrew/apt/yum/pacman
  - Post-install setup (gitconfig.local, env files)
  - Non-interactive flags: `--full`, `--minimal`, `--help`

#### Utility Scripts

- **`scripts/backup.sh`** - Backup existing dotfiles
  - Timestamped backup directories
  - Skips symlinks automatically
  - Tracks backup location for easy restore
  
- **`scripts/uninstall.sh`** - Uninstall dotfiles and restore backups
  - Removes all stow symlinks
  - Optional backup restoration
  - Optional Zinit cleanup

#### Configuration Files

- **`mise/.config/mise/config.toml`** - mise tool version manager configuration
  - Pre-configured with common development tools
  - Languages: Node.js, Python, Go, Rust, Ruby
  - CLI tools: bat, eza, fzf, ripgrep, delta, btop, etc.
  - Infrastructure tools: terraform, opentofu, kubectl, helm, k9s
  - DevOps tools: argocd, awscli, lazygit, github-cli
  - Will be symlinked to `~/.config/mise/config.toml` via stow
  
- **`git/.gitconfig.template`** - Template for sharing git config
  - Separates personal info into `.gitconfig.local`
  - Includes all settings without personal data

#### Documentation

- Updated **`README.md`** with:
  - Comprehensive installation instructions
  - Three installation modes explained
  - Complete dependency list
  - Troubleshooting section
  - Contributing guidelines
  - Detailed tools table with descriptions
  
- Updated **`scripts/README.md`** with:
  - Documentation for all scripts
  - Usage examples
  - Common commands reference
  - Troubleshooting tips

- **`CHANGELOG.md`** - This file for tracking changes

### Fixed

#### Critical Configuration Issues

- **`zsh/.config/zsh/env.zsh`**
  - ✅ Removed duplicate JAVA_HOME and PATH declarations
  - ✅ Removed hardcoded Node.js version (25.2.1) from PATH
  - ✅ Added conditional checks for Java installation
  - ✅ Reorganized OS-specific configurations
  - ✅ Added comment to use mise for Node.js version management
  
- **`zsh/.config/zsh/aliases.zsh`**
  - ✅ Fixed duplicate `gp` alias (git push)
  - ✅ Renamed `gp='git push origin'` to `gpo='git push origin'`
  
- **`zsh/.zshrc`**
  - ✅ Fixed mise activation logic (was skipping macOS)
  - ✅ Now checks if mise exists before activating
  - ✅ Works on all operating systems

#### Git Configuration

- **`git/.gitconfig`**
  - ✅ Changed default branch from `master` to `main`
  - ✅ Added include for `~/.gitconfig.local`
  - ✅ Added comments about personal information
  - ✅ Fixed email format (removed angle brackets)

### Changed

- **`.gitignore`**
  - Added `.gitconfig.local` to prevent committing personal info
  - Added `.dotfiles-backup-location` tracking file

### Security

- Git personal information (name/email) now stored in `.gitconfig.local`
- `.gitconfig.local` added to `.gitignore`
- Template file provided for sharing configuration without personal data

---

## Notes for Users

### Migration Guide

If you're updating from an older version:

1. **Backup your current setup:**
   ```bash
   ./scripts/backup.sh
   ```

2. **Pull the latest changes:**
   ```bash
   git pull origin main
   ```

3. **Create your personal git config:**
   ```bash
   cat > ~/.gitconfig.local << EOF
   [user]
       name = Your Name
       email = your.email@example.com
   EOF
   ```

4. **Re-run installation (optional):**
   ```bash
   ./install.sh
   ```

### Breaking Changes

⚠️ **Node.js PATH**: If you relied on the hardcoded Node.js path, you now need to:
- Use mise: `mise use -g node@latest`
- Or use nvm/homebrew and manage manually

⚠️ **Git Default Branch**: Changed from `master` to `main`
- Update your existing repos if needed

⚠️ **mise Activation**: Now activates on all OS (previously skipped macOS)
- If you don't want mise, comment out the activation in `.zshrc`

### Recommended Next Steps

1. Install mise and tools:
   ```bash
   mise install
   ```

2. Set up your personal git configuration:
   ```bash
   nano ~/.gitconfig.local
   ```

3. Restart your shell or source config:
   ```bash
   source ~/.zshrc
   ```

---

## Version History

### [1.0.0] - 2026-01-27

- Initial tagged release with complete installation system
- All critical configuration issues fixed
- Comprehensive documentation added
