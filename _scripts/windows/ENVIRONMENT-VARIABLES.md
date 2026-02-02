# Environment Variables Setup for Windows

## Overview

This guide explains how to set up XDG Base Directory specification environment variables on Windows for cross-platform configuration compatibility.

## What are XDG Environment Variables?

The [XDG Base Directory specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) defines standard locations for user-specific configuration, data, and cache files. While primarily used on Linux, setting these on Windows enables cross-platform configuration compatibility.

| Variable | Default (Linux) | Windows Equivalent | Purpose |
|----------|----------------|-------------------|---------|
| `XDG_CONFIG_HOME` | `~/.config` | `$env:USERPROFILE\.config` | User-specific configuration files |
| `XDG_DATA_HOME` | `~/.local/share` | `$env:USERPROFILE\.local\share` | User-specific data files |
| `XDG_CACHE_HOME` | `~/.cache` | `$env:USERPROFILE\.cache` | User-specific cache files |
| `XDG_STATE_HOME` | `~/.local/state` | `$env:USERPROFILE\.local\state` | User-specific state files |

## Setup Methods

### Method 1: Automatic (PowerShell Profile) ✅ Recommended

The PowerShell profile is already configured to set XDG variables automatically when you open a new PowerShell session.

**No action needed!** The variables are set in your profile at:
```
Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

**Verify it's working:**
```powershell
# Open new PowerShell window and check
$env:XDG_CONFIG_HOME
# Should output: C:\Users\<username>\.config
```

### Method 2: Script (Current Session Only)

Set variables for the current PowerShell session only:

```powershell
cd C:\Users\<username>\.files\_scripts\windows\pwsh
.\Set-EnvironmentVariables.ps1
```

**When to use:** Quick testing without persistence

### Method 3: Script (Persistent)

Save variables to Windows User environment (persists across all sessions):

```powershell
cd C:\Users\<username>\.files\_scripts\windows\pwsh
.\Set-EnvironmentVariables.ps1 -Persist
```

**When to use:** You want these variables available in ALL applications (not just PowerShell)

**Benefits:**
- Variables available in CMD, Git Bash, VS Code terminals, etc.
- No need to set in PowerShell profile
- Survives PowerShell profile reloads

**Drawbacks:**
- Requires registry modification
- Need to restart applications to pick up changes

### Method 4: Script (System-Wide)

Save variables for all users (requires Administrator):

```powershell
# Run PowerShell as Administrator
cd C:\Users\<username>\.files\_scripts\windows\pwsh
.\Set-EnvironmentVariables.ps1 -Persist -Scope Machine
```

**When to use:** Multi-user system where all users need these variables

## Quick Test

Verify everything is working with the automated test script:

```powershell
cd C:\Users\<username>\.files\_scripts\windows\pwsh
.\Test-EnvironmentVariables.ps1
```

This will check:
- ✓ All XDG variables are set correctly
- ✓ Directories exist (or show how to create them)
- ✓ PowerShell profile configures the variables
- ✓ Optional: Check if variables are persisted

## Verification

### Check Current Session Variables

```powershell
# Check all XDG variables
$env:XDG_CONFIG_HOME
$env:XDG_DATA_HOME
$env:XDG_CACHE_HOME
$env:XDG_STATE_HOME

# Or check all at once
Get-ChildItem env:XDG_*
```

### Check Persisted Variables (User)

```powershell
[System.Environment]::GetEnvironmentVariable('XDG_CONFIG_HOME', 'User')
[System.Environment]::GetEnvironmentVariable('XDG_DATA_HOME', 'User')
[System.Environment]::GetEnvironmentVariable('XDG_CACHE_HOME', 'User')
[System.Environment]::GetEnvironmentVariable('XDG_STATE_HOME', 'User')
```

### Check Persisted Variables (Machine)

```powershell
[System.Environment]::GetEnvironmentVariable('XDG_CONFIG_HOME', 'Machine')
# etc.
```

## How Applications Use These Variables

### Example: Git Configuration

With `XDG_CONFIG_HOME` set:
```powershell
# Git looks for config at:
# 1. $env:XDG_CONFIG_HOME\git\config
# 2. $env:USERPROFILE\.gitconfig

# So you can use XDG-style config location on Windows too!
```

### Example: Neovim

Neovim on Windows checks:
1. `$env:LOCALAPPDATA\nvim` (Windows default)
2. `$env:XDG_CONFIG_HOME\nvim` (if XDG_CONFIG_HOME is set)

### Example: Custom Scripts

You can use these in your own scripts:

```powershell
# Cross-platform config path
$configPath = if ($env:XDG_CONFIG_HOME) {
    Join-Path $env:XDG_CONFIG_HOME "myapp"
} else {
    Join-Path $env:USERPROFILE ".config" "myapp"
}
```

## Directory Structure

After setup, your home directory structure will match Linux conventions:

```
C:\Users\<username>\
├── .config\              # XDG_CONFIG_HOME - configuration files
│   ├── git\
│   ├── nvim\
│   ├── starship.toml
│   └── wezterm\
├── .local\               # Local user files
│   ├── share\            # XDG_DATA_HOME - application data
│   ├── state\            # XDG_STATE_HOME - state files
│   └── bin\              # User binaries
└── .cache\               # XDG_CACHE_HOME - cache files
```

## Integration with stow.ps1

The stow.ps1 script supports both Windows and XDG conventions:

| Package Prefix | Target Directory | Example |
|----------------|-----------------|---------|
| `.config/` | `$env:XDG_CONFIG_HOME` (`~\.config`) | `wezterm/.config/wezterm/` → `~\.config\wezterm\` |
| `.local/` | `$env:LOCALAPPDATA` | `nvim/.local/nvim/` → `$env:LOCALAPPDATA\nvim\` |
| (none) | `$Target` parameter | `git/.gitconfig` → `~\.gitconfig` |

**With XDG variables set**, applications can use unified configuration paths across platforms!

## Troubleshooting

### Variables not set after restart

**Cause:** Variables only set for current session (Method 2)

**Solution:** Use Method 1 (PowerShell profile) or Method 3 (persist with script)

### Variables not available in other applications

**Cause:** Variables only set in PowerShell profile (Method 1)

**Solution:** Use Method 3 (`-Persist` flag) to save to Windows environment

### Need to refresh environment variables

```powershell
# Reload environment variables without restarting
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Or use refreshenv if Chocolatey is installed
refreshenv
```

### Remove persisted variables

```powershell
# Remove from User environment
[System.Environment]::SetEnvironmentVariable('XDG_CONFIG_HOME', $null, 'User')
[System.Environment]::SetEnvironmentVariable('XDG_DATA_HOME', $null, 'User')
[System.Environment]::SetEnvironmentVariable('XDG_CACHE_HOME', $null, 'User')
[System.Environment]::SetEnvironmentVariable('XDG_STATE_HOME', $null, 'User')

# Remove from Machine environment (requires admin)
[System.Environment]::SetEnvironmentVariable('XDG_CONFIG_HOME', $null, 'Machine')
# etc.
```

## Best Practices

1. **Use PowerShell Profile (Method 1)** for personal setup - simplest and most flexible
2. **Use Persist (Method 3)** if you need variables in non-PowerShell environments
3. **Create required directories** if needed:
   ```powershell
   New-Item -ItemType Directory -Force -Path $env:XDG_CONFIG_HOME
   New-Item -ItemType Directory -Force -Path $env:XDG_DATA_HOME
   New-Item -ItemType Directory -Force -Path $env:XDG_CACHE_HOME
   New-Item -ItemType Directory -Force -Path $env:XDG_STATE_HOME
   ```
4. **Test in current session first** before persisting
5. **Document custom variables** if you add more beyond the standard XDG ones

## See Also

- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
- [LOCALAPPDATA-STOW.md](LOCALAPPDATA-STOW.md) - Windows-specific stowing
- [QUICK-START.md](QUICK-START.md) - Windows dotfiles setup guide
