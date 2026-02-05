# Stow.ps1 - LOCALAPPDATA Support

## Overview

`stow.ps1` now supports both XDG-style (`.config/`) and Windows-style (`.local/`) directory structures, allowing the same dotfiles repository to work seamlessly across Linux, macOS, and Windows.

## How It Works

The script detects directory prefixes in package structures and routes them to the appropriate target:

| Prefix | Target Directory | Platform | Example |
|--------|-----------------|----------|---------|
| `.config/` | `~/.config/` | Linux/macOS | `wezterm/.config/wezterm/` → `~/.config/wezterm/` |
| `.local/` | `$env:LOCALAPPDATA` | Windows | `nvim/.local/nvim/` → `C:\Users\<user>\AppData\Local\nvim\` |
| (none) | `$Target` | All | `git/.gitconfig` → `~/.gitconfig` |

## Package Structure Examples

### XDG-Style (Linux/macOS)

For applications following XDG Base Directory specification:

```
wezterm/
└── .config/
    └── wezterm/
        └── wezterm.lua
```

**Result**: `~/.config/wezterm/wezterm.lua`

### Windows LOCALAPPDATA-Style

For Windows applications that use `LOCALAPPDATA`:

```
nvim/
└── .local/
    └── nvim/
        ├── init.lua
        └── lua/
            ├── config/
            └── plugins/
```

**Result**: `C:\Users\<username>\AppData\Local\nvim\init.lua`

### Cross-Platform Package

You can have both in the same package:

```
nvim/
├── .config/          # For Linux/macOS
│   └── nvim/
│       └── init.lua
└── .local/           # For Windows
    └── nvim/
        └── init.lua
```

The script will automatically use the correct one based on the platform.

## Usage

### Stowing with LOCALAPPDATA

```powershell
# Stow nvim config to $env:LOCALAPPDATA\nvim
cd C:\Users\<username>\.files
.\stow.ps1 -Stow nvim

# Dry run to see what would happen
.\stow.ps1 -Stow nvim -DryRun -Verbose
```

### Unstowing

```powershell
# Remove nvim symlinks from $env:LOCALAPPDATA\nvim
.\stow.ps1 -Unstow nvim
```

### Restowing

```powershell
# Remove and recreate symlinks
.\stow.ps1 -Restow nvim
```

## Windows Applications Using LOCALAPPDATA

Common Windows applications that store config in `$env:LOCALAPPDATA`:

| Application | Path | Package Structure |
|-------------|------|-------------------|
| **Neovim** | `$env:LOCALAPPDATA\nvim` | `nvim/.local/nvim/` |
| **Windows Terminal** | `$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_*\LocalState\` | Custom handling needed |
| **VSCode** | `$env:APPDATA\Code\User\` | Use `$env:APPDATA` (different var) |

### Creating LOCALAPPDATA Packages

To create a new package for a Windows app:

1. Create the package directory structure:
   ```powershell
   mkdir myapp/.local/myapp
   ```

2. Add your config files:
   ```powershell
   # Place config files in .local/myapp/
   nvim myapp/.local/myapp/config.json
   ```

3. Stow the package:
   ```powershell
   .\stow.ps1 -Stow myapp
   ```

4. Verify symlinks:
   ```powershell
   Get-Item $env:LOCALAPPDATA\myapp\config.json | Select-Object LinkType, Target
   ```

## Technical Details

### Path Resolution Logic

The script checks path prefixes in the following order (precedence matters!):

```powershell
# In Invoke-StowPackage and Invoke-UnstowPackage functions:
# 1. Check .local/ FIRST (highest precedence)
if ($relativePath -match '^\.local\\') {
    # Strip .local\ prefix (7 characters)
    $relativePath = $relativePath.Substring(7)
    # Use LOCALAPPDATA instead of default target
    $actualTargetDir = $env:LOCALAPPDATA
}
# 2. Then check .config/ (lower precedence)
elseif ($TargetDir -match '\.config$' -and $relativePath -match '^\.config\\') {
    # Strip .config\ prefix (8 characters)
    $relativePath = $relativePath.Substring(8)
    # Use default target (already ~/.config)
    $actualTargetDir = $TargetDir
}
# 3. Default - use target as-is
else {
    $actualTargetDir = $TargetDir
}
```

**Important**: The `.local/` check must come BEFORE `.config/` to prevent incorrect path construction like `C:\Users\<user>\AppData\Local\.config\app\` (which would be wrong). By checking `.local/` first, we ensure Windows-style paths go directly to `LOCALAPPDATA` without any `.config` interference.

### Advantages

1. **Cross-platform compatibility**: Same repo, different targets per platform
2. **Platform conventions**: Respects XDG on Linux/macOS, LOCALAPPDATA on Windows
3. **No manual override needed**: Automatic detection based on directory structure
4. **Clean separation**: `.config/` vs `.local/` clearly indicates target platform

## Migration Guide

### Converting XDG-only to Cross-platform

If you have an existing package using `.config/` for Windows:

```powershell
# Before (incorrect for Windows):
myapp/.config/myapp/config.json  # Would go to ~/.config/myapp/ (wrong on Windows)

# After (correct for Windows):
myapp/.local/myapp/config.json   # Goes to $env:LOCALAPPDATA\myapp/ (correct!)
```

### Steps to migrate:

1. Create `.local/` structure:
   ```powershell
   mkdir myapp/.local
   cp -r myapp/.config/myapp myapp/.local/
   ```

2. Test stowing:
   ```powershell
   .\stow.ps1 -Stow myapp -DryRun -Verbose
   ```

3. Verify target paths in output

4. Stow for real:
   ```powershell
   .\stow.ps1 -Stow myapp
   ```

## Examples

### Neovim Package

```
nvim/
├── .config/nvim/     # Linux/macOS → ~/.config/nvim/
│   ├── init.lua
│   └── lua/
└── .local/nvim/      # Windows → $env:LOCALAPPDATA\nvim\
    ├── init.lua
    └── lua/
```

### WezTerm Package

```
wezterm/
└── .config/wezterm/  # All platforms → ~/.config/wezterm/
    └── wezterm.lua
```

Note: WezTerm uses `.config` on all platforms, so no `.local/` needed.

### Git Package

```
git/
├── .gitconfig        # All platforms → ~/.gitconfig
└── .gitignore_global # All platforms → ~/.gitignore_global
```

Note: Git uses home directory, so no prefix needed.

## Troubleshooting

### Symlinks not created

```powershell
# Check if Developer Mode is enabled or running as admin
Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock | Select-Object AllowDevelopmentWithoutDevLicense

# Run as admin if needed
Start-Process pwsh -Verb RunAs -ArgumentList "-NoProfile -File .\stow.ps1 -Stow nvim"
```

### Wrong target directory

```powershell
# Use -Verbose to see target resolution
.\stow.ps1 -Stow nvim -Verbose

# Check LOCALAPPDATA environment variable
$env:LOCALAPPDATA
```

### Conflicting files

```powershell
# Use -Force to override existing files
.\stow.ps1 -Stow nvim -Force

# Or manually remove conflicts first
Remove-Item $env:LOCALAPPDATA\nvim\init.lua
```

### Verify correct LOCALAPPDATA paths

If you suspect symlinks are being created in the wrong location (e.g., `LOCALAPPDATA\.config\nvim` instead of `LOCALAPPDATA\nvim`):

```powershell
# 1. Dry run with verbose to see where symlinks will be created
.\stow.ps1 -Stow nvim -DryRun -Verbose

# Look for lines like:
# "Using LOCALAPPDATA for: nvim\init.lua -> C:\Users\<user>\AppData\Local\nvim\init.lua"
# NOT: "... -> C:\Users\<user>\AppData\Local\.config\nvim\init.lua"

# 2. Check actual symlink targets
Get-ChildItem $env:LOCALAPPDATA\nvim -Recurse | Where-Object { $_.LinkType -eq 'SymbolicLink' } | Select-Object FullName, Target

# 3. If paths are wrong, unstow and restow
.\stow.ps1 -Unstow nvim
.\stow.ps1 -Stow nvim -Verbose
```

**Expected behavior**: Files in `.local/nvim/` should map to `$env:LOCALAPPDATA\nvim\`, NOT `$env:LOCALAPPDATA\.config\nvim\`.

## See Also

- [stow.ps1 main documentation](../README.md)
- [Neovim package README](../nvim/README.md)
- [Windows dotfiles QUICK-START](QUICK-START.md)
