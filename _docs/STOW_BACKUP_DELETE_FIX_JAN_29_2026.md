# Stow Backup Deleting Repository Files Fix - January 29, 2026

## Problem

The stow backup logic was **deleting files from the dotfiles repository** when running stow operations. Git would show many deleted files:

```bash
$ git status
Changes not staged for commit:
  deleted:    bat/.config/bat/config
  deleted:    bat/.config/bat/themes/Catppuccin Frappe.tmTheme
  deleted:    nvim/.config/nvim/init.lua
  deleted:    nvim/.config/nvim/lua/config/autocmds.lua
  ... (many more deleted files)
```

This happened when running stow on already-stowed packages.

## Root Cause

**File**: `scripts/manage-stow.sh` (lines 105-160)

The backup function checks individual files for conflicts, but **doesn't check if parent directories are already symlinked** to the dotfiles.

### What Was Happening

1. **Initial stow** creates directory symlinks:
   ```
   ~/.config/bat → ../../.files/bat/.config/bat
   ~/.config/nvim → ../../.files/nvim/.config/nvim
   ```

2. **Backup function** checks for conflicts by looking at individual files:
   ```bash
   target="$HOME/.config/bat/config"
   # Checks if ~/.config/bat/config exists
   ```

3. **Problem**: When checking `~/.config/bat/config`, bash **follows the symlink**:
   ```
   ~/.config/bat/config
     ↓ (follows symlink)
   ~/.files/bat/.config/bat/config  # THE ACTUAL FILE IN THE REPO!
   ```

4. **Backup logic** sees the file exists, backs it up, and **deletes the original**:
   ```bash
   cp -a "$target" "$backup_target"  # Backs up repo file
   rm -rf "$target"                  # DELETES repo file!
   ```

5. **Result**: Files in the repository get deleted, git shows them as deleted

## Solution

Added logic to check if **any parent directory is a symlink to the dotfiles** before checking individual files:

```bash
# Check if any parent directory is a symlink to our dotfiles
local parent_dir="$target"
local is_already_stowed=false
while [[ "$parent_dir" != "$HOME" ]] && [[ "$parent_dir" != "/" ]]; do
    parent_dir=$(dirname "$parent_dir")
    if [[ -L "$parent_dir" ]]; then
        local parent_resolved=$(readlink -f "$parent_dir" 2>/dev/null || echo "")
        if [[ "$parent_resolved" == *"$DOTFILES_ROOT/$pkg"* ]]; then
            is_already_stowed=true
            break
        fi
    fi
done

# Skip if file is already stowed via parent directory symlink
[[ "$is_already_stowed" == true ]] && continue
```

### How It Works

1. For each file to stow (e.g., `.config/bat/config`), walk up the directory tree
2. Check each parent directory (`~/.config/bat`, `~/.config`, `~`)
3. If any parent is a symlink pointing to our dotfiles, mark as already stowed
4. Skip backing up files that are already stowed via parent symlink

### Example

Checking `~/.config/bat/config`:
```
1. Check ~/.config/bat/config - not a symlink
2. Move up: ~/.config/bat - IS A SYMLINK!
3. Resolve: points to ~/.files/bat/.config/bat
4. Contains DOTFILES_ROOT? YES
5. Skip backup ✅ (file is already stowed)
```

## Changes Made

### Line Updates (around lines 105-130)

**Before:**
```bash
local target="$HOME/$file"

# Skip if target doesn't exist
[[ ! -e "$target" ]] && continue

# If target is a symlink, check where it points
if [[ -L "$target" ]]; then
    # ... check symlink ...
fi
```

**After:**
```bash
local target="$HOME/$file"

# Skip if target doesn't exist
[[ ! -e "$target" ]] && [[ ! -L "$target" ]] && continue

# Check if any parent directory is a symlink to our dotfiles
local parent_dir="$target"
local is_already_stowed=false
while [[ "$parent_dir" != "$HOME" ]] && [[ "$parent_dir" != "/" ]]; do
    parent_dir=$(dirname "$parent_dir")
    if [[ -L "$parent_dir" ]]; then
        local parent_resolved=$(readlink -f "$parent_dir" 2>/dev/null || echo "")
        if [[ "$parent_resolved" == *"$DOTFILES_ROOT/$pkg"* ]]; then
            is_already_stowed=true
            break
        fi
    fi
done

# Skip if file is already stowed via parent directory symlink
[[ "$is_already_stowed" == true ]] && continue

# If target is a symlink, check where it points
if [[ -L "$target" ]]; then
    # ... check symlink ...
fi
```

## Testing

### Before Fix
```bash
$ ./scripts/manage-stow.sh stow bat
[INFO] Stowing: bat
[INFO] Creating backup at: ~/.dotfiles-stow-backup-...
[WARN] Backed up: ~/.config/bat/config
[WARN] Backed up: ~/.config/bat/themes/Catppuccin Mocha.tmTheme
... (backs up all files)

$ git status
  deleted:    bat/.config/bat/config
  deleted:    bat/.config/bat/themes/...
  ❌ Repository files deleted!
```

### After Fix
```bash
$ ./scripts/manage-stow.sh stow bat
[INFO] Stowing: bat
[✓] bat stowed

# No backup messages!

$ git status
  # No deleted files
  ✅ Repository files safe!
```

### Full Test
```bash
$ ./scripts/manage-stow.sh stow
[INFO] Stowing: zsh
[✓] zsh stowed

[INFO] Stowing: mise
[✓] mise stowed

[INFO] Stowing: zellij
[✓] zellij stowed

[INFO] Stowing: bat
[✓] bat stowed

[INFO] Stowing: nvim
[✓] nvim stowed

[INFO] Stowing: starship
[✓] starship stowed

[✓] Stow operation complete!

$ git status
# No deleted files from any package ✅
```

## Impact

- ✅ Repository files are never deleted
- ✅ Re-running stow is safe (idempotent)
- ✅ Only backs up actual conflicts
- ✅ Correctly identifies already-stowed files
- ✅ Works with both file and directory symlinks
- ✅ No breaking changes

## Files Modified

- `scripts/manage-stow.sh` (lines ~105-130)

## Related Issues

This complements the earlier "Smart ZSH Backup Logic" fix which handled the special case for zsh files. This fix makes the general backup logic smarter for all packages.

## Lesson Learned

When dealing with symlinks, always check parent directories as well. A file might not be a symlink itself, but could be accessible via a parent directory symlink, which would cause operations to affect the symlink target instead of the expected location.
