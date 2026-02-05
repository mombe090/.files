# Simplified Architecture (v2.0)

## Visual Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         install.sh                              │
│                    (Thin Orchestrator)                          │
│                                                                 │
│  • No business logic                                            │
│  • No duplicate checks                                          │
│  • Just calls scripts                                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
     ┌────────────────────────┴────────────────────────┐
     │                                                  │
     ▼                                                  ▼
┌─────────────────┐                          ┌─────────────────┐
│  Core Scripts   │                          │ Optional Scripts│
├─────────────────┤                          ├─────────────────┤
│ • Homebrew      │                          │ • .NET SDK      │
│ • mise          │                          │ • JS Packages   │
│ • zsh           │                          │                 │
│ • stow          │                          │                 │
└─────────────────┘                          └─────────────────┘
     │                                                  │
     └────────────────────────┬────────────────────────┘
                              ▼
                    ┌─────────────────────┐
                    │  Management Scripts │
                    ├─────────────────────┤
                    │ • manage-stow.sh    │
                    │   - Auto-backup     │
                    │   - Symlink mgmt    │
                    │ • check-dotnet.sh   │
                    │ • backup.sh         │
                    │ • uninstall.sh      │
                    └─────────────────────┘
```

## Key Principles (Before & After)

### ❌ Before (v1.0)

```bash
# install.sh had duplicate logic
install_mise() {
    log_step "Installing mise..."

    # ❌ Duplicate check - mise script also checks this!
    if command -v mise &> /dev/null; then
        log_warn "mise already installed ($(mise --version))"
        return 0
    fi

    # ❌ Duplicate PATH logic - mise script handles this!
    bash "$SCRIPTS_DIR/install-mise.sh"

    if [[ -f "$HOME/.local/bin/mise" ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        eval "$(mise activate bash)"
    elif [[ -f "/usr/local/bin/mise" ]]; then
        export PATH="/usr/local/bin:$PATH"
        eval "$(mise activate bash)"
    fi

    log_success "mise installed"
}
```

### ✅ After (v2.0)

```bash
# install.sh just delegates
install_mise() {
    log_step "Installing mise..."
    if [[ -x "$SCRIPTS_DIR/install-mise.sh" ]]; then
        bash "$SCRIPTS_DIR/install-mise.sh"

        # ✅ Only activate in current shell (not duplicate logic)
        if command -v mise &> /dev/null; then
            eval "$(mise activate bash)" 2>/dev/null || true
        fi
    else
        log_warn "install-mise.sh not found or not executable"
    fi
}
```

```bash
# install-mise.sh handles ALL the logic
install_mise() {
    # ✅ Script checks if already installed
    if command -v mise &> /dev/null; then
        log_warn "mise already installed ($(mise --version))"
        return 0
    fi

    log_info "Installing mise..."

    # ✅ Script handles installation
    if [[ $EUID -eq 0 ]] || sudo -n true 2>/dev/null; then
        curl https://mise.run | sudo MISE_INSTALL_PATH=/usr/local/bin/mise sh
        export PATH="/usr/local/bin:$PATH"
    else
        curl https://mise.run | sh
        export PATH="$HOME/.local/bin:$PATH"
    fi

    log_info "mise installed"
}

# ✅ Script handles shell configuration
configure_shell() {
    # Adds mise activation to .zshrc/.bashrc
    ...
}
```

## Function Comparison

| Function | Before (v1.0) | After (v2.0) | Lines Saved |
|----------|---------------|--------------|-------------|
| `install_homebrew()` | 25 lines | 8 lines | **-17** |
| `install_mise()` | 22 lines | 11 lines | **-11** |
| `install_zsh()` | Logic in install.sh | Delegated to script | **All** |
| `install_stow()` | Logic in install.sh | Delegated to script | **All** |
| `install_dotnet()` | 15 lines with checks | 7 lines | **-8** |
| `stow_configs()` | 3 lines | 10 lines (with fallback) | **+7** |

**Total**: ~40 lines removed from install.sh, logic moved to self-contained scripts

## Benefits

### 1. **Single Responsibility**
- Each script does ONE thing
- install.sh just orchestrates
- No duplicate code

### 2. **Easier Testing**
```bash
# Test scripts independently
./scripts/install-mise.sh
./scripts/install-dotnet.sh
./scripts/manage-stow.sh stow

# Scripts are self-contained, don't need install.sh
```

### 3. **Better Maintainability**
```bash
# Want to fix mise installation? Edit ONE file:
vim scripts/install-mise.sh

# Not TWO files:
# ❌ vim install.sh (check logic)
# ❌ vim scripts/install-mise.sh (install logic)
```

### 4. **Clearer Error Messages**
```bash
# Before: Errors could come from install.sh OR script
[ERROR] Failed to install mise
# Where did this come from? install.sh or install-mise.sh?

# After: Errors clearly from the script
[ERROR] Failed to install mise  # From install-mise.sh
[WARN] install-mise.sh not found  # From install.sh
```

### 5. **Graceful Degradation**
```bash
# Scripts handle their own logic
if command -v mise &> /dev/null; then
    log_warn "mise already installed"
    return 0  # ✅ Exit gracefully
fi

# install.sh doesn't need to know
bash "$SCRIPTS_DIR/install-mise.sh"  # Just call it
```

## Installation Flow (Simplified)

```
User runs: ./install.sh --full
         │
         ▼
┌────────────────────────┐
│  check_prerequisites() │  ← Only checks git & curl (universal requirements)
└────────────────────────┘
         │
         ▼
┌────────────────────────┐
│   backup_configs()     │  ← Backs up existing dotfiles
└────────────────────────┘
         │
         ▼
┌────────────────────────┐
│  install_homebrew()    │  → scripts/install-homebrew.sh
│                        │    ├── Detects OS
│                        │    ├── Checks if installed
│                        │    ├── Installs brew
│                        │    └── Configures PATH
└────────────────────────┘
         │
         ▼
┌────────────────────────┐
│   install_mise()       │  → scripts/install-mise.sh
│                        │    ├── Checks if installed
│                        │    ├── Installs mise
│                        │    └── Configures shell
└────────────────────────┘
         │
         ▼
┌────────────────────────┐
│ install_core_tools()   │  → scripts/install-zsh.sh
│                        │  → scripts/install-stow.sh
│                        │    Each script:
│                        │    ├── Detects OS
│                        │    ├── Checks if installed
│                        │    ├── Installs tool
│                        │    └── Configures as needed
└────────────────────────┘
         │
         ▼
┌────────────────────────┐
│install_optional_tools()│  → Uses install_package() helper
│                        │    ├── Tries mise first
│                        │    └── Falls back to brew/apt/yum
└────────────────────────┘
         │
         ▼
┌────────────────────────┐
│  install_dotnet()      │  → scripts/install-dotnet.sh
│                        │    ├── Detects OS & distro
│                        │    ├── Checks if installed
│                        │    ├── Installs .NET SDK
│                        │    └── Configures PATH
└────────────────────────┘
         │
         ▼
┌────────────────────────┐
│ install_mise_tools()   │  ← Runs 'mise install' if available
└────────────────────────┘
         │
         ▼
┌────────────────────────┐
│   stow_configs()       │  → scripts/manage-stow.sh stow
│                        │    ├── Auto-backups conflicts
│                        │    ├── Stows packages
│                        │    └── Shows summary
└────────────────────────┘
         │
         ▼
┌────────────────────────┐
│   post_install()       │  ├── Creates .gitconfig.local
│                        │  ├── Creates .env/.envrc
│                        │  └── scripts/install-js-packages.sh
│                        │      ├── Checks for bun
│                        │      ├── Reads js.pkg.yml
│                        │      └── Installs packages
└────────────────────────┘
         │
         ▼
┌────────────────────────┐
│ show_completion_msg()  │  ← Shows next steps
└────────────────────────┘
```

## Script Self-Containment

Each script is **fully self-contained**:

```bash
#!/usr/bin/env bash
# scripts/install-mise.sh

# ✅ Own logging functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ✅ Own checks
if command -v mise &> /dev/null; then
    log_warn "mise already installed"
    return 0
fi

# ✅ Own installation logic
install_mise() {
    # Installation code
}

# ✅ Own configuration logic
configure_shell() {
    # Shell configuration code
}

# ✅ Own main function
main() {
    install_mise
    configure_shell
    log_info "✓ Done!"
}

main "$@"
```

## Error Handling

### install.sh
```bash
# Stops on error for core functions
set -e

# Optional operations don't stop installation
install_package "$cmd" "${tools[$cmd]}" || log_warn "Failed (optional)"
AUTO_CONFIRM=true bash "$SCRIPTS_DIR/install-js-packages.sh" --yes || true
```

### Scripts
```bash
# Scripts handle their own errors
if [[ "$os" == "unknown" ]]; then
    log_error "Unsupported OS"
    exit 1  # Script exits, install.sh continues
fi

# Graceful exits
if command -v mise &> /dev/null; then
    log_warn "Already installed"
    return 0  # Not an error
fi
```

## Testing

### Syntax Check (All Pass ✅)
```bash
$ bash -n install.sh
$ bash -n scripts/*.sh
✓ All scripts pass syntax check
```

### Individual Script Testing
```bash
# Test each script independently
$ ./scripts/install-mise.sh
[INFO] Installing mise for dotfiles
[WARN] mise already installed (mise 2024.1.0)
✓ Done!

$ ./scripts/manage-stow.sh status
===========================================
GNU Stow Package Status
===========================================
✓ zsh
✓ mise
✓ bat
...
```

## Future Improvements

### 1. Shared Utility Library
Create `lib/utils.sh`:
```bash
#!/usr/bin/env bash
# Shared logging functions

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

detect_os() {
    # OS detection logic
}
```

Source in scripts:
```bash
source "$(dirname "$0")/lib/utils.sh"
```

### 2. Add --help to All Scripts
```bash
$ ./scripts/install-mise.sh --help
Usage: install-mise.sh [OPTIONS]

Installs mise version manager globally and configures shell integration.

Options:
  --help, -h     Show this help message
  --verbose, -v  Verbose output
```

### 3. Add --dry-run Mode
```bash
$ ./install.sh --full --dry-run
[DRY-RUN] Would check prerequisites...
[DRY-RUN] Would backup configs...
[DRY-RUN] Would install homebrew...
...
```

## Summary

**Before (v1.0)**:
- ❌ Duplicate checks in install.sh and scripts
- ❌ Logic spread across multiple files
- ❌ Hard to test scripts independently
- ❌ Unclear where errors originate

**After (v2.0)**:
- ✅ Scripts are fully self-contained
- ✅ No duplicate logic
- ✅ Easy to test independently
- ✅ Clear separation of concerns
- ✅ Simpler install.sh (40+ lines removed)
- ✅ Better error messages
- ✅ Easier maintenance

**Result**: Cleaner, more maintainable, easier to test, and better documented! 🎉
