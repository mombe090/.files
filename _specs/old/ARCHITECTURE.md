# Dotfiles Repository Architecture

## Overview

This dotfiles repository follows a **simplified, delegated architecture** where the main `install.sh` acts as a thin orchestrator, delegating all business logic to specialized, self-contained scripts.

## Architecture Principles

### 1. Single Responsibility
- **install.sh**: Orchestrator only - no business logic, just calls scripts
- **_scripts/linux/sh/\*.sh**: Self-contained scripts that handle all their own logic

### 2. No Duplicate Checks
- Scripts handle their own checks (OS detection, tool availability, etc.)
- install.sh does NOT duplicate these checks
- Each script is responsible for its own error handling and messaging

### 3. Graceful Degradation
- Scripts check if tools are already installed before installing
- Scripts exit gracefully (exit 0) if not applicable to current environment
- Optional dependencies don't block the installation flow

### 4. Clear Separation of Concerns
```
install.sh (Orchestrator)
├── check_prerequisites()     → Checks only git & curl (required everywhere)
├── backup_configs()          → Backs up existing dotfiles
├── install_homebrew()        → Delegates to _scripts/linux/sh/installers/install-homebrew.sh
├── install_mise()            → Delegates to _scripts/linux/sh/installers/install-mise.sh
├── install_core_tools()      → Uses install_package() helper for mise/brew tools
├── install_optional_tools()  → Uses install_package() helper for mise/brew tools
├── install_dotnet()          → Delegates to _scripts/linux/sh/installers/install-dotnet.sh
├── install_mise_tools()      → Runs 'mise install' if mise available
├── stow_configs()            → Delegates to _scripts/linux/sh/tools/manage-stow.sh
└── post_install()            → Creates config files, delegates to _scripts/linux/sh/installers/install-js-packages.sh
```

## Script Responsibilities

### Core Scripts (Required)

#### install-homebrew.sh
**Purpose**: Install Homebrew package manager (macOS/Linux)
- Detects OS (macOS/Linux)
- Checks if brew already installed
- Installs brew using official installer
- Configures shell PATH (adds to .zshrc/.bashrc)
- **Exit**: 0 if successful or already installed

#### install-mise.sh
**Purpose**: Install mise version manager
- Checks if mise already installed
- Tries global install (sudo) or local install (~/.local/bin)
- Configures shell activation (adds to .zshrc/.bashrc)
- **Exit**: 0 if successful or already installed

#### install-zsh.sh
**Purpose**: Install zsh and set as default shell
- Detects OS (macOS/Debian/RHEL/Arch)
- Checks if zsh already installed
- Installs via appropriate package manager
- Adds zsh to /etc/shells if needed
- Sets zsh as default shell (requires logout)
- **Exit**: 0 if successful or already installed, 1 if unsupported OS

#### install-stow.sh
**Purpose**: Install GNU Stow for symlink management
- Detects OS (macOS/Debian/RHEL/Arch)
- Checks if stow already installed
- Installs via appropriate package manager
- **Exit**: 0 if successful or already installed, 1 if unsupported OS

### Optional Scripts

#### install-dotnet.sh
**Purpose**: Install .NET SDK (default: .NET 10.0)
- Detects OS and distribution
- Checks if dotnet already installed
- Installs via package manager (brew/apt/yum/dnf/pacman)
- Configures PATH if needed
- **Environment Variables**: `AUTO_INSTALL=true` for non-interactive mode
- **Exit**: 0 if successful, already installed, or user declined

#### install-js-packages.sh
**Purpose**: Install JavaScript/TypeScript packages globally via bun
- Reads package list from `_scripts/linux/config/js.pkg.yml`
- Checks if bun is available (exits gracefully if not)
- Installs packages with `bun install -g`
- Commands: install, list, update
- **Environment Variables**: `AUTO_CONFIRM=true` for non-interactive mode
- **Exit**: 0 always (graceful exit if bun not found)

### Management Scripts

#### manage-stow.sh
**Purpose**: Centralized GNU Stow package management
- Commands: stow, restow, unstow, list, status
- Default packages: zsh, mise, zellij, bat, nvim, starship
- **Auto-backup**: Creates timestamped backups of conflicting files before stowing
- Shows summary statistics after operations
- **Exit**: 0 if successful, 1 if stow not found or error

#### check-dotnet.sh
**Purpose**: Diagnostic tool for .NET PATH issues
- Searches for dotnet binary in common locations
- Shows installed dotnet packages
- Provides troubleshooting steps
- **Exit**: 0 always (diagnostic tool)

#### backup.sh
**Purpose**: Backup dotfiles before making changes
- Creates timestamped backup directory
- Backs up all dotfiles and configs
- **Exit**: 0 if successful

#### uninstall.sh
**Purpose**: Uninstall dotfiles and restore backups
- Unstows all packages
- Optionally restores from backup
- **Exit**: 0 if successful

## Installation Flow

### Full Installation (./install.sh --full)
```
1. check_prerequisites()      → Verify git & curl installed
2. backup_configs()           → Backup existing dotfiles
3. install_homebrew()         → Install brew (macOS/Linux)
4. install_mise()             → Install mise version manager
5. install_core_tools()       → Install zsh & stow
6. install_optional_tools()   → Install bat, eza, fzf, rg, fd, etc. via mise/brew
7. install_dotnet()           → Install .NET SDK 10.0
8. install_mise_tools()       → Install tools from mise config.toml
9. stow_configs()             → Symlink dotfiles (auto-backup conflicts)
10. post_install()            → Create .gitconfig.local, install JS packages
```

### Minimal Installation (./install.sh --minimal)
```
1. check_prerequisites()
2. backup_configs()
3. install_homebrew()
4. install_core_tools()       → Only zsh & stow
5. stow_configs()             → Only zsh & git configs
6. post_install()
```

## Configuration Files

### mise Config (`mise/.config/mise/config.toml`)
Defines tools and versions to install via mise:
- Node.js, Python, Go, Rust, etc.
- Automatically installed when running `mise install`

### JavaScript Packages (`_scripts/linux/config/js.pkg.yml`)
Defines JavaScript/TypeScript packages to install globally:
- 25+ packages: TypeScript, ESLint, Prettier, Vite, etc.
- Installed via `bun install -g` in post_install()

### Stow Packages (Default)
- **zsh**: Shell configuration
- **mise**: Version manager config
- **zellij**: Terminal multiplexer config
- **bat**: Syntax highlighting config
- **nvim**: Neovim configuration
- **starship**: Shell prompt config

## Key Features

### 1. Auto-Backup on Conflicts
`manage-stow.sh` automatically backs up conflicting files before stowing:
```bash
~/.dotfiles-stow-backup-20260129-143022/
├── .zshrc
├── .config/
│   └── nvim/
└── ...
```

### 2. Graceful Degradation
- Scripts check for tool availability before running
- Missing optional tools don't block installation
- Clear warnings for missing tools, not errors

### 3. Idempotent Operations
- All scripts can be run multiple times safely
- Check if already installed before installing
- Skip operations if already completed

### 4. Cross-Platform Support
- **macOS**: Homebrew, .NET via brew
- **Ubuntu/Debian**: apt, .NET via apt with backports
- **RHEL/Fedora**: yum/dnf, .NET via Microsoft repos
- **Arch**: pacman, .NET via AUR

### 5. Environment Detection
Scripts detect and adapt to:
- Operating System (macOS/Linux/distro)
- Architecture (arm64/x86_64)
- Existing installations (avoid duplicates)
- Sudo availability (global vs local installs)

## Error Handling

### Philosophy
- **install.sh**: Stops on error (`set -e`) except for optional tools
- **Scripts**: Handle their own errors, exit gracefully when appropriate
- **Optional tools**: Failures logged as warnings, don't stop installation

### Exit Codes
- **0**: Success or gracefully skipped (tool already installed, not applicable)
- **1**: Error (missing prerequisites, unsupported OS, failed installation)

### Logging Levels
```bash
log_info()    # General information (green)
log_warn()    # Warnings, non-fatal issues (yellow)
log_error()   # Errors, fatal issues (red)
log_success() # Successful operations (green, bold)
log_step()    # Major installation steps (blue, bold)
```

## Testing & Validation

### Syntax Check
```bash
bash -n install.sh
bash -n _scripts/linux/sh/installers/*.sh
bash -n _scripts/linux/sh/tools/*.sh
bash -n _scripts/linux/sh/checkers/*.sh
```

### Dry Run (Check Only)
```bash
# Check what would be installed without installing
./install.sh --help
./_scripts/linux/sh/tools/manage-stow.sh status
```

### Individual Script Testing
```bash
# Test individual scripts
./_scripts/linux/sh/installers/install-dotnet.sh
./_scripts/linux/sh/installers/install-js-packages.sh install
./_scripts/linux/sh/tools/manage-stow.sh stow
./_scripts/linux/sh/checkers/check-dotnet.sh
```

## Troubleshooting

### Common Issues

#### 1. .NET not in PATH
```bash
./_scripts/linux/sh/checkers/check-dotnet.sh  # Diagnostic tool
source ~/.zshrc                                # Reload shell
```

#### 2. Stow conflicts
```bash
# Manual backup & stow
./_scripts/linux/sh/tools/manage-stow.sh unstow
# Fix conflicts
./_scripts/linux/sh/tools/manage-stow.sh stow  # Auto-backups conflicts
```

#### 3. Missing bun (JS packages)
```bash
# Install bun first
curl -fsSL https://bun.sh/install | bash
# Then install JS packages
./_scripts/linux/sh/installers/install-js-packages.sh install
```

## Future Improvements

### Potential Enhancements
1. **Shared Utility Library**: Extract common functions (logging, OS detection) to `lib/utils.sh`
2. **--help Support**: Add `--help` flag to all scripts for usage info
3. **Verbose Mode**: Add `--verbose` flag for detailed logging
4. **Dry-Run Mode**: Add `--dry-run` to show what would be installed without installing
5. **Rollback**: Enhanced uninstall with automatic backup restoration
6. **Test Suite**: Add automated tests for all scripts

### Consistency Improvements
1. Standardize error messages across all scripts
2. Use consistent log formatting (currently good, could be even more consistent)
3. Add progress indicators for long-running operations
4. Consider JSON output mode for scripting

## Best Practices

### When Adding New Scripts
1. **Self-contained**: Script should handle all its own logic
2. **Idempotent**: Can be run multiple times safely
3. **Check first**: Verify if already installed before installing
4. **Exit gracefully**: Use exit 0 for "not applicable" scenarios
5. **Log clearly**: Use consistent log_info/warn/error/success messages
6. **Handle errors**: Provide clear error messages and exit codes
7. **OS detection**: Support macOS + major Linux distros
8. **Executable**: Always `chmod +x` new scripts

### When Modifying install.sh
1. **Don't duplicate**: Let scripts handle their own checks
2. **Delegate only**: install.sh should only call scripts, not implement logic
3. **Handle failures**: Use `|| true` for optional operations
4. **Keep simple**: install.sh is just an orchestrator
5. **Test syntax**: Run `bash -n install.sh` after changes

## Version History

### v2.0 - Simplified Architecture (Jan 2026)
- Removed duplicate checks from install.sh
- All business logic moved to individual scripts
- Scripts are now fully self-contained
- Added auto-backup to manage-stow.sh
- Standardized error handling and logging
- Improved cross-platform support

### v1.0 - Initial Release
- Basic dotfiles installation
- Manual stow management
- Limited error handling

---

**Maintained by**: mombe090  
**Repository**: https://github.com/mombe090/.files  
**Last Updated**: January 29, 2026
