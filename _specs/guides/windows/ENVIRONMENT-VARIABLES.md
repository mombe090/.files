# Environment Variables for Windows

## Overview

XDG Base Directory environment variables are automatically set in your PowerShell profile for cross-platform configuration compatibility.

## What are XDG Environment Variables?

The [XDG Base Directory specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) defines standard locations for user-specific configuration, data, and cache files. While primarily used on Linux, setting these on Windows enables cross-platform configuration compatibility.

| Variable | Windows Value | Purpose |
|----------|---------------|---------|
| `XDG_CONFIG_HOME` | `$env:USERPROFILE\.config` | User-specific configuration files |
| `XDG_DATA_HOME` | `$env:USERPROFILE\.local\share` | User-specific data files |
| `XDG_CACHE_HOME` | `$env:USERPROFILE\.cache` | User-specific cache files |
| `XDG_STATE_HOME` | `$env:USERPROFILE\.local\state` | User-specific state files |

## How It Works

### Automatic Setup ✅

The PowerShell profile automatically sets these variables when you open a PowerShell session.

**Location**: `Documents\PowerShell\Microsoft.PowerShell_profile.ps1`

**Variables set**:
```powershell
$env:XDG_CONFIG_HOME = "$env:USERPROFILE\.config"
$env:XDG_DATA_HOME = "$env:USERPROFILE\.local\share"
$env:XDG_CACHE_HOME = "$env:USERPROFILE\.cache"
$env:XDG_STATE_HOME = "$env:USERPROFILE\.local\state"
```

**No manual setup required!** Just stow the PowerShell profile and open a new PowerShell session.

## Verification

### Check Variables Are Set

```powershell
# Check individual variables
$env:XDG_CONFIG_HOME
# Should output: C:\Users\<username>\.config

$env:XDG_DATA_HOME
# Should output: C:\Users\<username>\.local\share

# Check all XDG variables at once
Get-ChildItem env:XDG_*
```

### Expected Output

```
Name                           Value
----                           -----
XDG_CACHE_HOME                 C:\Users\<username>\.cache
XDG_CONFIG_HOME                C:\Users\<username>\.config
XDG_DATA_HOME                  C:\Users\<username>\.local\share
XDG_STATE_HOME                 C:\Users\<username>\.local\state
```

## Directory Structure

After stowing dotfiles, your home directory will follow this structure:

```
C:\Users\<username>\
├── .config\              # XDG_CONFIG_HOME - configuration files
│   ├── git\
│   ├── nvim\
│   ├── starship.toml
│   └── wezterm\
├── .local\               # Local user files
│   ├── share\            # XDG_DATA_HOME - application data
│   └── state\            # XDG_STATE_HOME - state files
└── .cache\               # XDG_CACHE_HOME - cache files
```

## How Applications Use These Variables

### Git Configuration

With `XDG_CONFIG_HOME` set, Git checks:
1. `$env:XDG_CONFIG_HOME\git\config`
2. `$env:USERPROFILE\.gitconfig`

You can use XDG-style config location on Windows!

### Neovim

Neovim on Windows checks:
1. `$env:LOCALAPPDATA\nvim` (Windows default)
2. `$env:XDG_CONFIG_HOME\nvim` (if XDG_CONFIG_HOME is set)

### Custom Scripts

Use these in your own scripts for cross-platform compatibility:

```powershell
# Cross-platform config path
$configPath = if ($env:XDG_CONFIG_HOME) {
    Join-Path $env:XDG_CONFIG_HOME "myapp"
} else {
    Join-Path $env:USERPROFILE ".config" "myapp"
}
```

## Integration with stow.ps1

The environment variables complement stow.ps1's path routing:

| Package Prefix | Target Directory | Notes |
|----------------|-----------------|-------|
| `.config/` | `~\.config` | Matches `$env:XDG_CONFIG_HOME` |
| `.local/` | `$env:LOCALAPPDATA` | Windows-specific apps |
| (none) | `$Target` parameter | Direct to home or custom target |

**Example**: Applications can check `$env:XDG_CONFIG_HOME` instead of hardcoding `~\.config`.

## Creating Required Directories

If needed, create the XDG directories:

```powershell
New-Item -ItemType Directory -Force -Path $env:XDG_CONFIG_HOME
New-Item -ItemType Directory -Force -Path $env:XDG_DATA_HOME
New-Item -ItemType Directory -Force -Path $env:XDG_CACHE_HOME
New-Item -ItemType Directory -Force -Path $env:XDG_STATE_HOME
```

## Troubleshooting

### Variables not set

**Cause**: PowerShell profile not loaded or not stowed

**Solution**:
```powershell
# Stow PowerShell profile
cd C:\Users\<username>\.files
.\stow.ps1 -Stow powershell -Target $env:USERPROFILE

# Restart PowerShell
```

### Check if profile exists

```powershell
# Check profile path
$PROFILE
# Output: C:\Users\<username>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

# Check if it exists
Test-Path $PROFILE
# Should be: True

# View profile content
code $PROFILE
# Look for $env:XDG_* lines in the Environment Variables section
```

### Variables only work in PowerShell

**Expected behavior**: These variables are set in PowerShell profile, so they're only available in PowerShell sessions.

**For other shells** (CMD, Git Bash, etc.): You would need to set them in Windows User environment variables manually via System Properties → Environment Variables.

## Scope and Limitations

### ✅ Available In:
- PowerShell 7+ sessions
- Scripts run from PowerShell
- Applications launched from PowerShell

### ❌ Not Available In:
- CMD (unless set in Windows environment)
- Git Bash (unless set in Windows environment)
- Applications launched from Start Menu or File Explorer

**This is by design** - the profile approach keeps environment clean and only sets variables when needed in PowerShell.

## Best Practices

1. **Use PowerShell for development** - All XDG variables are automatically available
2. **Stow the profile** - Ensure `powershell` package is stowed to `$env:USERPROFILE`
3. **Restart PowerShell after profile changes** - New sessions pick up changes automatically
4. **Check variables in scripts** - Always verify `$env:XDG_*` exists before using
5. **Document assumptions** - If your scripts require XDG variables, document it

## See Also

- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
- [LOCALAPPDATA-STOW.md](LOCALAPPDATA-STOW.md) - Windows-specific stowing
- [QUICK-START.md](QUICK-START.md) - Windows dotfiles setup guide
- [PowerShell Profile](../../powershell/Documents/PowerShell/Microsoft.PowerShell_profile.ps1) - Source of truth
