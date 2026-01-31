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

**Step 2: Clone and Run**

```powershell
# Clone the repository
cd ~
git clone <your-repo-url> .files

# Run the installer
cd .files/_scripts
.\install.ps1
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
├── install.ps1                      # Main installer
├── lib/pwsh/                        # PowerShell libraries
│   ├── colors.ps1                   # Logging functions
│   ├── common.ps1                   # Utility functions
│   ├── detect.ps1                   # System detection
│   └── package-managers.ps1         # Package manager abstraction
├── windows/pwsh/                    # Windows-specific scripts
│   ├── install-packages.ps1         # Package installer
│   └── setup-windows.ps1            # PowerShell module installer
├── installers/pwsh/                 # Package manager installers
│   ├── winget.ps1                   # WinGet installer
│   ├── choco.ps1                    # Chocolatey installer
│   └── powershell.ps1               # PowerShell 7 installer
└── configs/                         # Configuration files
    ├── packages/pro/                # Professional packages
    ├── packages/perso/              # Personal packages
    └── platform/                    # Platform configs
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
.\installers\pwsh\powershell.ps1    # Install PowerShell 7
.\installers\pwsh\winget.ps1        # Install WinGet (if needed)

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

# Navigate to scripts directory
cd ~/.files/_scripts

# Interactive menu
.\install.ps1

# Or specify package type directly
.\install.ps1 -Type pro           # Work packages only
.\install.ps1 -Type perso         # Personal packages only
.\install.ps1 -Type all           # Everything
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

### Individual Scripts

```powershell
# Install packages only
.\windows\pwsh\install-packages.ps1 -Type pro

# Install PowerShell modules only
.\windows\pwsh\setup-windows.ps1

# Install WinGet
.\installers\pwsh\winget.ps1

# Install Chocolatey
.\installers\pwsh\choco.ps1
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

### PowerShell Version Error

**Error:** "This script requires PowerShell 7 or higher"

**Solution:**

```powershell
# Check current PowerShell version
$PSVersionTable.PSVersion

# If version is 5.x (Windows PowerShell), install PowerShell 7:
winget install Microsoft.PowerShell

# Or use the standalone installer:
.\installers\pwsh\powershell.ps1

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
.\installers\pwsh\winget.ps1
```

### PowerShell Module Installation Fails

```powershell
# Update PowerShellGet
Install-Module -Name PowerShellGet -Force -Scope CurrentUser

# Then retry
.\windows\pwsh\setup-windows.ps1
```

### Package Installation Hangs

- Check your internet connection
- Try running with `-Verbose` flag
- Manually install the package to see detailed errors

### Scripts Won't Run (Execution Policy)

**Error:** "cannot be loaded because running scripts is disabled"

**Solution:**

```powershell
# Check current execution policy
Get-ExecutionPolicy

# Set execution policy for current user (recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or bypass for a single script
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

## 📚 Libraries Reference

### `lib/pwsh/colors.ps1`

Logging functions with colors:

- `Write-Info` - Info messages (Cyan)
- `Write-Success` - Success messages (Green)
- `Write-Warn` - Warnings (Yellow)
- `Write-ErrorMsg` - Errors (Red)
- `Write-Header` - Section headers (Magenta)
- `Write-Step` - Sub-steps (White)

### `lib/pwsh/common.ps1`

Utility functions:

- `Test-Command` - Check if command exists
- `Invoke-WithRetry` - Retry failed operations
- `New-Backup` - Create backups
- `New-DirectorySafe` - Create directories safely
- `Get-ConfirmationPrompt` - Ask for confirmation
- `Test-InternetConnection` - Check connectivity

### `lib/pwsh/detect.ps1`

System detection:

- `Get-WindowsVersion` - Windows version info
- `Test-IsAdmin` - Check admin privileges
- `Get-SystemInfo` - Full system information
- `Test-IsWindows11` - Check if Windows 11
- `Get-PowerShellVersion` - PowerShell version

### `lib/pwsh/package-managers.ps1`

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
