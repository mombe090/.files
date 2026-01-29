# Bun Global Packages PATH Configuration

## Problem

After installing global packages with bun, they are not accessible from the command line:

```bash
$ ./scripts/install-js-packages.sh
[✓] typescript installed
[✓] eslint installed
... (all packages install successfully)

$ tsc --version
zsh: command not found: tsc

$ eslint --version
zsh: command not found: eslint
```

## Root Cause

Bun installs global packages to `~/.bun/bin`, but this directory is **not in your PATH** by default.

When you install packages globally with bun:
```bash
$ bun add -g typescript
```

The executable (`tsc`) is installed to:
```
~/.bun/bin/tsc
```

But your shell doesn't know to look there unless `~/.bun/bin` is in your `$PATH`.

## Solution

The dotfiles configuration now includes bun's bin directory in the PATH via `env.zsh`:

**File**: `zsh/.config/zsh/env.zsh`

```bash
# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
```

## How to Apply the Fix

### Option 1: Restart Your Shell (Recommended)
```bash
exec $SHELL -l
```

This reloads your shell configuration, including the updated PATH.

### Option 2: Source Your .zshrc
```bash
source ~/.zshrc
```

This sources the configuration in your current shell session.

## Verification

After restarting your shell, verify the PATH is configured correctly:

### 1. Check if bun/bin is in PATH
```bash
$ echo $PATH | grep '.bun/bin'
/home/user/.bun/bin:/usr/local/bin:/usr/bin...
```

You should see `~/.bun/bin` (or `/home/user/.bun/bin`) in the output.

### 2. Check BUN_INSTALL variable
```bash
$ echo $BUN_INSTALL
/home/user/.bun
```

### 3. Verify installed packages are accessible
```bash
$ tsc --version
Version 5.7.3

$ eslint --version
v9.18.0

$ prettier --version
3.4.2
```

## Common Package Names vs Commands

Some packages have different executable names than their package names:

| Package Name | Command |
|-------------|---------|
| `typescript` | `tsc` (TypeScript Compiler) |
| `ts-node` | `ts-node` |
| `eslint` | `eslint` |
| `prettier` | `prettier` |
| `vite` | `vite` |
| `jest` | `jest` |
| `vitest` | `vitest` |
| `nodemon` | `nodemon` |
| `serve` | `serve` |
| `http-server` | `http-server` |

**Note**: Use `tsc --version` (not `typescript --version`)

## Troubleshooting

### Still getting "command not found" after restarting shell?

1. **Verify bun is installed:**
   ```bash
   $ which bun
   /home/user/.bun/bin/bun
   ```

2. **Check if packages are actually installed:**
   ```bash
   $ bun pm ls -g
   # Should list all globally installed packages
   ```

3. **Check if package binaries exist:**
   ```bash
   $ ls -la ~/.bun/bin/
   # Should show tsc, eslint, prettier, etc.
   ```

4. **Manually verify PATH:**
   ```bash
   $ echo $PATH
   # Should contain ~/.bun/bin
   ```

5. **Source env.zsh manually:**
   ```bash
   $ source ~/.config/zsh/env.zsh
   $ echo $PATH | grep '.bun/bin'
   # Should show ~/.bun/bin
   ```

### PATH not updating?

If the PATH still doesn't include `~/.bun/bin`:

1. **Check if zshrc loads env.zsh:**
   ```bash
   $ grep "env.zsh" ~/.zshrc
   source "$ZDOTDIR/env.zsh"
   ```

2. **Check ZDOTDIR:**
   ```bash
   $ echo $ZDOTDIR
   /home/user/.config/zsh
   ```

3. **Verify env.zsh exists:**
   ```bash
   $ ls -la ~/.config/zsh/env.zsh
   -rw-r--r-- 1 user user 3421 Jan 29 07:30 env.zsh
   ```

## Installation Flow

When you run `./install.sh --full`:

1. ✅ Dotfiles are stowed (including updated `env.zsh`)
2. ✅ Shell config is symlinked to `~/.zshrc`
3. ✅ JavaScript packages are installed via bun
4. ⚠️ **Packages are installed but not yet in PATH** (current shell session)
5. ✅ Restart shell → new PATH is loaded → packages accessible

## Files Modified

- `zsh/.config/zsh/env.zsh` - Added bun PATH configuration
- `install.sh` - Updated completion message to clarify shell restart needed

## Summary

- ✅ Bun global packages install to `~/.bun/bin`
- ✅ Dotfiles now configure `~/.bun/bin` in PATH
- ✅ After shell restart, all installed packages are accessible
- ✅ Works on both macOS and Linux (including VMs)
- ✅ No manual PATH configuration needed
