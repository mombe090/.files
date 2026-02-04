# Windows Neovim Configuration

This directory is for Windows-specific Neovim configuration that will be stowed to `$env:LOCALAPPDATA\nvim`.

## Directory Purpose

The `.local/` prefix tells `stow.ps1` to use `$env:LOCALAPPDATA` instead of `~/.config`, which matches Windows conventions for application data.

## Installation

### Option 1: Install LazyVim Starter (Recommended)

Use the LazyVim installer which sets up everything automatically:

```powershell
cd C:\Users\<username>\.files\_scripts\windows\pwsh
.\Install-LazyVim.ps1
```

This creates the configuration at: `$env:LOCALAPPDATA\nvim` (typically `C:\Users\<username>\AppData\Local\nvim`)

### Option 2: Use Custom Configuration

If you want to manage your Neovim config with stow:

1. Place your Neovim config files here following the same structure as `.config/nvim`:
   ```
   nvim/.local/nvim/
   ├── init.lua
   ├── lua/
   │   ├── config/
   │   └── plugins/
   └── ...
   ```

2. Stow the package:
   ```powershell
   cd C:\Users\<username>\.files
   .\stow.ps1 -Stow nvim
   ```

3. This will create symlinks from here to `$env:LOCALAPPDATA\nvim\`

## Why Two Directories?

- **`.config/nvim/`** - For Linux/macOS (XDG Base Directory spec)
- **`.local/nvim/`** - For Windows (LOCALAPPDATA convention)

This allows the same repository to work across all platforms with platform-appropriate paths.

## Notes

- LazyVim expects config at `$env:LOCALAPPDATA\nvim` on Windows
- The stow script detects `.local/` prefix and automatically uses `$env:LOCALAPPDATA`
- You can have both `.config/nvim` and `.local/nvim` - stow will use the right one per platform
