# Stow Script Hang Fix - January 29, 2026

## Problem

The installation process was hanging after stowing the first package (zsh) and never completing. The post-install completion message never appeared:

```
[INFO] Stowing: zsh
[✓] zsh stowed
# ← Script hangs here, never continues
```

## Root Cause

**File**: `scripts/manage-stow.sh` (lines 200-236)

The script was using the `((variable++))` syntax for incrementing counters:

```bash
local stowed=0
local failed=0
local skipped=0

for pkg in "${packages[@]}"; do
    # ...
    if stow -t "$HOME" "$pkg" 2>/dev/null; then
        log_success "$pkg stowed"
        ((stowed++))  # ← HUNG HERE
    else
        log_error "Failed to stow $pkg"
        ((failed++))  # Would also hang here
    fi
done
```

**Why it hung**:
- The `((variable++))` arithmetic expansion was causing the script to hang indefinitely
- This appears to be a shell compatibility issue or specific environment behavior
- The exact same syntax works fine in simple test scripts but fails inside the function
- Added debug logging which confirmed the hang occurred exactly at `((stowed++))`

## Solution

Changed all counter increments from `((variable++))` to `variable=$((variable + 1))`:

```bash
local stowed=0
local failed=0
local skipped=0

for pkg in "${packages[@]}"; do
    # ...
    if stow -t "$HOME" "$pkg" 2>/dev/null; then
        log_success "$pkg stowed"
        stowed=$((stowed + 1))  # ✅ WORKS
    else
        log_error "Failed to stow $pkg"
        failed=$((failed + 1))  # ✅ WORKS
    fi
done
```

## Changes Made

### Lines Updated
- Line 208: `((skipped++))` → `skipped=$((skipped + 1))`
- Line 221: `((stowed++))` → `stowed=$((stowed + 1))`
- Line 224: `((failed++))` → `failed=$((failed + 1))`

## Testing

### Before Fix
```bash
$ ./scripts/manage-stow.sh stow
[INFO] Stowing: zsh
[✓] zsh stowed
# ← Hangs forever, never processes mise, zellij, bat, nvim, starship
```

### After Fix
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

Summary:
  ✓ Stowed: 6
  ✗ Failed: 0
  → Skipped: 0
  Total: 6
```

### Full Installation Test
```bash
$ ./install.sh --full

# ... installation runs ...

[✓] Stow operation complete!

[STEP] Running post-install setup...
[✓] Post-install setup complete

==================================
✓ Installation Complete!
==================================

Next steps:
  1. Restart your shell to load new configurations
  2. ...
```

✅ **Completion message now appears!**

## Impact

- ✅ Stow operations now complete successfully
- ✅ All default packages are stowed (zsh, mise, zellij, bat, nvim, starship)
- ✅ Post-install message appears
- ✅ Installation completes fully
- ✅ No breaking changes to script API
- ✅ No functionality loss

## Related Issues

This also resolves the original complaint that "post install message does not appear" because the script was hanging before it could reach the `show_completion_message()` function in `install.sh`.

## Files Modified

- `scripts/manage-stow.sh` (lines 208, 221, 224)

## Lesson Learned

The `((variable++))` syntax, while standard Bash, can behave unexpectedly in certain contexts. The more explicit `variable=$((variable + 1))` syntax is safer and more portable.

**Related Documentation**:
- `docs/STOW_FIX_JAN_29_2026.md` - Previous stow logic fix
- `docs/COMPLETE_SUMMARY_JAN_29_2026.md` - Full day's work summary
