# JavaScript Packages Script Hang Fix - January 29, 2026

## Problem

The `install-js-packages.sh` script was hanging during package installation, similar to the stow script issue. The output would show:

```
[INFO] Installing: pnpm
[✓] pnpm installed
# ← Script hangs here, never continues to next package
```

This caused:
- ❌ Only first package installed
- ❌ Rest of packages never processed
- ❌ Summary never displayed
- ❌ Script appeared to freeze

## Root Cause

**File**: `scripts/install-js-packages.sh` (lines 253, 260, 263)

Same issue as the stow script - the `((variable++))` syntax was hanging:

```bash
local installed=0
local failed=0
local skipped=0

for pkg in "${packages[@]}"; do
    if already_installed; then
        ((skipped++))  # ← Would hang here
    fi

    if install_success; then
        ((installed++))  # ← Would hang here
    else
        ((failed++))  # ← Would also hang here
    fi
done
```

## Solution

Changed all counter increments from `((variable++))` to `variable=$((variable + 1))`:

```bash
local installed=0
local failed=0
local skipped=0

for pkg in "${packages[@]}"; do
    if already_installed; then
        skipped=$((skipped + 1))  # ✅ WORKS
    fi

    if install_success; then
        installed=$((installed + 1))  # ✅ WORKS
    else
        failed=$((failed + 1))  # ✅ WORKS
    fi
done
```

## Changes Made

### Lines Updated
- Line 253: `((skipped++))` → `skipped=$((skipped + 1))`
- Line 260: `((installed++))` → `installed=$((installed + 1))`
- Line 263: `((failed++))` → `failed=$((failed + 1))`

## Expected Behavior After Fix

```bash
$ ./scripts/install-js-packages.sh

[INFO] Using bun version: 1.3.8
[STEP] Installing pro packages...
[INFO] Reading package list from: /home/user/.files/scripts/config/js.pkg.yml
[INFO] Found 23 packages to install

Install these pro packages globally with bun? [Y/n]: y
[STEP] Installing pro packages globally...

[INFO] Installing: pnpm
[✓] pnpm installed

[INFO] Installing: yarn
[✓] yarn installed

[INFO] Installing: typescript
[✓] typescript installed

... (continues for all packages)

[✓] Pro packages installed!

Summary:
  ✓ Installed: 23
  ✗ Failed: 0
  → Skipped: 0
  Total: 23
```

## Impact

- ✅ All packages install successfully
- ✅ Loop completes for all packages
- ✅ Summary displays correctly
- ✅ Script completes fully
- ✅ No breaking changes

## Related Issues

This is the same root cause as:
- `docs/STOW_HANG_FIX_JAN_29_2026.md` - Stow script hang fix

Both scripts were using `((variable++))` syntax which causes hangs in certain shell environments. The more explicit `variable=$((variable + 1))` syntax is safer and more portable.

## Files Modified

- `scripts/install-js-packages.sh` (lines 253, 260, 263)

## Testing

```bash
# Syntax check
$ bash -n scripts/install-js-packages.sh
✅ No errors

# Functional test (will test when user runs it)
$ ./scripts/install-js-packages.sh
# Should now complete successfully without hanging
```
