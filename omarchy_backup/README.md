# Omarchy Configuration

Theme management and customization for Omarchy Linux distribution.

## What is Omarchy?

Omarchy is a Linux distribution focused on aesthetic consistency. This configuration manages themes across all applications.

## Features

- **Multi-Theme Support**: 11 pre-configured themes
  - Catppuccin (Mocha, Latte, Frappe)
  - Everforest
  - Gruvbox
  - Kanagawa
  - Matte Black
  - Nord
  - Osaka Jade
  - Ristretto
  - Rose Pine
  - Tokyo Night

- **System-Wide Theming**: Consistent themes for:
  - Alacritty, Ghostty, Kitty (terminals)
  - Hyprland, Hyprlock (window manager)
  - Waybar (status bar)
  - Btop (system monitor)
  - Neovim (editor)
  - VSCode (IDE)

## Installation

```bash
stow omarchy
```

## Structure

```text
~/.config/omarchy/
├── branding/          # Omarchy branding assets
├── current/theme/     # Active theme (symlinked)
└── themes/            # Available themes
```

## Usage

Switch themes using Omarchy's theme switcher (usually GUI-based). Each theme includes:

- Background wallpapers
- Color schemes for all applications
- Icon themes
- Font configurations

## Files Per Theme

- `alacritty.toml`, `ghostty.conf`, `kitty.conf` - Terminal themes
- `hyprland.conf`, `hyprlock.conf` - WM themes
- `btop.theme` - System monitor theme
- `neovim.lua` - Editor theme
- `vscode.json` - IDE theme
- `waybar.css`, `walker.css` - UI themes
- `backgrounds/` - Wallpapers

## Customization

1. Select a theme as base from `themes/`
2. Copy to new directory
3. Modify color schemes in individual files
4. Use Omarchy theme switcher to activate
