# Omarchy Themes

This directory contains custom Omarchy themes managed via GNU Stow.

## Structure

```
themes/
└── .config/
    └── omarchy/
        └── themes/
            ├── catppuccin/
            │   ├── alacritty.toml
            │   ├── backgrounds/
            │   ├── btop.theme
            │   ├── ghostty.conf
            │   ├── hyprland.conf
            │   ├── hyprlock.conf
            │   ├── mako.ini
            │   └── ...
            ├── tokyo-night/
            │   └── ...
            └── rose-pine/
                └── ...
```

## How It Works

When you run `~/.files/scripts/omarchy/install.sh`, the themes are **stowed** (symlinked) to:
```
~/.config/omarchy/themes/catppuccin    -> ~/.files/themes/.config/omarchy/themes/catppuccin
~/.config/omarchy/themes/tokyo-night   -> ~/.files/themes/.config/omarchy/themes/tokyo-night
~/.config/omarchy/themes/rose-pine     -> ~/.files/themes/.config/omarchy/themes/rose-pine
```

## Available Themes

- **catppuccin** - Soothing pastel theme with warm colors
- **tokyo-night** - Dark, modern theme inspired by Tokyo at night
- **rose-pine** - Low-contrast, warm theme with earthy tones

## Adding New Themes

### Method 1: Copy from Omarchy

```bash
cp -r ~/.local/share/omarchy/themes/gruvbox ~/.files/themes/.config/omarchy/themes/
cd ~/.files/scripts/omarchy
./install.sh
```

### Method 2: Create Custom Theme

1. Create a new directory:
   ```bash
   mkdir -p ~/.files/themes/.config/omarchy/themes/my-custom-theme
   ```

2. Add theme files:
   ```bash
   cd ~/.files/themes/.config/omarchy/themes/my-custom-theme
   # Copy and edit theme files from another theme as template
   ```

3. Re-run install:
   ```bash
   cd ~/.files/scripts/omarchy
   ./install.sh
   ```

## Switching Themes

Use Omarchy's theme switcher:
```bash
omarchy theme catppuccin
# or
omarchy theme tokyo-night
# or
omarchy theme rose-pine
```

## Editing Themes

Edit theme files in your dotfiles:
```bash
nvim ~/.files/themes/.config/omarchy/themes/catppuccin/hyprland.conf
```

Changes are immediately reflected (because of symlinks). To apply:
```bash
hyprctl reload  # For Hyprland changes
# or
omarchy theme catppuccin  # Re-apply full theme
```

## Theme Files Explained

Each theme contains:
- `alacritty.toml` - Terminal colors
- `backgrounds/` - Wallpaper images
- `btop.theme` - System monitor colors
- `chromium.theme` - Browser theme colors
- `ghostty.conf` - Ghostty terminal colors
- `hyprland.conf` - Window manager colors & effects
- `hyprlock.conf` - Lock screen styling
- `icons.theme` - Icon theme selection
- `kitty.conf` - Kitty terminal colors
- `mako.ini` - Notification styling
- `neovim.lua` - Neovim theme
- `preview.png` - Theme preview image
- `swayosd.css` - OSD styling
- `vscode.json` - VSCode theme
- `walker.css` - Launcher styling
- `waybar.css` - Status bar styling

## Benefits of Stow

✅ **Symlinks** - Changes in dotfiles are immediately active
✅ **Version Control** - Git tracks all theme customizations
✅ **Easy Sync** - Share themes across machines
✅ **Non-destructive** - Original Omarchy themes remain untouched
✅ **Selective** - Only stow the themes you want

## Unstowing

To remove symlinks:
```bash
cd ~/.files
stow -D themes
```

## Related

- Main install script: `~/.files/scripts/omarchy/install.sh`
- Theme integration: `~/.files/scripts/omarchy/themes/all.sh`
- Omarchy themes location: `~/.local/share/omarchy/themes/`
