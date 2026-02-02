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

### Using stow.ps1 (Recommended)

```powershell
# 1. Stow PowerShell configuration to ~/.config/powershell/
cd C:\Users\<username>\.files
.\stow.ps1 powershell

# 2. Create wrapper profile at $PROFILE location
cd _scripts\windows\pwsh
.\Setup-PowerShellProfile.ps1
```

This creates a small wrapper file at `$PROFILE` that sources `~/.config/powershell/profile.ps1`.

**No admin privileges required!** (Uses wrapper file instead of symlink)

### Manual Setup

```powershell
# Create .config/powershell directory
$configDir = "$env:USERPROFILE\.config\powershell"
New-Item -ItemType Directory -Path $configDir -Force

# Copy files
Copy-Item ".config\powershell\profile.ps1" $configDir
Copy-Item ".config\powershell\git-aliases.ps1" $configDir

# Create wrapper profile at $PROFILE location
$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force
}

@'
# PowerShell Profile Wrapper
$xdgProfile = Join-Path $env:USERPROFILE ".config\powershell\profile.ps1"
if (Test-Path $xdgProfile) { . $xdgProfile }
'@ | Out-File -FilePath $PROFILE -Encoding UTF8
```

## How It Works

1. **Stow creates:** `~/.config/powershell/profile.ps1` (actual profile)
2. **Setup script creates:** `Documents\PowerShell\Microsoft.PowerShell_profile.ps1` (wrapper)
3. **Wrapper sources:** `~/.config/powershell/profile.ps1`

This approach:
- ✅ No admin privileges required (no symlinks)
- ✅ Cross-platform path structure (`~/.config/powershell/`)
- ✅ Works with Windows PowerShell conventions (`$PROFILE` location)
- ✅ Easy to update (edit `~/.config/powershell/profile.ps1`)

## Profile Locations

PowerShell looks for profiles at:

- **Windows:** `$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`
- **Our approach:** Wrapper at `$PROFILE` → sources `~/.config/powershell/profile.ps1`

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
# Check wrapper profile
Get-Content $PROFILE

# Should show wrapper that sources ~/.config/powershell/profile.ps1

# Test profile loading
. $PROFILE

# Test git aliases
gst  # Should run 'git status'
```

## Updating

After updating `~/.config/powershell/profile.ps1` or `git-aliases.ps1`:

```powershell
# Reload profile
. $PROFILE
```

Changes are immediately reflected since the wrapper sources the config file.

## Uninstall

```powershell
# Remove wrapper profile
Remove-Item $PROFILE -Force

# Remove stowed config (optional)
.\stow.ps1 -Unstow powershell
```

## Cross-Platform Compatibility

This structure mirrors Linux/macOS dotfiles:
- **Linux/macOS:** `~/.config/powershell/profile.ps1`
- **Windows:** `~/.config/powershell/profile.ps1` (sourced by wrapper at `$PROFILE`)

The profile automatically detects the OS and adjusts paths accordingly via XDG environment variables.

## Troubleshooting

### Profile not loading?
```powershell
# Check if wrapper exists
Test-Path $PROFILE

# Check if XDG profile exists
Test-Path "$env:USERPROFILE\.config\powershell\profile.ps1"

# Manually load
. $PROFILE
```

### Git aliases not working?
```powershell
# Check if git-aliases.ps1 exists
Test-Path "$env:USERPROFILE\.config\powershell\git-aliases.ps1"

# Reload profile
. $PROFILE
```

### Wrapper shows warning?
If you see "XDG PowerShell profile not found", run:
```powershell
.\stow.ps1 powershell
```
