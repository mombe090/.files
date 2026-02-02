# PowerShell Configuration

Cross-platform PowerShell configuration using XDG-style paths.

## Structure

```
powershell/
└── .config/
    └── powershell/
        ├── profile.ps1        # Main PowerShell profile
        └── git-aliases.ps1    # Git aliases (Oh My Zsh style)
```

## Installation

### Option 1: Using stow.ps1 (Recommended)

```powershell
# Stow PowerShell configuration to ~/.config/powershell/
.\stow.ps1 powershell

# Then create symlink from $PROFILE to ~/.config/powershell/profile.ps1
$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force
}

# Remove existing profile if it exists
if (Test-Path $PROFILE) {
    Remove-Item $PROFILE -Force
}

# Create symlink
New-Item -ItemType SymbolicLink -Path $PROFILE -Target "$env:USERPROFILE\.config\powershell\profile.ps1"
```

### Option 2: Manual Setup

```powershell
# Create .config/powershell directory
$configDir = "$env:USERPROFILE\.config\powershell"
New-Item -ItemType Directory -Path $configDir -Force

# Copy files
Copy-Item "profile.ps1" $configDir
Copy-Item "git-aliases.ps1" $configDir

# Create symlink from $PROFILE to config
$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force
}

New-Item -ItemType SymbolicLink -Path $PROFILE -Target "$configDir\profile.ps1" -Force
```

## Profile Locations

PowerShell looks for profiles in these locations:

- **Windows:** `$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`
- **Our approach:** `$env:USERPROFILE\.config\powershell\profile.ps1` (symlinked to $PROFILE)

By using a symlink, we maintain cross-platform compatibility while respecting Windows' expected profile location.

## What's Included

### profile.ps1
- **Starship prompt** integration
- **XDG environment variables** (cross-platform paths)
- **PSReadLine** configuration (vi mode, history search)
- **Aliases** (ll, l, c, v)
- **Git aliases** (260+ Oh My Zsh-style aliases via git-aliases.ps1)
- **Kubernetes aliases** (k, kg, kd, kl, etc.)
- **Utilities** (cx, Add-ToPath)
- **Machine-specific profile loading** ($env:USERPROFILE\profile.ps1)

### git-aliases.ps1
- 260+ Oh My Zsh-style git aliases
- Helper functions (Get-GitMainBranch, Get-GitDevelopBranch)
- Safe defaults (gpf uses --force-with-lease)
- Full coverage: add, branch, checkout, commit, diff, fetch, log, merge, push, pull, rebase, remote, reset, restore, stash, status, switch, tag, worktree, cherry-pick, reflog, bisect, submodule

## Verification

```powershell
# Check if profile is symlinked correctly
Get-Item $PROFILE

# Should show:
# LinkType: SymbolicLink
# Target: C:\Users\<username>\.config\powershell\profile.ps1

# Test profile loading
. $PROFILE

# Test git aliases
gst  # Should run 'git status'
```

## Updating

After updating profile.ps1 or git-aliases.ps1:

```powershell
# Reload profile
. $PROFILE
```

The symlink ensures changes to `~/.config/powershell/profile.ps1` are immediately reflected in your PowerShell session.

## Uninstall

```powershell
# Remove symlink
Remove-Item $PROFILE -Force

# Remove stowed config (optional)
.\stow.ps1 -Unstow powershell
```

## Cross-Platform Compatibility

This structure mirrors Linux/macOS dotfiles:
- **Linux/macOS:** `~/.config/powershell/profile.ps1`
- **Windows:** `~/.config/powershell/profile.ps1` → symlinked to `$PROFILE`

The profile automatically detects the OS and adjusts paths accordingly via XDG environment variables.
