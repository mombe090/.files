# Omarchy Dotfiles Patches

Automated patching system to integrate custom dotfiles with Omarchy Linux using an **injection strategy**.

## Overview

Instead of replacing Omarchy's configurations or using complex symlinks, these patches:

1. **Create custom config files** in `~/.config/<app>/custom/`
2. **Inject source statements** into Omarchy's existing configs
3. **Preserve Omarchy's structure** - your changes layer on top
4. **Are idempotent** - safe to run multiple times

## Installation

```bash
cd ~/.files/scripts/omarchy
./install.sh
```

### Options

```bash
./install.sh                # Normal installation with confirmations
./install.sh --dry-run      # Preview changes without applying
./install.sh --force        # Skip confirmations
./install.sh --help         # Show help
```

## What It Does

### Hyprland

- Copies custom configs from `hypr/.config/hypr/` to `~/.config/hypr/custom/`
- Injects `source = ~/.config/hypr/custom/*.conf` into `hyprland.conf`
- Your custom configs include:
  - `monitors_custom.conf`
  - `bindings_custom.conf`
  - `workspaces_custom.conf`
  - `autostart_custom.conf`

### Zsh

- Copies all zsh configs to `~/.config/zsh/custom/`
- Injects source lines into `~/.zshrc`
- Preserves your aliases, functions, completions, etc.

### Git

- Creates `~/.config/git/custom.gitconfig`
- Injects include directive into `~/.gitconfig`
- Copies global gitignore

### Package Management

- Removes unwanted Omarchy defaults (configure in `packages/unwanted.list`)
- Installs custom packages (configure in `packages/custom.list`)

## Directory Structure

```
scripts/omarchy/
├── install.sh                   # Main entry point
│
├── helpers/                     # Utility functions
│   ├── all.sh                  # Source all helpers
│   ├── logging.sh              # Logging with timestamps
│   ├── detection.sh            # System detection
│   ├── backup.sh               # Automatic backups
│   └── inject.sh               # Idempotent injection
│
├── preflight/                   # Pre-install checks
│   ├── all.sh
│   ├── check-omarchy.sh        # Verify Omarchy
│   ├── check-deps.sh           # Check dependencies
│   └── confirm.sh              # User confirmation
│
├── packages/                    # Package management
│   ├── all.sh
│   ├── uninstall-defaults.sh
│   ├── install-custom.sh
│   ├── unwanted.list           # Configure here
│   └── custom.list             # Configure here
│
├── config/                      # Config patches
│   ├── all.sh
│   ├── hypr.sh                 # Hyprland patches
│   ├── zsh.sh                  # Zsh patches
│   └── git.sh                  # Git patches
│
├── themes/                      # Theme integration
│   └── all.sh
│
└── post-install/                # Finalization
    ├── all.sh
    ├── verify.sh               # Verify installation
    └── summary.sh              # Display summary
```

## Configuration

### Adding Custom Hyprland Configs

1. Edit files in `hypr/.config/hypr/`:
   - `monitors_custom.conf`
   - `bindings_custom.conf`
   - `workspaces_custom.conf`

2. Run the patches:
   ```bash
   ./install.sh
   ```

3. Reload Hyprland:
   ```bash
   hyprctl reload
   ```

### Managing Packages

Edit `packages/unwanted.list`:
```
# Remove packages you don't want
kitty
firefox
```

Edit `packages/custom.list`:
```
# Add packages you want
fzf
ripgrep
```

Run patches to apply changes.

## How It Works - Injection Strategy

### Before Patching

Omarchy's `~/.config/hypr/hyprland.conf`:
```bash
source = ~/.local/share/omarchy/default/hypr/autostart.conf
source = ~/.local/share/omarchy/default/hypr/bindings/media.conf
# ... more Omarchy defaults
```

### After Patching

Same file, with additions at the end:
```bash
source = ~/.local/share/omarchy/default/hypr/autostart.conf
source = ~/.local/share/omarchy/default/hypr/bindings/media.conf
# ... more Omarchy defaults

# === Custom Dotfiles Overrides ===
source = ~/.config/hypr/custom/monitors_custom.conf
source = ~/.config/hypr/custom/bindings_custom.conf
source = ~/.config/hypr/custom/workspaces_custom.conf
```

### Benefits

✅ **Non-destructive** - Original Omarchy configs untouched  
✅ **Idempotent** - Safe to run multiple times  
✅ **Updatable** - Edit in dotfiles, re-run patches  
✅ **Compatible** - Benefit from Omarchy updates  
✅ **Clear** - Your customizations in `custom/` directories

## Safety Features

### Automatic Backups

Before any modification:
- Original files backed up to `~/.local/state/dotfiles/backups/`
- Timestamped: `filename.backup_20251207_123456`

### Comprehensive Logging

All operations logged to:
- `~/.local/state/dotfiles/omarchy-patches.log`

### Idempotent Operations

- Source lines checked before injection
- Won't duplicate entries
- Safe to run repeatedly

### Dry Run Mode

Test without making changes:
```bash
./install.sh --dry-run
```

## Rollback

### Remove Custom Sources

Edit the config file and remove lines from:
```bash
# === Custom Dotfiles Overrides ===
```

Or restore from backup:
```bash
ls ~/.local/state/dotfiles/backups/
cp ~/.local/state/dotfiles/backups/hyprland.conf.backup_TIMESTAMP \
   ~/.config/hypr/hyprland.conf
```

## Adding New App Patches

1. Create `config/<app>.sh`:
   ```bash
   #!/usr/bin/env bash
   # <App> configuration patches
   
   log_info "Applying <app> patches..."
   
   DOTFILES_APP="$DOTFILES_ROOT/<app>/.config/<app>"
   TARGET_APP="$HOME/.config/<app>"
   CUSTOM_DIR="$TARGET_APP/custom"
   
   # Create custom directory
   mkdir -p "$CUSTOM_DIR"
   
   # Copy custom configs
   cp "$DOTFILES_APP/custom.conf" "$CUSTOM_DIR/custom.conf"
   
   # Inject source line
   inject_source "$TARGET_APP/config.conf" \
                 "source = $CUSTOM_DIR/custom.conf"
   
   log_success "<App> patches applied"
   ```

2. Script automatically runs via `config/all.sh`

## Troubleshooting

### Check Logs

```bash
tail -f ~/.local/state/dotfiles/omarchy-patches.log
```

### Verify Source Lines

```bash
grep "Custom Dotfiles Overrides" ~/.config/hypr/hyprland.conf
```

### Re-run Patches

Safe to run anytime:
```bash
./install.sh
```

### Test Configuration

```bash
# Hyprland
hyprctl reload

# Zsh
exec zsh

# Git
git config --list
```

## Development

### Testing Changes

1. Edit configs in dotfiles
2. Run with dry-run:
   ```bash
   ./install.sh --dry-run
   ```
3. Apply changes:
   ```bash
   ./install.sh
   ```

### Adding Features

See planning documents in `agents/plan/omarchy/`:
- `dotfiles-evolution-plan.md` - Complete architecture
- `injection-strategy.md` - Injection approach details
- `implementation-questions.md` - Configuration options

## Documentation

- **Planning Docs:** `../../agents/plan/omarchy/`
- **Strategy:** `../../agents/plan/omarchy/injection-strategy.md`
- **Full Plan:** `../../agents/plan/omarchy/dotfiles-evolution-plan.md`

## License

Part of your personal dotfiles. Use as you see fit!

## Credits

Built following Omarchy's patching patterns with an injection strategy for non-destructive configuration management.

## Backup Strategy

### Comprehensive Backup on Every Run

**IMPORTANT:** Every time you run `./install.sh`, the system creates backups BEFORE any changes:

```bash
./install.sh  # Backs up everything first, then applies patches
```

### What Gets Backed Up

On every execution, the following are backed up:
- `~/.config/hypr/hyprland.conf`
- `~/.config/zsh/` (entire directory)
- `~/.zshrc`
- `~/.gitconfig`

Plus, each individual script also backs up files before modification.

### Backup Location

All backups are timestamped and stored in:
```
~/.local/state/dotfiles/backups/
```

Example backup files:
```
hyprland.conf.backup_20251207_231646
zshrc.backup_20251207_231646
```

### Restore from Backup

If something goes wrong:

```bash
# List backups
ls -lht ~/.local/state/dotfiles/backups/

# Restore a file
cp ~/.local/state/dotfiles/backups/hyprland.conf.backup_TIMESTAMP \
   ~/.config/hypr/hyprland.conf
```

### Safety Guarantees

✅ **Backup before execution** - Every run starts with comprehensive backup  
✅ **Additional backups per-script** - Each config script also backs up before changes  
✅ **Timestamped** - Never overwrites previous backups  
✅ **Logged** - All backup operations logged  
✅ **Dry-run shows message** - See backup plan without executing  

