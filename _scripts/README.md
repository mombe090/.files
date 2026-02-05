# Windows Dotfiles

Simple and safe dotfiles implementation for Windows work environment.

## ⚡ Quick Setup (First Time)

**Step 1: Install PowerShell 7 and Git**

```powershell
# In Windows PowerShell (or cmd), install prerequisites:
winget install Microsoft.PowerShell
winget install Git.Git

# Restart your terminal, then open PowerShell 7:
pwsh
```

**Step 2: Enable Script Execution (Required)**

```powershell
# Allow running local scripts (required for install/uninstall)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Verify it's set
Get-ExecutionPolicy -List
```

**Step 3: Clone and Run**

```powershell
# Clone the repository
cd ~
git clone <your-repo-url> .files

# Run the installer
cd .files/_scripts
.\install.ps1
```

**Alternative: Bypass Execution Policy (One-Time)**

If you don't want to change the execution policy permanently:

```powershell
# Run installer with bypass (one-time)
powershell -ExecutionPolicy Bypass -File .\install.ps1

# Or for uninstall
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

That's it! The installer will guide you through the rest.

---

## 🎯 Design Principles

1. **Work Environment** - Conservative, non-intrusive configuration
2. **User-Level Only** - No system-wide changes
3. **No Registry Modifications** - Package managers handle all registry changes
4. **Admin Only for Packages** - PowerShell modules installed at user-level
5. **Windows 11 Only** - Simplified for modern Windows

## 📁 Structure

```
_scripts/
├── install.ps1                      # Main Windows installer
├── uninstall.ps1                    # Windows uninstaller
├── stow.ps1                         # Stow wrapper for Windows
├── unix/                            # Unix-like systems (Linux/macOS)
│   ├── installers/                  # Tool installation scripts
│   ├── tools/                       # Utility scripts
│   ├── checkers/                    # Validation scripts
│   └── lib/                         # Shared shell libraries
├── windows/                         # Windows-specific (PowerShell 7+)
│   ├── installers/                  # Application installers
│   ├── tools/                       # Utility scripts
│   ├── managers/                    # Package manager installers
│   └── lib/                         # PowerShell libraries
│       ├── colors.ps1               # Logging functions
│       ├── common.ps1               # Utility functions
│       ├── detect.ps1               # System detection
│       └── package-managers.ps1     # Package manager abstraction
├── omarchy/                         # Omarchy Linux installer
├── just/                            # Just command runner bootstrap
└── configs/                         # Configuration files (YAML)
    ├── unix/packages/               # Unix package configs
    └── windows/
        ├── packages/                # Windows package configs (pro/perso)
        └── platform/                # Platform configs
```

## 🚀 Quick Start

### Prerequisites

- Windows 11
- Windows Terminal (recommended)
- **PowerShell 7** (required for scripts)
- **Git** (required to clone this repository)

### Before You Begin

**Install PowerShell 7 and Git first if not already installed:**

```powershell
# Check if PowerShell 7 is installed
pwsh --version
# If not found, install via WinGet:
winget install Microsoft.PowerShell

# Check if Git is installed
git --version
# If not found, install via WinGet:
winget install Git.Git
```

**Alternatively, use the standalone installers:**

```powershell
# If you don't have WinGet, run these installers first:
.\windows\managers\Install-PowerShell.ps1    # Install PowerShell 7
.\windows\managers\Install-WinGet.ps1        # Install WinGet (if needed)

# Then install Git via WinGet
winget install Git.Git
```

**Clone the repository (if not already done):**

```powershell
# Using Git
cd ~
git clone <your-repo-url> .files
cd .files/_scripts
```

### Installation

**Important:** Run the installer in **PowerShell 7** (not Windows PowerShell 5.1):

```powershell
# Open PowerShell 7 (pwsh, not powershell)
pwsh

# Enable script execution if not already done
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Navigate to scripts directory
cd ~/.files/_scripts

# Interactive menu
.\install.ps1

# Or specify package type directly
.\install.ps1 -Type pro           # Work packages only
.\install.ps1 -Type perso         # Personal + professional packages
.\install.ps1 -Type all           # Everything (pro first, then perso)

# Check for updates and upgrade existing packages
.\install.ps1 -Type pro -CheckUpdate     # Update all pro packages
.\install.ps1 -Type perso -CheckUpdate   # Update all packages
```

**Important: Installation Order**

To prevent package conflicts and duplicates:

- **`-Type pro`**: Installs only professional packages
- **`-Type perso`**: Installs professional packages FIRST, then personal packages
- **`-Type all`**: Same as perso (installs pro first, then perso)

This ensures:
- ✅ Professional baseline is always established first
- ✅ No duplicate packages between pro and perso
- ✅ Personal packages can depend on professional packages
- ✅ Consistent environment across installations

**Update Checking:**

By default, already-installed packages are **skipped** (no update check). To check for and install updates:

```powershell
# Check for updates and upgrade all packages
.\install.ps1 -Type pro -CheckUpdate

# Update specific package type
.\install.ps1 -Type perso -CheckUpdate
```

**Benefits of default behavior (no update checking):**
- ✅ Faster installations (skips version checking for installed packages)
- ✅ Doesn't require internet for already-installed packages
- ✅ Predictable behavior (no unexpected updates)
- ✅ Use `-CheckUpdate` when you explicitly want to upgrade

**Installation Steps:**

1. **Package Managers** - Install/verify Chocolatey and winget
2. **System Packages** - Install applications (Git, VSCode, etc.)
3. **JavaScript Packages** - Install global JS tools via Bun (TypeScript, ESLint, etc.)
4. **PowerShell Modules** - Install PowerShell enhancements

```

**If you get "scripts is disabled" error:**

```powershell
# Option 1: Set execution policy (recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Option 2: Bypass for single execution
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Type pro
```

### Uninstallation

To uninstall packages and modules:

```powershell
# Navigate to scripts directory
cd ~/.files/_scripts

# Interactive menu
.\uninstall.ps1

# Or specify what to uninstall
.\uninstall.ps1 -Type pro -Force           # Uninstall pro packages
.\uninstall.ps1 -Type perso -Force         # Uninstall personal packages
.\uninstall.ps1 -Type all -Force           # Uninstall all packages
.\uninstall.ps1 -UninstallModules -Force   # Only uninstall PowerShell modules
```

**If you get execution policy error:**

```powershell
# Bypass for uninstall
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1 -Type pro -Force
```

### What Gets Installed

#### Package Manager (Admin Required)

- **WinGet** (preferred) or **Chocolatey** (fallback)

#### Packages (Admin Required)

**Professional (`pro`):**

- PowerShell 7 (Microsoft.PowerShell)
- Git (Git.Git)
- GitHub CLI (GitHub.cli)
- VSCode (Microsoft.VisualStudioCode)
- Windows Terminal (Microsoft.WindowsTerminal)
- PowerToys (Microsoft.PowerToys)
- Python (Python.Python.3.12)
- Node.js (OpenJS.NodeJS.LTS)
- ...and more

**Personal (`perso`):**

- VLC (VideoLAN.VLC)
- 7-Zip (7zip.7zip)
- Discord (Discord.Discord)
- Spotify (Spotify.Spotify)
- ...and more

#### PowerShell Modules (User-Level, No Admin)

- **PSReadLine** - Enhanced command-line editing
- **Terminal-Icons** - File icons in terminal
- **posh-git** - Git integration for PowerShell

## 📦 Fonts (Manual Installation)

Fonts are installed via package managers to avoid registry modifications:

```powershell
# Cascadia Code (Windows Terminal default)
winget install Cascadia.Fonts

# JetBrains Mono
winget install JetBrains.JetBrainsMono.NerdFont
```

Or via Chocolatey:

```powershell
choco install cascadiafonts
choco install jetbrainsmono
```

## ⚙️ Configuration

### Package Configuration

Packages are defined in YAML files:

- `configs/packages/pro/winget.pkg.yml` - Professional WinGet packages
- `configs/packages/pro/choco.pkg.yml` - Professional Chocolatey packages
- `configs/packages/perso/winget.pkg.yml` - Personal WinGet packages
- `configs/packages/perso/choco.pkg.yml` - Personal Chocolatey packages

### Adding Packages

Edit the appropriate YAML file:

```yaml
packages:
  - name: Package.Name
    description: Brief description (optional)
```

## 🔒 Security & Safety

### What We DON'T Do

- ❌ No registry modifications (package managers handle this)
- ❌ No system-wide settings changes
- ❌ No Explorer/Taskbar customization
- ❌ No automatic commits or destructive operations

### What We DO

- ✅ User-level PowerShell modules only
- ✅ Package managers handle all system changes
- ✅ Verify installations before proceeding
- ✅ Skip already-installed packages/modules
- ✅ Clear logging and error messages

## 🛠️ Advanced Usage

### Skip Steps

```powershell
# Skip packages (modules only)
.\install.ps1 -SkipPackages

# Skip modules (packages only)
.\install.ps1 -SkipModules

# Install professional packages, skip modules
.\install.ps1 -Type pro -SkipModules
```

### Update Checking

```powershell
# Default behavior: Skip update check for installed packages (faster)
.\install.ps1 -Type pro

# Check for updates and upgrade installed packages
.\install.ps1 -Type pro -CheckUpdate
.\install.ps1 -Type perso -CheckUpdate

# Update only system packages (skip JS packages)
.\windows\installers\Install-Packages.ps1 -Type pro -CheckUpdate

# Update only JavaScript packages
.\windows\installers\Install-JsPackages.ps1 -Type pro -CheckUpdate
```

### Individual Scripts

```powershell
# Install packages only
.\windows\installers\Install-Packages.ps1 -Type pro

# Install PowerShell modules only
.\windows\installers\Install-PwshModules.ps1

# Install JavaScript packages only (requires Bun)
.\windows\installers\Install-JsPackages.ps1 -Type pro

# Manage dotfiles with symlinks (like GNU Stow)
# Run from .files root directory
cd ..
.\stow.ps1 wezterm           # Stow wezterm
.\stow.ps1 -Unstow wezterm   # Unstow wezterm
.\stow.ps1 -ListPackages     # List packages

# Install WinGet
.\windows\managers\Install-WinGet.ps1

# Install Chocolatey
.\windows\managers\Install-Choco.ps1
```

For more information on managing dotfiles with stow, see [STOW_GUIDE.md](STOW_GUIDE.md).

## 📦 JavaScript Packages (Bun)

Install global JavaScript/TypeScript development tools using Bun package manager.

### Prerequisites

Bun must be installed first (included in professional packages):

```powershell
# Bun is installed automatically with professional packages
.\install.ps1 -Type pro

# Or install Bun manually via Chocolatey
choco install bun -y
```

### Quick Start

**Note:** JavaScript packages are now automatically installed when you run the main installer!

```powershell
# Automatic installation (recommended)
.\install.ps1 -Type pro          # Installs pro JS packages automatically
.\install.ps1 -Type perso        # Installs pro + perso JS packages automatically

# Manual installation (if needed)
.\windows\installers\Install-JsPackages.ps1 -Type pro

# Install only development category
.\windows\installers\Install-JsPackages.ps1 -Type pro -Category development

# Force reinstall/upgrade all packages
.\windows\installers\Install-JsPackages.ps1 -Type pro -Force
```

### What Gets Installed

**Professional JavaScript Packages (`pro`):**

- **TypeScript** - TypeScript compiler and language server
- **TSX** - TypeScript runner (Node.js alternative)
- **Prettier** - Opinionated code formatter
- **ESLint** - JavaScript/TypeScript linter
- **markdownlint-cli2** - Markdown linting tool
- **@qetza/replacetokens** - Token replacement utility

**Personal JavaScript Packages (`perso`):**

- **opencode** - OpenCode CLI tool

**Note:** When installing with `-Type perso` or `-Type all`, professional packages are installed first, then personal packages are added on top.

All packages are installed globally via Bun (`bun add --global`).

**Automatic PATH Configuration:**

The installation script automatically:
- Checks if Bun's global bin directory (`%USERPROFILE%\.bun\bin`) is in your PATH
- Adds it to your user PATH if missing
- Updates the current PowerShell session for immediate use

After installation, you may need to restart your terminal for new sessions to pick up the PATH changes.

### Configuration

Packages are defined in YAML files:

- `configs/packages/pro/js.pkg.yml` - Professional JavaScript packages
- `configs/packages/perso/js.pkg.yml` - Personal JavaScript packages (optional)

### Adding Custom Packages

Edit `configs/packages/pro/js.pkg.yml`:

```yaml
development:
  - id: package-name
    name: Package Display Name
    category: development
    
  - id: "@scope/package-name"
    name: Scoped Package
    category: development
```

**Note:** Scoped packages (e.g., `@qetza/replacetokens`) are fully supported.

### Usage Examples

After installation, these tools are available globally:

```powershell
# TypeScript compiler
tsc --version

# TypeScript runner
tsx --version

# Code formatter
prettier --version

# Linter
eslint --version

# Markdown linter
markdownlint-cli2 --version

# Token replacement
replacetokens --version
```

### Advanced Options

```powershell
# Install from custom config directory
.\windows\installers\Install-JsPackages.ps1 -ConfigDir "C:\custom\path"

# Install all packages (pro + personal)
.\windows\installers\Install-JsPackages.ps1 -Type all

# View detailed help
Get-Help .\windows\installers\Install-JsPackages.ps1 -Detailed
```

### Verifying Installation

```powershell
# List globally installed Bun packages
bun pm ls --global

# Check specific package
bun pm ls --global | Select-String "typescript"
```

### Troubleshooting

**Bun not found:**

```powershell
# Verify Bun is installed
bun --version

# If not installed, install via Chocolatey
choco install bun -y

# Restart your terminal after installation
```

**Package installation fails:**

```powershell
# Try forcing reinstall
.\windows\installers\Install-JsPackages.ps1 -Type pro -Force

# Or install manually
bun add --global typescript
```

**Scoped package issues:**

```powershell
# Scoped packages use @ symbol and may need quotes in some contexts
bun add --global "@qetza/replacetokens"
```

## 📝 Notes

### Admin Requirements

- **Required for:** Package manager installation, package installation
- **NOT required for:** PowerShell module installation
- **Why:** Package managers modify system paths and install to Program Files

### Registry Changes

We don't modify the Windows registry directly in our scripts. All registry changes are handled by the package managers (WinGet/Chocolatey) when they install applications. This ensures:

- Safe, tested installation procedures
- Proper uninstallation support
- Windows Update compatibility
- No manual registry cleanup needed

### Package Managers

**WinGet (Preferred):**

- Official Microsoft package manager
- Comes with Windows 11 (via App Installer)
- Better integration with Windows
- Automatic updates via Microsoft Store

**Chocolatey (Fallback):**

- Community-driven package manager
- Larger package repository
- Used if WinGet not available
- Requires manual installation

## 🐛 Troubleshooting

### Scripts Won't Run (Execution Policy) ⚠️ COMMON ISSUE

**Error:** "cannot be loaded because running scripts is disabled on this system"

**This is the most common issue!** Windows blocks PowerShell scripts by default for security.

**Solution (Recommended):**

```powershell
# Check current execution policy
Get-ExecutionPolicy

# Set execution policy for current user (safe, recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Verify it's set correctly
Get-ExecutionPolicy -List
```

**Quick Fix (One-Time Bypass):**

```powershell
# For install
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Type pro

# For uninstall
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1 -Type pro -Force
```

**What each policy means:**
- `Restricted` (default) - No scripts allowed
- `RemoteSigned` (recommended) - Downloaded scripts must be signed, local scripts OK
- `Bypass` - Temporary override for single command

### PowerShell Version Error

**Error:** "This script requires PowerShell 7 or higher"

**Solution:**

```powershell
# Check current PowerShell version
$PSVersionTable.PSVersion

# If version is 5.x (Windows PowerShell), install PowerShell 7:
winget install Microsoft.PowerShell

# Or use the standalone installer:
.\windows\managers\Install-PowerShell.ps1

# Then open PowerShell 7 (pwsh) and run the scripts
pwsh
```

**Note:** Make sure to run scripts in `pwsh` (PowerShell 7), not `powershell` (Windows PowerShell 5.1).

### Git Not Found

**Error:** "git: command not found" or cannot clone repository

**Solution:**

```powershell
# Install Git via WinGet
winget install Git.Git

# Or download from https://git-scm.com/download/win
# After installation, restart your terminal
```

### Package Manager Not Found

If WinGet is not detected:

```powershell
# Install App Installer from Microsoft Store
# Or run our installer
.\windows\managers\Install-WinGet.ps1
```

### PowerShell Module Installation Fails

```powershell
# Update PowerShellGet
Install-Module -Name PowerShellGet -Force -Scope CurrentUser

# Then retry
.\windows\installers\Install-PwshModules.ps1
```

### Package Installation Hangs

- Check your internet connection
- Try running with `-Verbose` flag
- Manually install the package to see detailed errors

## 📚 Libraries Reference

### `windows/lib/colors.ps1`

Logging functions with colors:

- `Write-Info` - Info messages (Cyan)
- `Write-Success` - Success messages (Green)
- `Write-Warn` - Warnings (Yellow)
- `Write-ErrorMsg` - Errors (Red)
- `Write-Header` - Section headers (Magenta)
- `Write-Step` - Sub-steps (White)

### `windows/lib/common.ps1`

Utility functions:

- `Test-Command` - Check if command exists
- `Invoke-WithRetry` - Retry failed operations
- `New-Backup` - Create backups
- `New-DirectorySafe` - Create directories safely
- `Get-ConfirmationPrompt` - Ask for confirmation
- `Test-InternetConnection` - Check connectivity

### `windows/lib/detect.ps1`

System detection:

- `Get-WindowsVersion` - Windows version info
- `Test-IsAdmin` - Check admin privileges
- `Get-SystemInfo` - Full system information
- `Test-IsWindows11` - Check if Windows 11
- `Get-PowerShellVersion` - PowerShell version

### `windows/lib/package-managers.ps1`

Package manager abstraction:

- `Get-PackageManager` - Detect available PM
- `Install-PackageWith` - Install with any PM
- `Test-PackageInstalled` - Check if installed
- `Get-PackageList` - List installed packages

## 🎯 Future Enhancements

Potential additions (not yet implemented):

- [ ] macOS dotfiles implementation
- [ ] Linux (Ubuntu) dotfiles implementation
- [ ] Automatic dotfile symlinking
- [ ] PowerShell profile configuration
- [ ] Windows Terminal settings sync
- [ ] VSCode settings sync
- [ ] Git configuration setup

## 📄 License

Part of personal dotfiles repository.

## 🤝 Contributing

This is a personal dotfiles repository, but suggestions and improvements are welcome!

---

**Note:** This implementation prioritizes safety and simplicity for work environments. If you need more advanced features or system customization, consider using a more comprehensive dotfiles framework.
