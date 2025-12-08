# Install Script Performance Guide

## What Takes Time During Installation

### 1. Preflight Checks (< 1 second normally)
- ✓ Check Omarchy installation
- ✓ Check dependencies (git, stow)
- ⏸️ **USER CONFIRMATION** - Waits for 'y' input

### 2. Package Management (Variable - can be slow)
- Checks which packages are already installed
- ⏳ **PACMAN INSTALL** - If packages need to be installed, this can take 30s-5min depending on:
  - Number of packages
  - Download speed
  - Package size
  - Mirror speed

### 3. Configuration Patches (< 5 seconds)
- Stows hypr configs (symlink creation - instant)
- Injects source lines into hyprland.conf
- Copies and injects Zsh configs

### 4. Theme Integration (< 2 seconds)
- Stows theme directories (symlink creation - instant)

### 5. Post-Install (< 1 second)
- Verification
- Summary display

---

## How to Speed Up Installation

### Skip Confirmation (Auto-Accept)

**Method 1: Force Mode**
```bash
cd ~/.files/scripts/omarchy
./install.sh --force
```

**Method 2: Dry-Run (No Changes)**
```bash
./install.sh --dry-run
```

**Method 3: Non-Interactive (Auto-Confirms)**
```bash
yes | ./install.sh
```

### Skip Package Installation

If packages are already installed, the script will detect and skip them automatically.

**To manually skip packages:**
```bash
# Empty the custom.list temporarily
mv ~/.files/scripts/omarchy/packages/custom.list{,.bak}
touch ~/.files/scripts/omarchy/packages/custom.list

# Run install
./install.sh

# Restore
mv ~/.files/scripts/omarchy/packages/custom.list{.bak,}
```

---

## Progress Indicators Added

### ✨ New Features (Dec 2025)

**Preflight:**
```
[INFO] Running preflight checks...
[INFO] → Checking Omarchy installation...
[SUCCESS] Omarchy detected (version: 2024.12)
[INFO] → Checking dependencies...
[INFO]   ✓ git
[INFO]   ✓ stow
[SUCCESS] All required dependencies found
[INFO] → Awaiting user confirmation...
[INFO] Press 'y' to continue or 'n' to abort...
```

**Packages:**
```
[INFO] Checking 6 packages: fzf ripgrep eza fd bat delta
[INFO]   ✓ fzf (already installed)
[INFO]   ✓ ripgrep (already installed)
[INFO]   → eza (will install)
[INFO]   → fd (will install)
[INFO]   ✓ bat (already installed)
[INFO]   ✓ delta (already installed)
[INFO] Installing 2 packages...
[INFO] This may take a few moments...
```

**Config:**
```
[INFO] Applying configuration patches...
[INFO] → [1/3] Patching: git
[INFO] → [2/3] Patching: hypr
[INFO]   → Stowing hypr configs...
[INFO]   ✓ Hypr configs stowed
[INFO]   → Injecting custom sources into hyprland.conf...
[INFO]   ✓ Injected 3 custom config sources
[INFO] → [3/3] Patching: zsh
```

---

## Typical Installation Times

### First Install (All Packages Needed)
```
Preflight:         2-3 seconds (with user confirmation)
Packages:          30s-5min (depends on download speed)
Config:            3-5 seconds
Themes:            1-2 seconds
Post-install:      1 second
-------------------------------------------
TOTAL:             ~1-6 minutes
```

### Subsequent Runs (All Packages Installed)
```
Preflight:         2-3 seconds (with user confirmation)
Packages:          < 1 second (skipped, already installed)
Config:            3-5 seconds
Themes:            1-2 seconds
Post-install:      1 second
-------------------------------------------
TOTAL:             ~10-15 seconds
```

### Force Mode (Skip Confirmation)
```
Preflight:         < 1 second (no confirmation)
Packages:          < 1 second (skipped)
Config:            3-5 seconds
Themes:            1-2 seconds
Post-install:      1 second
-------------------------------------------
TOTAL:             ~5-10 seconds
```

---

## Troubleshooting Slow Installations

### Issue: Stuck at "Awaiting user confirmation"

**Cause:** Script is waiting for keyboard input

**Solution:**
```bash
# Use force mode to skip
./install.sh --force
```

### Issue: Pacman taking forever

**Cause:** Slow mirror or large package downloads

**Check progress:**
```bash
# In another terminal
tail -f ~/.local/state/dotfiles/omarchy-patches.log
```

**Speed up:**
```bash
# Update mirror list for faster downloads
sudo pacman-mirrors --fasttrack
sudo pacman -Syy
```

### Issue: Installation seems frozen

**Check what's running:**
```bash
# In another terminal
ps aux | grep -E "(pacman|stow|install)"
```

**Check logs:**
```bash
tail -f ~/.local/state/dotfiles/omarchy-patches.log
```

---

## Current Package List

**File:** `~/.files/scripts/omarchy/packages/custom.list`

```
# Modern CLI tools
fzf         # Fuzzy finder (< 1MB, instant)
ripgrep     # Fast grep (< 5MB, instant)
eza         # Modern ls (< 2MB, instant)
fd          # Fast find (< 1MB, instant)
bat         # Cat with syntax highlighting (< 5MB, instant)
delta       # Git diff viewer (< 10MB, ~5-10 seconds)
```

**Total size:** ~25MB
**Install time:** ~30 seconds on good connection

---

## Monitoring Installation Progress

### Real-Time Log Following
```bash
# Terminal 1: Run install
cd ~/.files/scripts/omarchy
./install.sh

# Terminal 2: Watch logs
tail -f ~/.local/state/dotfiles/omarchy-patches.log
```

### Check What Phase You're In
```bash
# See recent log entries
tail -20 ~/.local/state/dotfiles/omarchy-patches.log

# Look for:
# [INFO] Starting: Preflight checks
# [INFO] Starting: Package management
# [INFO] Starting: Configuration patches
# [INFO] Starting: Theme integration
# [INFO] Starting: Post-install tasks
```

### See Pacman Progress
```bash
# If stuck on packages, check pacman
sudo pacman -Q fzf ripgrep eza fd bat delta
```

---

## Best Practices

### Development (Frequent Runs)
```bash
# Skip confirmation every time
./install.sh --force
```

### First Setup
```bash
# Let it run normally to see what's happening
./install.sh
# Press 'y' when prompted
```

### Testing Changes
```bash
# Dry-run to see what would happen
./install.sh --dry-run

# Then apply for real
./install.sh --force
```

---

## Related Files

- Install script: `~/.files/scripts/omarchy/install.sh`
- Package list: `~/.files/scripts/omarchy/packages/custom.list`
- Log file: `~/.local/state/dotfiles/omarchy-patches.log`
- Preflight scripts: `~/.files/scripts/omarchy/preflight/`
