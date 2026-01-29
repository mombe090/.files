# .NET Installation Troubleshooting Guide

## Problem: "command not found: dotnet" After Installation

If you've installed .NET using `./install.sh` or `./scripts/install-dotnet.sh` but get "command not found" when running `dotnet`, this is almost always a PATH issue.

---

## Quick Fix (90% of cases)

### Option 1: Restart Your Shell (Recommended)

The simplest solution - close and reopen your terminal, or run:

```bash
exec $SHELL -l
```

This reloads your shell with a fresh environment, picking up the updated PATH.

### Option 2: Reload Shell Configuration

```bash
# If using zsh (default on modern systems)
source ~/.zshrc

# If using bash
source ~/.bashrc
```

### Option 3: Clear Command Hash (Bash/Zsh)

Sometimes the shell caches command locations:

```bash
hash -r
dotnet --version
```

---

## Diagnostic Steps

### 1. Run the Diagnostic Script

We've created a comprehensive diagnostic tool:

```bash
./scripts/check-dotnet.sh
```

This will:
- Check if dotnet is in your PATH
- Search for dotnet binary in common locations
- Show installed .NET packages
- Provide specific fix instructions

### 2. Manual Check: Find dotnet Binary

```bash
# Check common locations
ls -la /usr/bin/dotnet          # Ubuntu/Debian via apt
ls -la /usr/local/bin/dotnet    # macOS via Homebrew
ls -la $HOME/.dotnet/dotnet     # Manual install
```

If you find it, test directly:

```bash
/usr/bin/dotnet --version
```

If that works, add it to your PATH (see below).

### 3. Check if .NET Was Actually Installed

**Ubuntu/Debian:**
```bash
dpkg -l | grep dotnet
# Should show: dotnet-sdk-10.0
```

**macOS:**
```bash
brew list --cask | grep dotnet
# Should show: dotnet-sdk
```

**RHEL/Fedora:**
```bash
rpm -qa | grep dotnet
```

---

## Common Issues & Solutions

### Issue 1: .NET Installed but Not in PATH

**Symptoms:** You can run `/usr/bin/dotnet --version` but not `dotnet --version`

**Solution:** Add to dotfiles env configuration:

```bash
# Edit the dotfiles env config
nano ~/.config/zsh/env.zsh

# Add this section (if not already present):
# .NET configuration (Linux)
if [[ -d "$HOME/.dotnet" ]] && [[ ! -f "/usr/bin/dotnet" ]]; then
    export DOTNET_ROOT="$HOME/.dotnet"
    export PATH="$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools"
fi

# Save and reload
source ~/.zshrc
```

**Temporary fix (current session only):**
```bash
export PATH="$PATH:/usr/bin"
dotnet --version
```

### Issue 2: Ubuntu 22.04 with .NET 10 - Repository Not Added

**Symptoms:** Installation failed or .NET 10 not available

**Solution:** Add the backports repository:

```bash
sudo add-apt-repository ppa:dotnet/backports
sudo apt-get update
sudo apt-get install -y dotnet-sdk-10.0
```

### Issue 3: Multiple .NET Installations Conflicting

**Symptoms:** Different versions in different locations

**Solution:** Check all locations and unify:

```bash
# Find all dotnet installations
which -a dotnet
find /usr -name "dotnet" 2>/dev/null

# Decide which one to keep and update PATH accordingly
```

### Issue 4: VM/Container - PATH Not Persisted

**Symptoms:** Works in current session, but not after restart

**Solution:** Ensure PATH is set in dotfiles env config (not just exported in current session):

```bash
# Check if dotnet is configured
grep -r "DOTNET" ~/.config/zsh/env.zsh

# If not found, add it (see Issue 1 above)
# Or if using these dotfiles:
cd ~/.files
git pull  # Get latest with .NET PATH config
stow -R zsh  # Restow to update
source ~/.zshrc
```

---

## Platform-Specific Notes

### Ubuntu/Debian

After `apt install`, dotnet is typically at `/usr/bin/dotnet`, which should already be in PATH. If not working:

1. Check installation: `dpkg -l | grep dotnet-sdk-10.0`
2. Verify binary exists: `ls -la /usr/bin/dotnet`
3. Restart shell: `exec $SHELL -l`

### macOS (Homebrew)

After `brew install --cask dotnet-sdk`, dotnet is at `/usr/local/bin/dotnet`:

1. Check installation: `brew list --cask dotnet-sdk`
2. Verify binary exists: `ls -la /usr/local/bin/dotnet`
3. Run: `hash -r` or restart terminal

### RHEL/Fedora

After `yum/dnf install`, check:

1. Installation: `rpm -qa | grep dotnet-sdk-10.0`
2. Binary location: `/usr/bin/dotnet`
3. Restart shell

---

## Still Not Working?

### Verify Installation from Scratch

```bash
# 1. Check what's installed
./scripts/check-dotnet.sh

# 2. If nothing found, reinstall
./scripts/install-dotnet.sh --version 10.0

# 3. Watch for error messages during installation
# Look for:
#   - Permission errors (need sudo?)
#   - Repository errors (need to add PPA?)
#   - Download errors (network issue?)

# 4. After successful install, restart shell
exec $SHELL -l

# 5. Test
dotnet --version
```

### Manual Installation (Last Resort)

If package managers fail, use Microsoft's install script:

```bash
# Download and run install script
curl -fsSL https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --channel 10.0 --install-dir $HOME/.dotnet

# Add to dotfiles env config (recommended)
# Edit ~/.config/zsh/env.zsh and add:
#   if [[ -d "$HOME/.dotnet" ]]; then
#       export DOTNET_ROOT="$HOME/.dotnet"
#       export PATH="$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools"
#   fi

# Or temporary fix (current session only):
export PATH="$PATH:$HOME/.dotnet"
export DOTNET_ROOT="$HOME/.dotnet"

# Reload config (if added to env.zsh)
source ~/.zshrc

# Test
dotnet --version
```

---

## Get Help

If none of these solutions work:

1. Run the diagnostic: `./scripts/check-dotnet.sh` and save output
2. Check installation logs for errors
3. Note your OS version: `cat /etc/os-release` or `sw_vers` (macOS)
4. Create an issue with:
   - OS and version
   - Diagnostic script output
   - Installation method used
   - Any error messages

---

## Quick Reference Commands

```bash
# Check if dotnet is available
command -v dotnet

# Check dotnet version
dotnet --version

# See full .NET info
dotnet --info

# Restart shell
exec $SHELL -l

# Reload shell config
source ~/.zshrc  # or ~/.bashrc

# Clear command hash
hash -r

# Run diagnostics
./scripts/check-dotnet.sh

# Reinstall .NET 10
./scripts/install-dotnet.sh --version 10.0

# Manual install to home directory
curl -fsSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel 10.0
```
