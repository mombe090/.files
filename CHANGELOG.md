# Changelog

All notable changes to this dotfiles repository will be documented in this file.

## [Unreleased] - 2026-01-27

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
