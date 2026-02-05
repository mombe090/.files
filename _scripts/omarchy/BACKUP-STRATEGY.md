# Backup Strategy - Safety First!

## 🛡️ Comprehensive Backup on Every Execution

Every time you run `./install.sh`, a comprehensive backup is created **BEFORE** any changes are made.

## Flow Diagram

```
./install.sh
    ↓
[Initialize logging & backup system]
    ↓
[CREATE COMPREHENSIVE BACKUP] ← YOU ARE HERE (Before any changes!)
    ├── ~/.config/hypr/hyprland.conf
    ├── ~/.config/zsh/ (entire directory)
    ├── ~/.zshrc
    └── ~/.gitconfig
    ↓
[Preflight checks]
    ↓
[Package management]
    ↓
[Configuration patches]
    ├── hypr.sh (+ individual backup if needed)
    ├── zsh.sh (+ individual backup if needed)
    └── git.sh (+ individual backup if needed)
    ↓
[Theme integration]
    ↓
[Post-install verification]
    ↓
[SUCCESS!]
```

## Double-Layer Protection

### Layer 1: Comprehensive Backup (Entry Point)
**When:** At the start of `./install.sh`, before ANY changes
**What:** All critical config files and directories
**Why:** Complete restore point if anything goes wrong

### Layer 2: Individual Script Backups
**When:** Before each script modifies a file
**What:** Specific file being modified
**Why:** Granular restore if specific change causes issues

## Backup Locations

All backups stored in:
```
~/.local/state/dotfiles/backups/
```

### Timestamped Files

Every backup includes timestamp in filename:
```
hyprland.conf.backup_20251207_231646
zshrc.backup_20251207_231646
zsh.backup_20251207_231646
gitconfig.backup_20251207_231646
```

### Never Overwritten

- Each run creates new timestamped backups
- Previous backups preserved
- Can restore from any point in time

## Commands

### List All Backups
```bash
ls -lht ~/.local/state/dotfiles/backups/
```

### Find Recent Backups
```bash
ls -lt ~/.local/state/dotfiles/backups/ | head -10
```

### Restore a File
```bash
# Example: Restore hyprland.conf
cp ~/.local/state/dotfiles/backups/hyprland.conf.backup_20251207_231646 \
   ~/.config/hypr/hyprland.conf
```

### Restore Entire Directory
```bash
# Example: Restore zsh directory
rm -rf ~/.config/zsh
cp -r ~/.local/state/dotfiles/backups/zsh.backup_20251207_231646 \
      ~/.config/zsh
```

### Clean Old Backups (Optional)
```bash
# Keep only backups from last 7 days
find ~/.local/state/dotfiles/backups/ -type f -mtime +7 -delete
```

## Dry-Run Mode

Even in dry-run, you see what would be backed up:
```bash
./install.sh --dry-run

# Output shows:
# [DRY RUN] Would create comprehensive backup before changes
```

## Safety Guarantees

✅ **Backup FIRST, change LATER** - Always in that order
✅ **Timestamped** - Never lose previous backups
✅ **Comprehensive** - All critical files backed up
✅ **Double-layer** - Entry point + per-script backups
✅ **Logged** - All backup operations in log file
✅ **Automatic** - No manual steps required

## Emergency Restore

If something goes wrong:

### 1. Check What Was Backed Up
```bash
tail -100 ~/.local/state/dotfiles/omarchy-patches.log | grep "Backed up"
```

### 2. List Available Backups
```bash
ls -lht ~/.local/state/dotfiles/backups/
```

### 3. Restore Needed Files
```bash
# Find the timestamp from the last successful run
# Restore each file from that timestamp
cp ~/.local/state/dotfiles/backups/FILE.backup_TIMESTAMP \
   ~/.config/path/to/FILE
```

### 4. Reload Configs
```bash
exec zsh           # Reload shell
hyprctl reload     # Reload Hyprland
```

## Testing the Backup

You can verify backups are working:

```bash
# Run once
./install.sh

# Check backups were created
ls -lt ~/.local/state/dotfiles/backups/

# You should see timestamped backup files
```

## Why This Approach?

1. **Peace of Mind** - Always have a restore point
2. **No Surprises** - Backup happens before any change
3. **Easy Recovery** - Simple copy command to restore
4. **History** - Keep multiple restore points
5. **Automatic** - Works every time, no extra steps

---

**Remember:** Every execution of `./install.sh` creates fresh backups first!
