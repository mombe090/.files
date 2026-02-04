# PowerShell Stow - Dotfiles Symlink Manager

A PowerShell implementation of GNU Stow for managing dotfiles on Windows.

## What is Stow?

Stow is a symlink farm manager that makes it easy to organize your dotfiles in a central location and create symlinks to their proper locations. Instead of copying files, you create symbolic links, which means:

- ✅ Single source of truth for your configs
- ✅ Easy to version control
- ✅ No duplicate files
- ✅ Changes sync automatically

## Quick Start

### 1. Create a Package

Organize your config files in a package directory:

```
.files/
├── wezterm/
│   └── .config/
│       └── wezterm/
│           └── wezterm.lua
├── nvim/
│   └── .config/
│       └── nvim/
│           └── init.lua
├── stow.ps1
└── _scripts/
    └── ...
```

### 2. Stow the Package

```powershell
cd .files
.\stow.ps1 wezterm
```

This creates:
```
~/.config/wezterm/wezterm.lua -> .files/wezterm/.config/wezterm/wezterm.lua
```

### 3. Unstow if Needed

```powershell
.\stow.ps1 -Unstow wezterm
```

## Usage

### Basic Commands

```powershell
# Stow a package (create symlinks)
.\stow.ps1 -Stow <package-name>

# Unstow a package (remove symlinks)
.\stow.ps1 -Unstow <package-name>

# Restow a package (unstow then stow)
.\stow.ps1 -Restow <package-name>

# List all available packages
.\stow.ps1 -ListPackages
```

### Options

```powershell
# Dry run (show what would be done without doing it)
.\stow.ps1 -Stow wezterm -DryRun

# Verbose output
.\stow.ps1 -Stow wezterm -Verbose

# Force override existing symlinks
.\stow.ps1 -Stow wezterm -Force

# Custom target directory (default: ~/.config)
.\stow.ps1 -Stow wezterm -Target $env:USERPROFILE

# Custom package directory
.\stow.ps1 -Stow wezterm -PackageDir C:\dotfiles
```

## Package Structure

### Standard .config Structure

For apps that expect configs in `~/.config/`:

```
wezterm/
└── .config/
    └── wezterm/
        ├── wezterm.lua
        └── colors/
            └── custom.toml
```

Result:
```
~/.config/wezterm/wezterm.lua
~/.config/wezterm/colors/custom.toml
```

### Home Directory Structure

For configs that go directly in `~`:

```
git/
├── .gitconfig
└── .gitignore_global
```

To stow to home directory:
```powershell
.\stow.ps1 -Stow git -Target $env:USERPROFILE
```

Result:
```
~/.gitconfig
~/.gitignore_global
```

## Examples

### WezTerm Configuration

```powershell
# Create package
mkdir -p .files\wezterm\.config\wezterm
# Add your wezterm.lua
code .files\wezterm\.config\wezterm\wezterm.lua

# Stow it
cd .files
.\stow.ps1 -Stow wezterm
```

### Neovim Configuration

```powershell
# Package structure
mkdir -p .files\nvim\.config\nvim
# Add your init.lua
code .files\nvim\.config\nvim\init.lua

# Stow it
.\stow.ps1 -Stow nvim
```

### PowerShell Profile

```powershell
# Package structure for Documents/PowerShell
mkdir -p .files\powershell\Documents\PowerShell
code .files\powershell\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

# Stow to home directory
.\stow.ps1 -Stow powershell -Target $env:USERPROFILE
```

## Features

### Conflict Detection

Stow will warn you if a file already exists at the target location:

```powershell
PS> .\stow.ps1 -Stow wezterm
❌ Path exists but is not a symlink: C:\Users\user\.config\wezterm\wezterm.lua
⚠ Use -Force to backup and override, or manually remove the file
```

### Force Override

```powershell
# Override existing files/symlinks
.\stow.ps1 -Stow wezterm -Force
```

### Dry Run

See what would happen without making changes:

```powershell
PS> .\stow.ps1 -Stow wezterm -DryRun
ℹ [DRY RUN] Would create file symlink: C:\Users\user\.config\wezterm\wezterm.lua -> ...
```

### List Packages

```powershell
PS> .\stow.ps1 -ListPackages
Available Packages
ℹ   wezterm
ℹ   nvim
ℹ   git
✓ Found 3 package(s)
```

## Tips

### 1. Organize by Application

Keep each application's config in its own package:

```
.files/
├── wezterm/
├── nvim/
├── git/
├── powershell/
└── vscode/
```

### 2. Version Control

Add your packages to git:

```powershell
cd .files
git add wezterm nvim git
git commit -m "Add dotfiles for wezterm, nvim, and git"
```

### 3. Fresh Install Workflow

On a new machine:

```powershell
# Clone dotfiles
git clone https://github.com/yourusername/.files.git
cd .files

# Stow everything
.\stow.ps1 -Stow wezterm
.\stow.ps1 -Stow nvim
.\stow.ps1 -Stow git -Target $env:USERPROFILE
```

### 4. Update Configurations

Since files are symlinked, just edit the source:

```powershell
# Edit in dotfiles directory
code .files\wezterm\.config\wezterm\wezterm.lua

# Changes are immediately reflected in ~/.config/wezterm/wezterm.lua
```

## Troubleshooting

### Permission Errors

Creating symlinks on Windows requires either Developer Mode OR Administrator privileges.

**Option 1: Enable Developer Mode (Recommended)**
1. Settings → Privacy & Security → For developers
2. Turn on "Developer Mode"
3. No UAC prompts needed for stow operations

**Option 2: Run with Administrator Privileges**
- Run PowerShell as Administrator before using stow.ps1
- You'll see UAC prompts for each symlink creation
- Less convenient but works if Developer Mode cannot be enabled

### Symlink Already Exists

```powershell
# Check what the symlink points to
Get-Item ~\.config\wezterm\wezterm.lua | Select-Object LinkType, Target

# Force recreate
.\stow.ps1 -Restow wezterm -Force
```

### Path Not Found

Make sure your package structure mirrors the target structure:

```
❌ wezterm/wezterm.lua           (wrong - missing .config)
✓  wezterm/.config/wezterm/wezterm.lua  (correct)
```

## Advanced Usage

### Multiple Targets

Stow different packages to different locations:

```powershell
# Config files to ~/.config
.\stow.ps1 -Stow wezterm -Target "$env:USERPROFILE\.config"

# Dotfiles to home directory
.\stow.ps1 -Stow git -Target $env:USERPROFILE

# Scripts to custom location
.\stow.ps1 -Stow scripts -Target "C:\tools"
```

### Batch Stowing

Stow multiple packages at once:

```powershell
$packages = @('wezterm', 'nvim', 'git')
foreach ($pkg in $packages) {
    .\stow.ps1 -Stow $pkg
}
```

## Comparison with GNU Stow

| Feature | GNU Stow | PowerShell Stow |
|---------|----------|-----------------|
| Platform | Linux/Mac | Windows |
| Language | Perl | PowerShell |
| Symlinks | ✓ | ✓ |
| Conflict detection | ✓ | ✓ |
| Tree folding | ✓ | Planned |
| Directory stowing | ✓ | File-level only |

## See Also

- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/)
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
