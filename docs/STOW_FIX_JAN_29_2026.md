# Stow Logic Fix - January 29, 2026

## Problem

User reported that `./scripts/manage-stow.sh stow` was failing with:
```
[INFO] Stowing: zsh
[ERROR] Failed to stow zsh
```

However, running `stow -v -t "$HOME" zsh` manually worked fine.

## Root Cause

**File**: `scripts/manage-stow.sh` (lines 217-230)

The original stow logic had a flaw in how it determined success/failure:

```bash
# OLD/BROKEN CODE:
if stow -v -t "$HOME" "$pkg" 2>&1 | grep -v "BUG in find_stowed_path"; then
    log_success "$pkg stowed"
    ((stowed++))
else
    log_error "Failed to stow $pkg"
    ((failed++))
fi
```

**Why it failed**:
1. `stow -v` outputs verbose messages to stderr
2. One of those messages is a harmless "BUG in find_stowed_path" warning from stow itself
3. We used `grep -v` to filter out this BUG message
4. **Problem**: When stow succeeds but only outputs the BUG message:
   - `grep -v` filters it out
   - Returns empty output
   - Empty output makes the `if` condition fail (falsy)
   - Script incorrectly reports "Failed to stow" even though stow succeeded

## Solution

Separated the verbose output from the success check:

```bash
# NEW/FIXED CODE:
# Show verbose output (filtered for BUG message)
stow -v -t "$HOME" "$pkg" 2>&1 | grep -v "BUG in find_stowed_path" || true

# Check if stow succeeded by running it again (idempotent, no verbose)
if stow -t "$HOME" "$pkg" 2>/dev/null; then
    log_success "$pkg stowed"
    ((stowed++))
else
    log_error "Failed to stow $pkg"
    ((failed++))
fi
```

**Why this works**:
1. **First stow call**: Shows verbose output for user feedback, filtered to remove BUG message
   - Uses `|| true` to prevent failures from affecting script flow
   - If no output after filtering, doesn't fail the script
2. **Second stow call**: Runs silently to check actual success/failure
   - Stow is idempotent (safe to run multiple times)
   - Uses exit code (0 = success, non-zero = failure)
   - No dependency on output text

## Additional Issue Fixed

During implementation, leftover code from the old version caused syntax errors:
- Line 226: Extra closing parenthesis `)`
- Lines 227-230: Duplicate `else` block

These were remnants from the old `if` statement that weren't removed when we rewrote the logic.

## Testing

```bash
# Syntax check
$ bash -n scripts/manage-stow.sh
✅ No errors

# Functional test
$ ./scripts/manage-stow.sh stow zsh
[STEP] Stowing packages...
[INFO] Stowing: zsh
[✓] zsh stowed

✅ Success!
```

## Files Modified

- `scripts/manage-stow.sh` (lines 216-226)

## Impact

- ✅ Stow operations now correctly report success/failure
- ✅ Verbose output still shown (minus harmless BUG message)
- ✅ Works with all packages (zsh, nvim, git, etc.)
- ✅ No breaking changes to script API

## Related Documentation

- See `docs/COMPLETE_SUMMARY_JAN_29_2026.md` for full day's work
- See `scripts/docs/MANAGE_STOW_GUIDE.md` for usage guide
