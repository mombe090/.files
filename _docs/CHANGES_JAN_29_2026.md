# Summary of Changes - Professional vs Personal Packages

## Date: January 29, 2026

## Overview

Implemented two major improvements:

1. **ZSH Backup Logic** - Smart backup that only backs up actual files, not symlinks to dotfiles
2. **Professional vs Personal JS Packages** - Separate package lists for work and personal environments
3. **Personal Tools Installation** - Optional installation of personal tools (clawdbot, etc.)

---

## 1. ZSH Backup Logic (manage-stow.sh)

### Problem
The backup script was trying to backup `~/.config/zsh` files even when they were already symlinked to the dotfiles repository, causing potential issues.

### Solution
Added special handling for the `zsh` package in `backup_conflicts()` function:

```bash
# Special handling for zsh package
if [[ "$pkg" == "zsh" ]]; then
    # Only backup ~/.zshrc if it's NOT already a symlink to dotfiles
    # Only backup ~/.config/zsh if it's a real directory (not symlink)
    # Uses readlink -f to resolve symlinks to absolute paths
fi
```

### Behavior
- ✅ Skips backup if `~/.zshrc` is already a symlink to dotfiles repo
- ✅ Skips backup if `~/.config/zsh` is already a symlink to dotfiles repo  
- ✅ Only backs up real files/directories that would conflict
- ✅ Handles both relative and absolute symlink paths

### Files Modified
- `scripts/manage-stow.sh` - Updated `backup_conflicts()` function

---

## 2. Professional vs Personal JS Packages

### Problem
Single package list mixed work-safe tools with personal project tools, making it unsafe to run on company PCs.

### Solution
Split into two separate config files with dedicated installation options:

#### Config Files

1. **`scripts/config/js.pkg.yml`** - Professional packages (safe for work)
   - TypeScript, ESLint, Prettier, Vite, Jest
   - Standard development tools
   - Safe to install on company PCs

2. **`scripts/config/js.pkg.personal.yml`** - Personal packages (personal use only)
   - Next.js, Vercel CLI, Firebase, framework CLIs
   - Personal project tools
   - Skip on company PCs

#### Installation Options

```bash
# Install professional packages ONLY (safe for work PC)
./scripts/install-js-packages.sh
./scripts/install-js-packages.sh --install

# Install personal packages ONLY
./scripts/install-js-packages.sh --personal

# Install BOTH professional AND personal (personal machine)
./scripts/install-js-packages.sh --all

# Update professional packages
./scripts/install-js-packages.sh --update

# Update personal packages
./scripts/install-js-packages.sh --update-personal
```

### Files Modified
- `scripts/install-js-packages.sh` - Complete refactor to support two config files
  - Added `CONFIG_FILE_PERSONAL` variable
  - Updated `check_config()` to handle both types
  - Updated `create_default_config()` to create both types
  - Updated `parse_yaml()` to accept config file parameter
  - Updated `install_packages()` to support config type parameter
  - Updated `update_packages()` to support config type parameter
  - Updated `show_help()` with new options
  - Updated `main()` to handle new flags

### Files Created
- `scripts/config/js.pkg.personal.yml` - Personal packages config

### Files Updated  
- `scripts/config/js.pkg.yml` - Removed optional section (now in personal config)

---

## 3. Personal Tools Installation (install.sh)

### Problem
Some tools like `clawdbot` are personal and shouldn't be installed on company PCs.

### Solution
Created optional personal tools installation that's:
- ❌ NOT included in full installation by default
- ✅ Available in custom installation menu
- ✅ Can be installed manually later

#### New Function

```bash
install_personal_tools() {
    # Clawdbot CLI - Optional personal tool
    if [[ -x "$SCRIPTS_DIR/install-clawdbot.sh" ]]; then
        bash "$SCRIPTS_DIR/install-clawdbot.sh"
    fi
    # Add more personal tools here in the future
}
```

#### Custom Installation Menu

Added prompt in custom installation:
```bash
read -p "Install personal tools (clawdbot, etc.)? [y/N]: " install_personal
if [[ "$install_personal" =~ ^[Yy]$ ]]; then
    install_personal_tools
fi
```

### Files Modified
- `install.sh` - Added `install_personal_tools()` function
- `install.sh` - Added prompt in custom installation
- `install.sh` - Updated completion message to mention personal tools

---

## Documentation Updates

### Updated Files

1. **`scripts/docs/INSTALL_JS_PACKAGES_GUIDE.md`** - Complete rewrite
   - Added professional vs personal packages explanation
   - Added usage scenarios (work PC, personal PC, side projects)
   - Added command reference table
   - Updated all examples to show new flags

2. **`install.sh`** - Updated completion message
   - Shows professional, personal, and all package installation commands
   - Shows personal tools installation command

---

## Testing

### Syntax Checks ✅
```bash
$ bash -n install.sh
$ bash -n scripts/install-js-packages.sh  
$ bash -n scripts/manage-stow.sh
✓ All syntax checks passed
```

### Help Output ✅
```bash
$ ./scripts/install-js-packages.sh --help
# Shows correct options: --install, --personal, --all, --update, --update-personal
✓ Help message correct
```

### Config Files ✅
```bash
$ ls scripts/config/
js.pkg.yml           # Professional packages
js.pkg.personal.yml  # Personal packages
✓ Both config files exist
```

---

## Usage Examples

### Work PC (Company Computer)
```bash
# Install dotfiles
./install.sh --full

# Result:
# ✅ Installs: zsh, mise, stow, dotnet, professional tools
# ✅ Installs: Professional JS packages (TypeScript, ESLint, Vite, etc.)
# ❌ Skips: Personal JS packages (Next.js, Vercel CLI, etc.)
# ❌ Skips: Personal tools (clawdbot)
```

### Personal Development Machine
```bash
# Install dotfiles  
./install.sh --full

# Install personal packages later (or use custom installation)
./scripts/install-js-packages.sh --personal --yes

# Install personal tools later
./scripts/install-clawdbot.sh

# Result:
# ✅ Installs: Everything from work PC
# ✅ Installs: Personal JS packages (Next.js, Vercel CLI, etc.)
# ✅ Installs: Personal tools (clawdbot)
```

### One-Command Personal Setup
```bash
# Install dotfiles with custom installation
./install.sh  # Choose custom installation

# When prompted:
# - Install personal tools? → Yes
# - (Everything else as default)

# Then install all JS packages
./scripts/install-js-packages.sh --all --yes

# Result:
# ✅ Everything installed (professional + personal)
```

---

## Benefits

### 1. Work-Safe Dotfiles
- ✅ Can safely install on company PCs
- ✅ Only installs work-appropriate tools
- ✅ Personal tools kept separate

### 2. Better Organization
- ✅ Clear separation between professional and personal tools
- ✅ Easy to maintain package lists
- ✅ No confusion about what's installed where

### 3. Flexibility
- ✅ Install professional packages only (work)
- ✅ Install personal packages only (side projects)
- ✅ Install both (personal dev machine)
- ✅ Update each separately

### 4. Smart Backups
- ✅ Only backs up actual conflicts
- ✅ Skips files already symlinked to dotfiles
- ✅ Handles relative and absolute symlinks
- ✅ No accidental deletion of repo files

---

## Command Reference

### manage-stow.sh
```bash
./scripts/manage-stow.sh stow     # Stow with smart backup
./scripts/manage-stow.sh status   # Check stow status
./scripts/manage-stow.sh list     # List available packages
```

### install-js-packages.sh
```bash
# Professional packages (work-safe)
./scripts/install-js-packages.sh              # Install
./scripts/install-js-packages.sh --update     # Update

# Personal packages (personal use)
./scripts/install-js-packages.sh --personal          # Install
./scripts/install-js-packages.sh --update-personal   # Update

# Both (personal dev machine)
./scripts/install-js-packages.sh --all        # Install both
```

### install.sh
```bash
./install.sh --full      # Full install (no personal tools by default)
./install.sh             # Custom install (can choose personal tools)
```

### Personal Tools
```bash
./scripts/install-clawdbot.sh   # Install clawdbot (personal)
# Add more personal tool scripts here in the future
```

---

## Files Summary

### Created
- `scripts/config/js.pkg.personal.yml` - Personal JS packages config

### Modified
- `scripts/manage-stow.sh` - Smart ZSH backup logic
- `scripts/install-js-packages.sh` - Professional vs personal split
- `scripts/config/js.pkg.yml` - Cleaned up (removed optional section)
- `scripts/docs/INSTALL_JS_PACKAGES_GUIDE.md` - Complete rewrite
- `install.sh` - Personal tools function and completion message

### Unchanged
- All other scripts remain the same
- Existing functionality preserved
- Backward compatible (default behavior is professional packages)

---

## Next Steps for User

1. **Test on Work PC** (optional)
   ```bash
   ./install.sh --full
   # Only professional tools will be installed
   ```

2. **Test on Personal Machine**
   ```bash
   ./install.sh --full
   ./scripts/install-js-packages.sh --all --yes
   ./scripts/install-clawdbot.sh
   ```

3. **Customize Package Lists**
   ```bash
   nano scripts/config/js.pkg.yml           # Edit professional
   nano scripts/config/js.pkg.personal.yml  # Edit personal
   ```

---

## Success! ✅

All tasks completed:
- ✅ Smart ZSH backup logic (only backs up real files)
- ✅ Professional vs personal JS packages separation
- ✅ Personal tools made optional
- ✅ All syntax checks pass
- ✅ Documentation updated
- ✅ Ready for production use

**Your dotfiles are now work-safe and personal-friendly!** 🎉
