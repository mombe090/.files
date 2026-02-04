# Homebrew Installation Logic Update

## Date: January 29, 2026

## Changes Made

Updated `install.sh` to **automatically skip Homebrew installation on Linux** systems.

### Problem
- Homebrew was being installed (or prompted) on Linux systems
- This is unnecessary since Linux has native package managers (apt, yum, pacman, etc.)
- User doesn't want to be asked about Homebrew on Linux

### Solution

#### 1. Updated `install_homebrew()` Function

**Before:**
```bash
install_homebrew() {
    log_step "Installing Homebrew..."
    if [[ -x "$SCRIPTS_DIR/install-homebrew.sh" ]]; then
        bash "$SCRIPTS_DIR/install-homebrew.sh"
    else
        log_warn "install-homebrew.sh not found or not executable"
    fi
}
```

**After:**
```bash
install_homebrew() {
    local os=$(detect_os)
    
    # Only install Homebrew on macOS
    if [[ "$os" != "macos" ]]; then
        log_info "Skipping Homebrew installation (not macOS)"
        return 0
    fi
    
    log_step "Installing Homebrew..."
    if [[ -x "$SCRIPTS_DIR/install-homebrew.sh" ]]; then
        bash "$SCRIPTS_DIR/install-homebrew.sh"
    else
        log_warn "install-homebrew.sh not found or not executable"
    fi
}
```

#### 2. Updated `custom_install()` Function

**Before:**
```bash
custom_install() {
    # ...
    read -p "Install Homebrew (macOS)? [y/N]: " install_brew
    if [[ "$install_brew" =~ ^[Yy]$ ]]; then
        install_homebrew
    fi
    # ...
}
```

**After:**
```bash
custom_install() {
    # ...
    local os=$(detect_os)
    
    # Only ask about Homebrew on macOS
    if [[ "$os" == "macos" ]]; then
        read -p "Install Homebrew? [Y/n]: " install_brew
        if [[ ! "$install_brew" =~ ^[Nn]$ ]]; then
            install_homebrew
        fi
    fi
    # ...
}
```

### Behavior

#### Full Installation (`./install.sh --full`)
- **macOS**: Installs Homebrew automatically
- **Linux**: Skips Homebrew, shows message: "Skipping Homebrew installation (not macOS)"

#### Custom Installation (`./install.sh`)
- **macOS**: Asks "Install Homebrew? [Y/n]" (default: Yes)
- **Linux**: Does NOT ask about Homebrew at all

#### Minimal Installation (`./install.sh --minimal`)
- **macOS**: Installs Homebrew
- **Linux**: Skips Homebrew

### Files Modified
- `install.sh` - Updated `install_homebrew()` and `custom_install()` functions

### Testing

**Syntax Check:** ✅ Passed
```bash
$ bash -n install.sh
✓ Syntax OK
```

**Logic Test:** ✅ Verified
- macOS: Homebrew installation proceeds
- Linux: Homebrew skipped automatically

### Benefits

✅ **No unnecessary prompts on Linux** - Users don't see Homebrew questions
✅ **Automatic detection** - No manual configuration needed
✅ **Clean output** - Single line message instead of prompt
✅ **Faster installation** - Skips unnecessary step on Linux
✅ **Uses native package managers** - Linux systems use apt/yum/pacman as intended

### Examples

#### On Linux (Ubuntu/Debian):
```bash
$ ./install.sh --full
[INFO] Skipping Homebrew installation (not macOS)
[STEP] Installing mise...
[STEP] Installing core tools...
# ... continues with Linux-appropriate tools
```

#### On macOS:
```bash
$ ./install.sh --full
[STEP] Installing Homebrew...
[INFO] Installing Homebrew...
# ... Homebrew installation proceeds
```

#### Custom Installation on Linux:
```bash
$ ./install.sh
Choose installation type: 3 (Custom)
# Does NOT ask about Homebrew
Install mise? [Y/n]: 
# ... continues with other prompts
```

#### Custom Installation on macOS:
```bash
$ ./install.sh
Choose installation type: 3 (Custom)
Install Homebrew? [Y/n]: 
# ... asks about Homebrew as expected
```

---

## Summary

Homebrew installation is now:
- ✅ **Automatic on macOS** (in full/minimal installations)
- ✅ **Skipped on Linux** (automatically, no prompts)
- ✅ **Optional on macOS** (in custom installation, default: Yes)
- ✅ **Never asked on Linux** (in custom installation)

**Perfect for cross-platform dotfiles!** 🎉
