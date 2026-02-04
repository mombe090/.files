# Neovim Configuration

LazyVim-based Neovim configuration with custom plugins and settings.

## What is LazyVim?

LazyVim is a Neovim configuration framework that provides a solid foundation with lazy-loaded plugins, LSP support, and modern development features.

## Features

- **Plugin Manager**: lazy.nvim with lazy loading
- **LSP**: Full language server protocol support
- **AI**: Copilot and AI integrations
- **Completion**: Blink.cmp for fast completion
- **UI**: Custom lualine, file explorer, transparency
- **Navigation**: Harpoon for quick file navigation

## Installation

### Linux/macOS

Uses XDG-style configuration in `~/.config/nvim`:

```bash
cd ~/.files
stow nvim
```

This will symlink files from `nvim/.config/nvim/` to `~/.config/nvim/`.

### Windows

Uses Windows-style configuration in `$env:LOCALAPPDATA\nvim`:

**Option 1: Install LazyVim directly** (Recommended)
```powershell
cd C:\Users\<username>\.files\_scripts\windows\pwsh
.\Install-LazyVim.ps1
```

This installs the LazyVim starter template directly to `$env:LOCALAPPDATA\nvim`.

**Option 2: Stow custom config** (For version control)
```powershell
# First, copy your customizations to .local/nvim
# Then stow using the new .local/ prefix support
cd C:\Users\<username>\.files
.\stow.ps1 -Stow nvim
```

The `.local/` prefix tells `stow.ps1` to use `$env:LOCALAPPDATA` instead of `~/.config`.

## Structure

### Linux/macOS Structure
```text
nvim/.config/nvim/
├── init.lua              # Entry point
├── lua/
│   ├── config/          # Core configuration
│   │   ├── autocmds.lua
│   │   ├── keymaps.lua
│   │   ├── lazy.lua     # Plugin manager setup
│   │   └── options.lua
│   └── plugins/         # Plugin configurations
│       ├── ai.lua
│       ├── coding.lua
│       ├── copilot.lua
│       └── ...
└── plugin/after/        # Post-load configurations
```

### Windows Structure
```text
nvim/.local/nvim/
└── (same structure as above)
```

**Target locations:**
- **Linux/macOS**: `~/.config/nvim/`
- **Windows**: `$env:LOCALAPPDATA\nvim` (e.g., `C:\Users\<username>\AppData\Local\nvim`)

## Usage

```bash
nvim                    # Launch Neovim
:Lazy                   # Plugin manager UI
:Mason                  # LSP/tool installer
:checkhealth            # Verify installation
```

## Key Plugins

- **Blink.cmp**: Fast completion engine
- **Copilot**: AI pair programming
- **Harpoon**: Quick file navigation
- **File Explorer**: Neo-tree or similar
- **Lualine**: Status line

## Customization

Add plugins in `lua/plugins/` following LazyVim conventions.

**Locations:**
- Linux/macOS: `~/.config/nvim/lua/plugins/`
- Windows: `$env:LOCALAPPDATA\nvim\lua\plugins\`

## Documentation

- LazyVim: <https://lazyvim.github.io/>
- Neovim: <https://neovim.io/doc/>

