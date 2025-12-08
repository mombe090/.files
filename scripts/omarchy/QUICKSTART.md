# Quick Start Guide

## What Was Built

✅ **Complete Omarchy patching system** using injection strategy
✅ **21 shell scripts** organized in Omarchy's pattern
✅ **Example custom configs** for Hyprland
✅ **Package management** for adding/removing packages
✅ **Comprehensive documentation**

## File Structure

```
scripts/omarchy/
├── install.sh              # Main entry point (EXECUTABLE)
├── README.md               # Full documentation
├── QUICKSTART.md           # This file
│
├── helpers/                # Utility functions
│   ├── logging.sh         # Logging with timestamps
│   ├── detection.sh       # System detection
│   ├── backup.sh          # Automatic backups
│   └── inject.sh          # Idempotent source injection
│
├── preflight/             # Pre-install checks
├── packages/              # Package management
├── config/                # Configuration patches
├── themes/                # Theme integration
└── post-install/          # Verification & summary
```

## First Run

### 1. Preview Changes (Dry Run)

```bash
cd ~/.files/scripts/omarchy
./install.sh --dry-run
```

This shows what would be done without making any changes.

### 2. Apply Patches

```bash
./install.sh
```

This will:
- Check you're on Omarchy
- Ask for confirmation
- Create `~/.config/<app>/custom/` directories
- Copy your custom configs
- Inject source lines into Omarchy configs
- Backup everything first!

### 3. Reload Configs

```bash
exec zsh           # Reload shell
hyprctl reload     # Reload Hyprland
```

## What It Does

### Hyprland Example

**Before:**
```bash
~/.config/hypr/hyprland.conf
# Just Omarchy's defaults
```

**After:**
```bash
~/.config/hypr/hyprland.conf
# Omarchy's defaults
# ... (untouched)

# === Custom Dotfiles Overrides ===
source = ~/.config/hypr/custom/monitors_custom.conf
source = ~/.config/hypr/custom/bindings_custom.conf
source = ~/.config/hypr/custom/workspaces_custom.conf
```

Your custom configs are now in `~/.config/hypr/custom/`!

## Customizing

### Edit Hyprland Monitors

1. Edit in your dotfiles:
   ```bash
   vim ~/.files/hypr/.config/hypr/monitors_custom.conf
   ```

2. Re-run patches:
   ```bash
   ./install.sh
   ```

3. Reload:
   ```bash
   hyprctl reload
   ```

### Add/Remove Packages

Edit `packages/unwanted.list`:
```
kitty    # Remove this if present
```

Edit `packages/custom.list`:
```
btop     # Add this
```

Run patches to apply.

## Safety Features

✅ **Automatic Backups** - Before any change  
✅ **Idempotent** - Run as many times as you want  
✅ **Dry Run Mode** - Preview before applying  
✅ **Comprehensive Logging** - Track all changes  
✅ **Non-Destructive** - Omarchy configs preserved  

## Logs & Backups

**Log file:**
```bash
~/.local/state/dotfiles/omarchy-patches.log
```

**Backups:**
```bash
~/.local/state/dotfiles/backups/
```

## Troubleshooting

### View Logs

```bash
tail -f ~/.local/state/dotfiles/omarchy-patches.log
```

### Verify Injections

```bash
grep "Custom Dotfiles Overrides" ~/.config/hypr/hyprland.conf
```

### Re-run Safely

It's idempotent, so just run again:
```bash
./install.sh
```

## Next Steps

1. ✅ Test with `--dry-run`
2. ✅ Run `./install.sh`
3. ✅ Customize your configs in `~/.files/`
4. ✅ Re-run patches to apply updates
5. ✅ Add more app patches as needed

## Adding More Apps

To patch other apps (alacritty, starship, etc.), create `config/<app>.sh` following the pattern in `config/hypr.sh`.

See full documentation in `README.md`!
