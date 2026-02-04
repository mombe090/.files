# Quick Fix for "dotnet: command not found" in VM

## TL;DR - Fast Solution

After installing dotnet, restart your shell:

```bash
exec $SHELL -l
```

Then test:

```bash
dotnet --version
```

---

## Why This Happens

When you install .NET via `apt` (Ubuntu/Debian), the package manager:
1. Installs dotnet to `/usr/bin/dotnet`
2. `/usr/bin` is already in your `$PATH`
3. **BUT** your current shell session has already cached the available commands

Your shell doesn't know dotnet exists until you:
- Restart the shell, OR
- Clear the command cache with `hash -r`, OR
- Source your config with `source ~/.zshrc`

---

## Solutions (Pick One)

### Option 1: Restart Shell (Recommended)

```bash
exec $SHELL -l
```

This completely restarts your shell with a fresh environment.

### Option 2: Reload Config

```bash
source ~/.zshrc
```

This reloads your zsh configuration.

### Option 3: Clear Command Cache

```bash
hash -r
dotnet --version
```

This clears the cached command locations.

---

## Verify Installation

After restarting/reloading, verify:

```bash
# Check if dotnet is found
command -v dotnet

# Check version
dotnet --version

# Should show: 10.0.x
```

---

## If Still Not Working

Run the diagnostic script:

```bash
cd ~/.files
./_scripts/linux/sh/checkers/check-dotnet.sh
```

This will:
- Show you exactly where dotnet is installed
- Check your PATH configuration
- Provide specific fix instructions

---

## PATH Configuration (Already Handled)

The latest dotfiles include .NET PATH configuration in `zsh/.config/zsh/env.zsh`:

```bash
# .NET configuration (Linux)
# If installed via package manager (apt/yum), dotnet is in /usr/bin (already in PATH)
# If manually installed to ~/.dotnet, add to PATH
if [[ -d "$HOME/.dotnet" ]] && [[ ! -f "/usr/bin/dotnet" ]]; then
    export DOTNET_ROOT="$HOME/.dotnet"
    export PATH="$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools"
fi
```

This means:
- ✅ If dotnet installed via `apt` → no action needed (already in `/usr/bin`)
- ✅ If dotnet manually installed to `~/.dotnet` → automatically added to PATH
- ✅ Just need to restart shell after installation

---

## For Future Reference

After installing ANY new package/tool:
```bash
# Always restart shell or reload config
exec $SHELL -l
```

This ensures your environment picks up the new tools.

---

## Still Having Issues?

See the complete troubleshooting guide:

```bash
cat ~/.files/DOTNET_TROUBLESHOOTING.md
```

Or open an issue with the output of:

```bash
./_scripts/linux/sh/checkers/check-dotnet.sh
```
