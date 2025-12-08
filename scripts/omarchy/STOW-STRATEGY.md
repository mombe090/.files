# Stow Strategy for Dotfiles

## Overview

This dotfiles repository uses **GNU Stow** for symlink management with a hybrid approach:
- **Hypr configs:** Stowed (symlinked)
- **Themes:** Stowed (symlinked)
- **Zsh configs:** Injected (sourced, not symlinked)
- **Git configs:** Injected (included, not symlinked)

## Architecture

### 1. Hypr - Stow Strategy

**Structure:**
```
~/.files/hypr/
└── .config/
    └── hypr/
        ├── custom/
        │   ├── monitors_custom.conf
        │   ├── bindings_custom.conf
        │   └── workspaces_custom.conf
        ├── autostart.conf
        ├── bindings.conf
        ├── hyprland.conf
        └── ...
```

**Stowed to:**
```
~/.config/hypr/custom/monitors_custom.conf  -> ~/.files/hypr/.config/hypr/custom/monitors_custom.conf
~/.config/hypr/custom/bindings_custom.conf  -> ~/.files/hypr/.config/hypr/custom/bindings_custom.conf
~/.config/hypr/custom/workspaces_custom.conf -> ~/.files/hypr/.config/hypr/custom/workspaces_custom.conf
```

**Injection:**
The install script injects these lines into `~/.files/hypr/.config/hypr/hyprland.conf`:
```conf
# === Custom Dotfiles Overrides ===
source = /home/user/.config/hypr/custom/monitors_custom.conf
source = /home/user/.config/hypr/custom/bindings_custom.conf
source = /home/user/.config/hypr/custom/workspaces_custom.conf
```

**Benefits:**
- ✅ Edit custom configs in `~/.files/hypr/.config/hypr/custom/` 
- ✅ Changes immediately reflected (symlinks)
- ✅ Git tracks all customizations
- ✅ Non-destructive layering on top of Omarchy defaults

### 2. Themes - Stow Strategy

**Structure:**
```
~/.files/themes/
└── .config/
    └── omarchy/
        └── themes/
            ├── catppuccin/
            │   ├── alacritty.toml
            │   ├── backgrounds/
            │   ├── hyprland.conf
            │   └── ...
            ├── tokyo-night/
            │   └── ...
            └── rose-pine/
                └── ...
```

**Stowed to:**
```
~/.config/omarchy/themes/catppuccin   -> ~/.files/themes/.config/omarchy/themes/catppuccin
~/.config/omarchy/themes/tokyo-night  -> ~/.files/themes/.config/omarchy/themes/tokyo-night
~/.config/omarchy/themes/rose-pine    -> ~/.files/themes/.config/omarchy/themes/rose-pine
```

**Usage:**
```bash
# Switch themes with Omarchy
omarchy theme catppuccin
omarchy theme tokyo-night
omarchy theme rose-pine

# Edit themes in dotfiles
nvim ~/.files/themes/.config/omarchy/themes/catppuccin/hyprland.conf
# Changes are immediate (symlinks)

# Add new themes
cp -r ~/.local/share/omarchy/themes/gruvbox ~/.files/themes/.config/omarchy/themes/
cd ~/.files/scripts/omarchy && ./install.sh
```

### 3. Zsh - Injection Strategy

**Structure:**
```
~/.files/zsh/.config/zsh/custom/
├── aliases.zsh
├── completions.zsh
├── env.zsh
├── fzf.git.zsh
├── history.zsh
├── Keybindings.zsh
└── plugins.zsh
```

**Copied to:**
```
~/.config/zsh/custom/
├── aliases.zsh
├── completions.zsh
├── ...
```

**Injected into `~/.zshrc`:**
```zsh
[[ -f "/home/user/.config/zsh/custom/aliases.zsh" ]] && source "/home/user/.config/zsh/custom/aliases.zsh"
[[ -f "/home/user/.config/zsh/custom/completions.zsh" ]] && source "/home/user/.config/zsh/custom/completions.zsh"
# ... etc
```

**Why not stow?**
- Zsh configs are copied (not symlinked) to avoid conflicts with Omarchy's zsh setup
- Injection is idempotent and non-destructive
- Allows machine-specific customizations

### 4. Git - Injection Strategy

**Injected into `~/.gitconfig`:**
```ini
[include]
    path = ~/.config/delta/themes/catppuccin.gitconfig
```

**Why not stow?**
- Git config may have machine-specific settings
- Injection preserves existing git config

## Installation

### Full Install
```bash
cd ~/.files/scripts/omarchy
./install.sh
```

**What it does:**
1. **Backup** - Creates timestamped backups of all configs
2. **Preflight** - Checks dependencies (Omarchy, stow, etc.)
3. **Packages** - Installs/removes packages
4. **Config** - Stows hypr, injects zsh/git sources
5. **Themes** - Stows theme directories
6. **Post-install** - Verifies and shows summary

### Dry Run
```bash
./install.sh --dry-run
```

### Manual Stow

**Stow hypr:**
```bash
cd ~/.files
stow -R hypr
```

**Stow themes:**
```bash
cd ~/.files
stow -R themes
```

**Unstow:**
```bash
cd ~/.files
stow -D hypr
stow -D themes
```

## Editing Custom Configs

### Hypr Custom Configs

Edit in dotfiles (changes are immediate):
```bash
nvim ~/.files/hypr/.config/hypr/custom/monitors_custom.conf
hyprctl reload  # Apply changes
```

Example monitor config:
```conf
# Dual monitors
monitor=DP-1,2560x1440@144,0x0,1
monitor=HDMI-A-1,1920x1080@60,2560x0,1
```

### Themes

Edit in dotfiles (changes are immediate):
```bash
nvim ~/.files/themes/.config/omarchy/themes/catppuccin/hyprland.conf
omarchy theme catppuccin  # Re-apply theme
```

### Zsh Custom Configs

Edit in dotfiles, then re-run install:
```bash
nvim ~/.files/zsh/.config/zsh/custom/aliases.zsh
cd ~/.files/scripts/omarchy && ./install.sh
exec zsh  # Reload shell
```

## Adding New Custom Configs

### New Hypr Custom Config

1. Create in dotfiles:
```bash
nvim ~/.files/hypr/.config/hypr/custom/looknfeel_custom.conf
```

2. Re-stow:
```bash
cd ~/.files && stow -R hypr
```

3. The script will auto-inject the source line

### New Theme

1. Copy from Omarchy:
```bash
cp -r ~/.local/share/omarchy/themes/gruvbox ~/.files/themes/.config/omarchy/themes/
```

2. Customize:
```bash
nvim ~/.files/themes/.config/omarchy/themes/gruvbox/hyprland.conf
```

3. Re-run install:
```bash
cd ~/.files/scripts/omarchy && ./install.sh
```

4. Switch to it:
```bash
omarchy theme gruvbox
```

## Benefits of This Hybrid Approach

### Stow (Hypr, Themes)
- ✅ **Immediate changes** - Edits in dotfiles are instantly active
- ✅ **Version control** - Git tracks all customizations
- ✅ **Easy sync** - Share configs across machines
- ✅ **Selective** - Only stow what you want

### Injection (Zsh, Git)
- ✅ **Non-destructive** - Preserves existing configs
- ✅ **Idempotent** - Safe to run multiple times
- ✅ **Machine-specific** - Allows local customizations
- ✅ **Compatible** - Works with Omarchy's structure

## File Locations

### Source (Dotfiles Repository)
```
~/.files/
├── hypr/.config/hypr/custom/          # Hypr custom configs (stowed)
├── themes/.config/omarchy/themes/     # Custom themes (stowed)
├── zsh/.config/zsh/custom/            # Zsh configs (copied)
└── scripts/omarchy/                   # Install scripts
```

### Target (Active Configs)
```
~/.config/
├── hypr/custom/                       # Symlinked to dotfiles
├── omarchy/themes/                    # Symlinked to dotfiles
└── zsh/custom/                        # Copied from dotfiles

~/.zshrc                               # Injected source lines
```

### Backups
```
~/.local/state/dotfiles/backups/
├── hyprland.conf.backup_TIMESTAMP
├── .zshrc.backup_TIMESTAMP
└── ...
```

### Logs
```
~/.local/state/dotfiles/omarchy-patches.log
```

## Troubleshooting

### Stow Conflicts

If stow reports conflicts:
```bash
cd ~/.files
stow --adopt hypr    # Adopt existing files
stow --adopt themes
```

### Reset to Defaults

1. Unstow everything:
```bash
cd ~/.files
stow -D hypr
stow -D themes
```

2. Restore from backup:
```bash
cp ~/.local/state/dotfiles/backups/hyprland.conf.backup_* ~/.config/hypr/hyprland.conf
```

### Re-sync After Edits

If you edit files outside the dotfiles repo:
```bash
cd ~/.files/scripts/omarchy
./install.sh
```

## Related Documentation

- Main README: `~/.files/README.md`
- Install script: `~/.files/scripts/omarchy/README.md`
- Themes: `~/.files/themes/README.md`
- Hypr configs: `~/.files/hypr/README.md`
