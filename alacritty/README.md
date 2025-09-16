# Alacritty Terminal Configuration

I use alacritty as my primary terminal emulator due to its speed, simplicity, and GPU acceleration.

## Overview

Alacritty is a cross-platform, GPU-accelerated terminal emulator written in Rust. This configuration provides a highly customized setup with extensive theming support, optimized for development workflows.

## Configuration Structure

```text
alacritty/
├── .config/
│   └── alacritty/
│       ├── alacritty.toml       # Main configuration file
│       └── themes/              # Theme collection (144+ themes)
│           ├── catppuccin_*.toml
│           ├── gruvbox_*.toml
│           ├── dracula.toml
│           └── ... (140+ more themes)
```

## Installation & Setup

### Prerequisites

1. **Alacritty**: Install via package manager

   ```bash
   # Arch Linux
   sudo pacman -S alacritty

   # Ubuntu/Debian
   sudo apt install alacritty

   # macOS
   brew install alacritty
   ```

2. **Nerd Font**: Install CaskaydiaMono Nerd Font

   ```bash
   # Download from https://www.nerdfonts.com/
   # Or via package manager:
   brew install font-caskaydia-cove-nerd-font  # macOS
   ```

### Symlinking Configuration

```bash
# Create symlink (from dotfiles root)
stow alacritty

# Or manually:
ln -sf ~/.files/alacritty/.config/alacritty ~/.config/
```

## Customization Guide

### Changing Themes

1. **Edit main config**:

   ```toml
   [general]
   import = ["~/.config/alacritty/themes/THEME_NAME.toml"]
   ```

2. **Popular choices**:

   ```toml
   # Dark themes
   import = ["~/.config/alacritty/themes/catppuccin_mocha.toml"]
   import = ["~/.config/alacritty/themes/tokyo_night.toml"]

   # Light themes
   import = ["~/.config/alacritty/themes/catppuccin_latte.toml"]
   ```

### Font Customization

```toml
[font]
size = 16                    # Adjust size (10-20 typical range)

[font.normal]
family = "JetBrains Mono"    # Alternative font family
style = "Regular"

[font.bold]
family = "JetBrains Mono"
style = "Bold"
```

### Window Transparency

```toml
[window]
opacity = 1.0              # Fully opaque
opacity = 0.9              # 90% opacity
opacity = 0.8              # 80% opacity (more transparent)
blur = false               # Disable blur for performance
```

### Performance Tuning

```toml
[window]
decorations = "Full"       # Use full decorations for compatibility
dynamic_title = false      # Disable for slight performance gain

[scrolling]
history = 5000            # Reduce scrollback for memory efficiency
multiplier = 3            # Adjust scroll speed
```

## Main Configuration (`alacritty.toml`)

### Font Settings

- **Font Family**: CaskaydiaMono Nerd Font Mono
- **Styles**: Regular, Bold, Italic supported
- **Font Offset**: Disabled (x=0, y=0) for precise rendering

### Window Configuration

```toml
[window]
decorations = "Transparent"    # Transparent window decorations
dynamic_title = true           # Update title based on running process
startup_mode = "Windowed"      # Start in windowed mode
opacity = 0.95                 # 95% opacity for subtle transparency
blur = true                    # Enable background blur
option_as_alt = "Both"         # macOS: Use Option key as Alt
```

**Window Dimensions:**

- **Columns**: 120 characters wide
- **Lines**: 40 lines tall
- **Padding**: 10px horizontal, 15px vertical

### Environment Variables

- `TERM`: Set to `xterm-256color` for maximum compatibility

### Mouse Configuration

- **Hide when typing**: Enabled for distraction-free typing
- **Middle-click paste**: Enabled for Unix-style clipboard workflow

### Keyboard Bindings

| Key Combination | Action | Description              |
| --------------- | ------ | ------------------------ |
| `Ctrl + V`      | Paste  | Standard paste operation |
| `Ctrl + B`      | Copy   | Copy selected text       |

## Theme System

### Available Theme Categories

The configuration includes `catppucin_*` and `tokyo_night` colorschemes by default.

#### **Popular Dark Themes**

- **Catppuccin** (Mocha, Macchiato, Frappe)
- **Tokyo Night**

#### **Light Themes**

- **Catppuccin Latte**

### Theme Structure

Each theme file follows this structure:

```toml
[colors.primary]
background = "#282828"    # Terminal background
foreground = "#ebdbb2"    # Default text color

[colors.normal]           # Standard ANSI colors (0-7)
black   = "#282828"
red     = "#cc241d"
# ... (8 colors)

[colors.bright]           # Bright ANSI colors (8-15)
black   = "#928374"
red     = "#fb4934"
# ... (8 colors)

[colors.cursor]           # Cursor colors
text = "#24273a"
cursor = "#f4dbd6"

[colors.selection]        # Text selection colors
text = "#24273a"
background = "#f4dbd6"
```

### Theme Integration with Omarchy

The configuration integrates with the Omarchy theming system:

- **Current theme**: Referenced in `omarchy/themes/catppuccin/alacritty.toml`
- **Dynamic switching**: Themes change automatically with Omarchy theme selection
- **System-wide consistency**: Colors match other applications (waybar, hyprland, etc.)

## Integration with Development Tools

### Shell Integration

Works seamlessly with:

- **Zsh** with custom prompt (Starship)
- **Tmux/Zellij** session management
- **Neovim** with matching colorschemes

### Workflow Features

- **GPU acceleration** for smooth scrolling and rendering
- **True color support** (24-bit) for accurate syntax highlighting
- **Unicode support** including Nerd Font icons
- **Fast startup** compared to electron-based terminals

## Troubleshooting

### Common Issues

1. **Font not found**:

   ```bash
   # Verify font installation
   fc-list | grep -i cascadia

   # Refresh font cache
   fc-cache -fv
   ```

2. **Theme not loading**:

   ```bash
   # Check file path
   ls ~/.config/alacritty/themes/

   # Validate TOML syntax
   alacritty --print-events
   ```

3. **Transparency not working**:
   - Ensure compositor is running (Hyprland/Picom)
   - Check if window manager supports transparency

### Performance Issues

```toml
[scrolling]
history = 1000            # Reduce if using excessive memory

[font]
size = 12                 # Smaller fonts render faster

[window]
opacity = 1.0             # Disable transparency
blur = false              # Disable blur
```

## Advanced Configuration

### Custom Keybindings

```toml
[keyboard]
bindings = [
  # Clipboard operations
  { key = "V", mods = "Control", action = "Paste" },
  { key = "C", mods = "Control", action = "Copy" },

  # Navigation
  { key = "Plus", mods = "Control", action = "IncreaseFontSize" },
  { key = "Minus", mods = "Control", action = "DecreaseFontSize" },
  { key = "Key0", mods = "Control", action = "ResetFontSize" },

  # Search
  { key = "F", mods = "Control", action = "SearchForward" },
  { key = "B", mods = "Control", action = "SearchBackward" },
]
```

## Related Documentation

- [Official Alacritty Documentation](https://alacritty.org/config-alacritty.html)
- [Omarchy Theme System](https://omarchy.dev/docs/themes)
- [Font Configuration Guide](../README.md#fonts)
- [Hyprland Integration](../hypr/README.md)

