# Hyprland Configuration

Tiling window manager configuration for Wayland with Omarchy integration.

## What is Hyprland?

Hyprland is a dynamic tiling Wayland compositor with smooth animations, extensive customization, and modern features.

## Features

- **Omarchy Integration**: Sources default Omarchy configurations
- **Modular Config**: Separate files for monitors, input, bindings, etc.
- **Theme Support**: Dynamic theme loading from Omarchy
- **Custom Scripts**: Brightness control and utilities

## Installation

```bash
stow hypr
```

## Configuration Files

- `hyprland.conf` - Main configuration (sources all others)
- `monitors.conf` - Display configuration
- `input.conf` - Keyboard/mouse settings
- `bindings.conf` - Custom keybindings
- `looknfeel.conf` - Aesthetics and animations
- `autostart.conf` - Programs to launch on startup
- `workspaces.conf` - Workspace rules
- `utilities.conf` - Utility settings

## Scripts

- `scripts/brightness.sh` - Brightness control utility

## Usage

Hyprland automatically loads this configuration on startup. Edit individual `.conf` files to customize specific aspects.

## Customization

1. Monitor setup: Edit `monitors.conf`
2. Keybindings: Edit `bindings.conf`
3. Startup apps: Edit `autostart.conf`
4. Themes: Use Omarchy theme switcher

## Documentation

Learn more: <https://wiki.hyprland.org/Configuring/>
