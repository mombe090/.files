# Omarchy Dotfiles Evolution Plan

**Date:** December 7, 2025  
**Author:** AI Assistant  
**Purpose:** Evolve personal dotfiles to integrate with Omarchy's patching system

---

## Table of Contents

- [Overview](#overview)
- [Goals](#goals)
- [Architecture Understanding](#architecture-understanding)
- [Proposed Structure](#proposed-structure)
- [Detailed Implementation Plan](#detailed-implementation-plan)
- [Patterns and Best Practices](#patterns-and-best-practices)
- [Safety and Rollback](#safety-and-rollback)
- [Questions for User](#questions-for-user)

---

## Overview

This plan outlines how to evolve the current dotfiles repository to work seamlessly with Omarchy's configuration and patching system. The goal is to maintain your custom configurations while leveraging Omarchy's theme system and defaults.

### Current State

- **Dotfiles Structure:** Stow-based with separate directories per tool (alacritty, ghostty, hypr, zsh, nvim, etc.)
- **Omarchy Integration:** Basic backup in `omarchy_backup/` with themes and configs
- **Package Management:** Manual installation, no automated removal of unwanted defaults
- **Scripts:** Empty `scripts/` directory ready for patches

### Target State

- **Omarchy Patches:** Automated scripts in `scripts/omarchy/` to apply custom configurations
- **Package Management:** Scripts to uninstall unwanted Omarchy defaults and install preferred tools
- **Theme Integration:** Custom themes integrated with Omarchy's theme switcher
- **Idempotent Operations:** Safe to run patches multiple times
- **Documentation:** Clear docs on usage, customization, and troubleshooting

---

## Goals

### Primary Goals

1. ✅ Create Omarchy patch scripts organized following Omarchy's patterns
2. ✅ Automate removal of unwanted default Omarchy packages
3. ✅ Integrate custom dotfiles with Omarchy's configuration structure
4. ✅ Maintain compatibility with existing stow-based workflow
5. ✅ Enable theme integration with Omarchy's theme switcher

### Secondary Goals

1. ✅ Provide rollback capabilities for all patches
2. ✅ Log all operations for debugging
3. ✅ Support dry-run mode for testing
4. ✅ Create comprehensive documentation
5. ✅ Follow shell scripting best practices from AGENTS.md

---

## Architecture Understanding

### Omarchy's Installation System

Based on research of [basecamp/omarchy](https://github.com/basecamp/omarchy), here's how Omarchy organizes installations:

```
omarchy/
├── install/
│   ├── helpers/              # Utility functions
│   │   ├── all.sh           # Sources all helpers
│   │   ├── logging.sh       # Logging with live tail
│   │   ├── errors.sh        # Error handling
│   │   └── presentation.sh  # UI with gum
│   │
│   ├── preflight/           # Pre-install checks
│   │   ├── all.sh
│   │   ├── guard.sh
│   │   └── ...
│   │
│   ├── packaging/           # Package installation
│   │   ├── all.sh
│   │   ├── base.sh
│   │   ├── fonts.sh
│   │   └── ...
│   │
│   ├── config/              # Configuration patching
│   │   ├── all.sh
│   │   ├── config.sh
│   │   ├── theme.sh
│   │   ├── git.sh
│   │   └── hardware/        # Hardware-specific fixes
│   │       ├── nvidia.sh
│   │       ├── fix-apple-t2.sh
│   │       └── ...
│   │
│   └── post-install/        # Finalization
│       └── all.sh
│
├── themes/                  # Theme definitions
├── config/                  # Base configurations
├── default/                 # Default configs (sourced by apps)
└── install.sh              # Main entry point
```

### Key Patterns in Omarchy

1. **Phase-based Execution:** `preflight → packaging → config → post-install`
2. **Orchestration Pattern:** Each phase has `all.sh` that calls individual scripts
3. **Logging:** All scripts run through `run_logged()` function
4. **Conditional Execution:** Hardware fixes only run when hardware is detected
5. **Symlink Heavy:** Uses symlinks for theme switching and config management
6. **Idempotent:** All scripts can be run multiple times safely

### Omarchy's Configuration Locations

- **System Defaults:** `~/.local/share/omarchy/default/` (don't edit)
- **User Config:** `~/.config/<app>/` (your customizations)
- **Themes:** `~/.config/omarchy/themes/`
- **Current Theme:** `~/.config/omarchy/current/theme/` (symlink)
- **Branding:** `~/.config/omarchy/branding/`

### How Apps Load Configs

Example from Hyprland:
```bash
# hyprland.conf
source = ~/.local/share/omarchy/default/hypr/autostart.conf  # Omarchy defaults
source = ~/.config/omarchy/current/theme/hyprland.conf       # Current theme
source = ~/.config/hypr/monitors.conf                        # User overrides
```

This cascading approach allows:
- Omarchy provides sane defaults
- Themes override colors/aesthetics
- User configs override everything

---

## Proposed Structure

```
.files/
├── scripts/
│   └── omarchy/
│       ├── README.md                    # Complete documentation
│       ├── install.sh                   # Main entry point
│       │
│       ├── helpers/
│       │   ├── all.sh                  # Source all helpers
│       │   ├── logging.sh              # Logging utilities
│       │   ├── detection.sh            # System detection
│       │   ├── symlink.sh              # Symlink management
│       │   └── backup.sh               # Backup utilities
│       │
│       ├── preflight/
│       │   ├── all.sh                  # Preflight orchestrator
│       │   ├── check-omarchy.sh        # Verify Omarchy install
│       │   ├── check-deps.sh           # Check dependencies
│       │   └── confirm.sh              # User confirmation
│       │
│       ├── packages/
│       │   ├── all.sh                  # Package orchestrator
│       │   ├── uninstall-defaults.sh   # Remove unwanted packages
│       │   ├── install-custom.sh       # Install custom packages
│       │   ├── unwanted.list           # Packages to remove
│       │   └── custom.list             # Packages to install
│       │
│       ├── config/
│       │   ├── all.sh                  # Config orchestrator
│       │   ├── hypr.sh                 # Hyprland configuration
│       │   ├── zsh.sh                  # Zsh configuration
│       │   ├── alacritty.sh            # Alacritty configuration
│       │   ├── ghostty.sh              # Ghostty configuration
│       │   ├── nvim.sh                 # Neovim configuration
│       │   ├── git.sh                  # Git configuration
│       │   ├── starship.sh             # Starship prompt
│       │   ├── zellij.sh               # Zellij multiplexer
│       │   ├── bat.sh                  # Bat configuration
│       │   └── delta.sh                # Delta git diff
│       │
│       ├── themes/
│       │   ├── all.sh                  # Theme orchestrator
│       │   ├── integrate.sh            # Integrate with Omarchy
│       │   └── custom.sh               # Add custom themes
│       │
│       └── post-install/
│           ├── all.sh                  # Post-install orchestrator
│           ├── verify.sh               # Verify installation
│           └── summary.sh              # Display summary
```

---

## Detailed Implementation Plan

### Phase 1: Foundation & Helpers

#### 1.1 Create Helper Scripts

**`helpers/all.sh`**
```bash
#!/usr/bin/env bash
# Source all helper scripts

HELPERS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$HELPERS_DIR/logging.sh"
source "$HELPERS_DIR/detection.sh"
source "$HELPERS_DIR/symlink.sh"
source "$HELPERS_DIR/backup.sh"
```

**`helpers/logging.sh`**
```bash
#!/usr/bin/env bash
# Logging utilities following Omarchy patterns

DOTFILES_LOG_DIR="$HOME/.local/state/dotfiles"
DOTFILES_LOG_FILE="$DOTFILES_LOG_DIR/omarchy-patches.log"

# Initialize logging
init_logging() {
    mkdir -p "$DOTFILES_LOG_DIR"
    touch "$DOTFILES_LOG_FILE"
}

# Log functions with timestamps
log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $*" | tee -a "$DOTFILES_LOG_FILE"
}

log_success() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $*" | tee -a "$DOTFILES_LOG_FILE"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $*" | tee -a "$DOTFILES_LOG_FILE" >&2
}

log_warn() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $*" | tee -a "$DOTFILES_LOG_FILE"
}

# Run command with logging
run_logged() {
    local description="$1"
    shift
    
    log_info "Starting: $description"
    
    if "$@" >> "$DOTFILES_LOG_FILE" 2>&1; then
        log_success "Completed: $description"
        return 0
    else
        log_error "Failed: $description"
        return 1
    fi
}
```

**`helpers/detection.sh`**
```bash
#!/usr/bin/env bash
# System and application detection

# Check if running on Omarchy
is_omarchy() {
    [[ -f /etc/omarchy-release ]] || \
    [[ -d ~/.local/share/omarchy ]]
}

# Check if package is installed
has_package() {
    pacman -Q "$1" &>/dev/null
}

# Check if config directory exists
has_config() {
    [[ -d "$1" ]]
}

# Check if command is available
has_command() {
    command -v "$1" &>/dev/null
}

# Check if systemd service is enabled
is_service_enabled() {
    systemctl is-enabled "$1" &>/dev/null
}

# Get Omarchy version
get_omarchy_version() {
    if [[ -f /etc/omarchy-release ]]; then
        cat /etc/omarchy-release
    else
        echo "unknown"
    fi
}
```

**`helpers/symlink.sh`**
```bash
#!/usr/bin/env bash
# Symlink management utilities

# Create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Check if source exists
    if [[ ! -e "$source" ]]; then
        log_error "Source does not exist: $source"
        return 1
    fi
    
    # Backup existing target
    if [[ -e "$target" ]]; then
        backup_file "$target"
    fi
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$target")"
    
    # Create symlink
    ln -snf "$source" "$target"
    log_info "Created symlink: $target -> $source"
}

# Remove symlink safely
remove_symlink() {
    local target="$1"
    
    if [[ -L "$target" ]]; then
        rm "$target"
        log_info "Removed symlink: $target"
        return 0
    elif [[ -e "$target" ]]; then
        log_warn "Not a symlink, skipping: $target"
        return 1
    fi
}

# Check if symlink points to expected target
verify_symlink() {
    local target="$1"
    local expected_source="$2"
    
    if [[ -L "$target" ]]; then
        local actual_source
        actual_source=$(readlink -f "$target")
        expected_source=$(readlink -f "$expected_source")
        
        if [[ "$actual_source" == "$expected_source" ]]; then
            return 0
        fi
    fi
    return 1
}
```

**`helpers/backup.sh`**
```bash
#!/usr/bin/env bash
# Backup utilities

BACKUP_DIR="$HOME/.local/state/dotfiles/backups"

# Initialize backup directory
init_backup() {
    mkdir -p "$BACKUP_DIR"
}

# Backup a file or directory
backup_file() {
    local target="$1"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    
    if [[ -e "$target" ]]; then
        local backup_name
        backup_name="$(basename "$target").backup_$timestamp"
        local backup_path="$BACKUP_DIR/$backup_name"
        
        cp -r "$target" "$backup_path"
        log_info "Backed up: $target -> $backup_path"
    fi
}

# Restore from backup
restore_backup() {
    local backup_path="$1"
    local target="$2"
    
    if [[ -e "$backup_path" ]]; then
        rm -rf "$target"
        cp -r "$backup_path" "$target"
        log_success "Restored: $target from backup"
    else
        log_error "Backup not found: $backup_path"
        return 1
    fi
}

# List available backups
list_backups() {
    ls -lh "$BACKUP_DIR"
}
```

#### 1.2 Create Main Entry Point

**`install.sh`**
```bash
#!/usr/bin/env bash
# Main entry point for Omarchy dotfiles patches
# Usage: ./install.sh [--dry-run] [--force]

set -eEuo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Options
DRY_RUN=false
FORCE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        -h|--help)
            cat <<EOF
Usage: $0 [OPTIONS]

Apply custom dotfiles patches to Omarchy installation.

OPTIONS:
    --dry-run    Show what would be done without making changes
    --force      Skip confirmations
    -h, --help   Show this help message

EXAMPLES:
    $0                  # Normal installation with confirmations
    $0 --dry-run        # Preview changes
    $0 --force          # Install without prompts

EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

export DRY_RUN FORCE DOTFILES_ROOT

# Source helpers
source "$SCRIPT_DIR/helpers/all.sh"

# Initialize
init_logging
init_backup

log_info "=== Omarchy Dotfiles Patches ==="
log_info "Started at $(date)"
log_info "Dotfiles root: $DOTFILES_ROOT"
log_info "Dry run: $DRY_RUN"

# Run phases
run_logged "Preflight checks" "$SCRIPT_DIR/preflight/all.sh"
run_logged "Package management" "$SCRIPT_DIR/packages/all.sh"
run_logged "Configuration patches" "$SCRIPT_DIR/config/all.sh"
run_logged "Theme integration" "$SCRIPT_DIR/themes/all.sh"
run_logged "Post-install tasks" "$SCRIPT_DIR/post-install/all.sh"

log_success "=== Patches Applied Successfully ==="
log_info "Finished at $(date)"
log_info "Log file: $DOTFILES_LOG_FILE"
```

---

### Phase 2: Preflight Checks

**`preflight/all.sh`**
```bash
#!/usr/bin/env bash
# Orchestrate preflight checks

PREFLIGHT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$PREFLIGHT_DIR/check-omarchy.sh"
source "$PREFLIGHT_DIR/check-deps.sh"
source "$PREFLIGHT_DIR/confirm.sh"
```

**`preflight/check-omarchy.sh`**
```bash
#!/usr/bin/env bash
# Verify Omarchy installation

if ! is_omarchy; then
    log_error "Not running on Omarchy"
    log_error "These patches are designed for Omarchy Linux"
    exit 1
fi

log_success "Omarchy detected (version: $(get_omarchy_version))"
```

**`preflight/check-deps.sh`**
```bash
#!/usr/bin/env bash
# Check required dependencies

REQUIRED_COMMANDS=(git stow)

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! has_command "$cmd"; then
        log_error "Required command not found: $cmd"
        exit 1
    fi
done

log_success "All required dependencies found"
```

**`preflight/confirm.sh`**
```bash
#!/usr/bin/env bash
# User confirmation

if [[ "$FORCE" == "true" ]]; then
    log_info "Force mode: skipping confirmation"
    exit 0
fi

cat <<EOF

This script will:
  • Remove unwanted default packages
  • Install custom packages
  • Apply configuration patches
  • Integrate custom themes

Backups will be created in: $BACKUP_DIR

EOF

read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Aborted by user"
    exit 0
fi
```

---

### Phase 3: Package Management

**`packages/all.sh`**
```bash
#!/usr/bin/env bash
# Orchestrate package operations

PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$PACKAGES_DIR/uninstall-defaults.sh"
bash "$PACKAGES_DIR/install-custom.sh"
```

**`packages/unwanted.list`**
```text
# Unwanted Omarchy Default Packages
# Lines starting with # are comments
# Add packages you want to remove (one per line)

# Example: If you prefer ghostty/alacritty over kitty
# kitty

# Add your unwanted packages below:
```

**`packages/custom.list`**
```text
# Custom Packages to Install
# Lines starting with # are comments
# Add packages you want installed (one per line)

# Development tools
fzf
ripgrep
eza
fd
bat
delta

# Add your custom packages below:
```

**`packages/uninstall-defaults.sh`**
```bash
#!/usr/bin/env bash
# Remove unwanted Omarchy default packages

PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNWANTED_LIST="$PACKAGES_DIR/unwanted.list"

if [[ ! -f "$UNWANTED_LIST" ]]; then
    log_warn "No unwanted packages list found"
    exit 0
fi

# Read unwanted packages (skip comments and empty lines)
mapfile -t UNWANTED < <(grep -v '^#' "$UNWANTED_LIST" | grep -v '^$')

if [[ ${#UNWANTED[@]} -eq 0 ]]; then
    log_info "No unwanted packages to remove"
    exit 0
fi

log_info "Packages to remove: ${UNWANTED[*]}"

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would remove packages"
    exit 0
fi

# Remove packages
for pkg in "${UNWANTED[@]}"; do
    if has_package "$pkg"; then
        log_info "Removing package: $pkg"
        sudo pacman -R --noconfirm "$pkg" || log_warn "Failed to remove: $pkg"
    else
        log_info "Package not installed: $pkg"
    fi
done

log_success "Package removal completed"
```

**`packages/install-custom.sh`**
```bash
#!/usr/bin/env bash
# Install custom packages

PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CUSTOM_LIST="$PACKAGES_DIR/custom.list"

if [[ ! -f "$CUSTOM_LIST" ]]; then
    log_warn "No custom packages list found"
    exit 0
fi

# Read custom packages (skip comments and empty lines)
mapfile -t CUSTOM < <(grep -v '^#' "$CUSTOM_LIST" | grep -v '^$')

if [[ ${#CUSTOM[@]} -eq 0 ]]; then
    log_info "No custom packages to install"
    exit 0
fi

log_info "Packages to install: ${CUSTOM[*]}"

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would install packages"
    exit 0
fi

# Install packages
sudo pacman -S --noconfirm --needed "${CUSTOM[@]}" || log_error "Package installation failed"

log_success "Package installation completed"
```

---

### Phase 4: Configuration Patches

**`config/all.sh`**
```bash
#!/usr/bin/env bash
# Orchestrate all configuration patches

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run each config patch
for script in "$CONFIG_DIR"/*.sh; do
    # Skip all.sh itself
    [[ "$(basename "$script")" == "all.sh" ]] && continue
    
    log_info "Running: $(basename "$script")"
    bash "$script"
done
```

**`config/hypr.sh`**
```bash
#!/usr/bin/env bash
# Hyprland configuration patches

log_info "Applying Hyprland patches..."

SOURCE_DIR="$DOTFILES_ROOT/hypr/.config/hypr"
TARGET_DIR="$HOME/.config/hypr"

if [[ ! -d "$SOURCE_DIR" ]]; then
    log_error "Hypr dotfiles not found: $SOURCE_DIR"
    exit 1
fi

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would symlink Hyprland configs"
    exit 0
fi

# Ensure target directory exists
mkdir -p "$TARGET_DIR"

# Symlink individual config files (preserve Omarchy's hyprland.conf structure)
for conf in monitors.conf input.conf bindings.conf envs.conf looknfeel.conf \
            autostart.conf utilities.conf workspaces.conf hypridle.conf \
            hyprlock.conf hyprsunset.conf; do
    if [[ -f "$SOURCE_DIR/$conf" ]]; then
        create_symlink "$SOURCE_DIR/$conf" "$TARGET_DIR/$conf"
    fi
done

# Symlink scripts directory
if [[ -d "$SOURCE_DIR/scripts" ]]; then
    create_symlink "$SOURCE_DIR/scripts" "$TARGET_DIR/scripts"
fi

log_success "Hyprland patches applied"
```

**`config/zsh.sh`**
```bash
#!/usr/bin/env bash
# Zsh configuration patches

log_info "Applying Zsh patches..."

SOURCE_DIR="$DOTFILES_ROOT/zsh/.config/zsh"
TARGET_DIR="$HOME/.config/zsh"
ZSHRC_SOURCE="$DOTFILES_ROOT/zsh/.zshrc"
ZSHRC_TARGET="$HOME/.zshrc"

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would symlink Zsh configs"
    exit 0
fi

# Symlink zsh config directory
create_symlink "$SOURCE_DIR" "$TARGET_DIR"

# Handle .zshrc - source from custom location
if [[ -f "$ZSHRC_SOURCE" ]]; then
    if ! grep -q "source $TARGET_DIR" "$ZSHRC_TARGET" 2>/dev/null; then
        backup_file "$ZSHRC_TARGET"
        cat >> "$ZSHRC_TARGET" <<EOF

# Custom dotfiles integration
[[ -f "$TARGET_DIR/env.zsh" ]] && source "$TARGET_DIR/env.zsh"
[[ -f "$TARGET_DIR/aliases.zsh" ]] && source "$TARGET_DIR/aliases.zsh"
[[ -f "$TARGET_DIR/plugins.zsh" ]] && source "$TARGET_DIR/plugins.zsh"
[[ -f "$TARGET_DIR/completions.zsh" ]] && source "$TARGET_DIR/completions.zsh"
[[ -f "$TARGET_DIR/history.zsh" ]] && source "$TARGET_DIR/history.zsh"
[[ -f "$TARGET_DIR/Keybindings.zsh" ]] && source "$TARGET_DIR/Keybindings.zsh"
EOF
    fi
fi

log_success "Zsh patches applied"
```

**`config/alacritty.sh`**
```bash
#!/usr/bin/env bash
# Alacritty configuration patches

log_info "Applying Alacritty patches..."

SOURCE_DIR="$DOTFILES_ROOT/alacritty/.config/alacritty"
TARGET_DIR="$HOME/.config/alacritty"

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would symlink Alacritty configs"
    exit 0
fi

create_symlink "$SOURCE_DIR" "$TARGET_DIR"

log_success "Alacritty patches applied"
```

**`config/ghostty.sh`**
```bash
#!/usr/bin/env bash
# Ghostty configuration patches

log_info "Applying Ghostty patches..."

SOURCE_DIR="$DOTFILES_ROOT/ghostty/.config/ghostty"
TARGET_DIR="$HOME/.config/ghostty"

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would symlink Ghostty configs"
    exit 0
fi

create_symlink "$SOURCE_DIR" "$TARGET_DIR"

log_success "Ghostty patches applied"
```

**`config/nvim.sh`**
```bash
#!/usr/bin/env bash
# Neovim configuration patches

log_info "Applying Neovim patches..."

SOURCE_DIR="$DOTFILES_ROOT/nvim/.config/nvim"
TARGET_DIR="$HOME/.config/nvim"

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would symlink Neovim configs"
    exit 0
fi

create_symlink "$SOURCE_DIR" "$TARGET_DIR"

log_success "Neovim patches applied"
```

**`config/git.sh`**
```bash
#!/usr/bin/env bash
# Git configuration patches

log_info "Applying Git patches..."

SOURCE_FILE="$DOTFILES_ROOT/git/.gitconfig"
TARGET_FILE="$HOME/.gitconfig"

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would symlink Git config"
    exit 0
fi

create_symlink "$SOURCE_FILE" "$TARGET_FILE"

# Symlink global gitignore
if [[ -f "$DOTFILES_ROOT/git/.gitignore_global" ]]; then
    create_symlink "$DOTFILES_ROOT/git/.gitignore_global" "$HOME/.gitignore_global"
fi

log_success "Git patches applied"
```

**`config/starship.sh`**
```bash
#!/usr/bin/env bash
# Starship prompt patches

log_info "Applying Starship patches..."

SOURCE_FILE="$DOTFILES_ROOT/starship/starship.toml"
TARGET_DIR="$HOME/.config"

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would symlink Starship config"
    exit 0
fi

create_symlink "$SOURCE_FILE" "$TARGET_DIR/starship.toml"

log_success "Starship patches applied"
```

**`config/zellij.sh`**
```bash
#!/usr/bin/env bash
# Zellij configuration patches

log_info "Applying Zellij patches..."

SOURCE_DIR="$DOTFILES_ROOT/zellij/.config/zellij"
TARGET_DIR="$HOME/.config/zellij"

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would symlink Zellij configs"
    exit 0
fi

create_symlink "$SOURCE_DIR" "$TARGET_DIR"

log_success "Zellij patches applied"
```

**`config/bat.sh`**
```bash
#!/usr/bin/env bash
# Bat configuration patches

log_info "Applying Bat patches..."

SOURCE_DIR="$DOTFILES_ROOT/bat/.config/bat"
TARGET_DIR="$HOME/.config/bat"

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would symlink Bat configs"
    exit 0
fi

create_symlink "$SOURCE_DIR" "$TARGET_DIR"

# Rebuild bat cache for themes
if has_command bat; then
    bat cache --build
fi

log_success "Bat patches applied"
```

**`config/delta.sh`**
```bash
#!/usr/bin/env bash
# Delta (git diff) configuration patches

log_info "Applying Delta patches..."

SOURCE_DIR="$DOTFILES_ROOT/delta/.config/delta"
TARGET_DIR="$HOME/.config/delta"

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would symlink Delta configs"
    exit 0
fi

create_symlink "$SOURCE_DIR" "$TARGET_DIR"

log_success "Delta patches applied"
```

---

### Phase 5: Theme Integration

**`themes/all.sh`**
```bash
#!/usr/bin/env bash
# Orchestrate theme integration

THEMES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$THEMES_DIR/integrate.sh"
bash "$THEMES_DIR/custom.sh"
```

**`themes/integrate.sh`**
```bash
#!/usr/bin/env bash
# Integrate custom themes with Omarchy's theme system

log_info "Integrating themes with Omarchy..."

OMARCHY_THEMES_DIR="$HOME/.config/omarchy/themes"

if [[ ! -d "$OMARCHY_THEMES_DIR" ]]; then
    log_warn "Omarchy themes directory not found, creating..."
    mkdir -p "$OMARCHY_THEMES_DIR"
fi

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would integrate themes"
    exit 0
fi

# TODO: Add theme integration logic based on user's custom themes
# This will be customized after user provides their theme preferences

log_success "Theme integration completed"
```

**`themes/custom.sh`**
```bash
#!/usr/bin/env bash
# Add custom themes

log_info "Adding custom themes..."

# TODO: Implement custom theme addition
# This will be customized based on user's requirements

log_info "Custom themes ready"
```

---

### Phase 6: Post-Install

**`post-install/all.sh`**
```bash
#!/usr/bin/env bash
# Post-install orchestration

POST_INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$POST_INSTALL_DIR/verify.sh"
bash "$POST_INSTALL_DIR/summary.sh"
```

**`post-install/verify.sh`**
```bash
#!/usr/bin/env bash
# Verify installation

log_info "Verifying installation..."

ERRORS=0

# Verify critical symlinks
CRITICAL_LINKS=(
    "$HOME/.config/hypr"
    "$HOME/.config/zsh"
    "$HOME/.config/nvim"
)

for link in "${CRITICAL_LINKS[@]}"; do
    if [[ ! -e "$link" ]]; then
        log_error "Missing: $link"
        ((ERRORS++))
    fi
done

if [[ $ERRORS -gt 0 ]]; then
    log_error "Verification failed with $ERRORS errors"
    exit 1
fi

log_success "Verification passed"
```

**`post-install/summary.sh`**
```bash
#!/usr/bin/env bash
# Display installation summary

cat <<EOF

╔═══════════════════════════════════════════════════════════╗
║         Omarchy Dotfiles Patches - Installation           ║
║                      Complete! ✓                          ║
╚═══════════════════════════════════════════════════════════╝

📁 Configurations Applied:
   ✓ Hyprland
   ✓ Zsh
   ✓ Alacritty
   ✓ Ghostty
   ✓ Neovim
   ✓ Git
   ✓ Starship
   ✓ Zellij
   ✓ Bat
   ✓ Delta

📝 Log file: $DOTFILES_LOG_FILE
💾 Backups: $BACKUP_DIR

🔄 Next Steps:
   1. Restart your shell or run: exec zsh
   2. Restart Hyprland or re-login
   3. Verify configs work as expected

📚 Documentation: $SCRIPT_DIR/README.md

EOF
```

---

## Patterns and Best Practices

### Following Omarchy's Patterns

1. **Directory Structure:**
   - Mirror Omarchy's `install/` structure
   - Use `all.sh` orchestrators in each directory
   - Separate concerns: helpers, preflight, packages, config, themes, post-install

2. **Script Organization:**
   - Each script does ONE thing
   - Use functions for reusability
   - Follow POSIX conventions where possible

3. **Error Handling:**
   - Use `set -eEuo pipefail`
   - Log all operations
   - Provide meaningful error messages
   - Exit codes: 0=success, 1=error

4. **Idempotency:**
   - Scripts can be run multiple times safely
   - Check before creating (symlinks, directories)
   - Use `ln -snf` for force-symlink updates
   - Don't fail if already configured

5. **Logging:**
   - Log to centralized log file
   - Include timestamps
   - Different levels: INFO, SUCCESS, ERROR, WARN
   - Use `run_logged()` for script execution

6. **User Experience:**
   - Show progress messages
   - Provide dry-run mode
   - Confirm destructive operations
   - Display helpful summary at end

### Shell Scripting Best Practices (from AGENTS.md)

1. **Shebang:** `#!/usr/bin/env bash` (or `/usr/bin/env sh` for POSIX)
2. **Variables:** Lowercase with underscores (`log_file`, `backup_dir`)
3. **Quoting:** Always quote variables: `"$variable"`
4. **Functions:** Clear names, single responsibility
5. **Comments:** Explain WHY, not WHAT
6. **Indentation:** 4 spaces for shell scripts

### Conditional Patterns

```bash
# Hardware detection pattern (from Omarchy)
if lspci | grep -q "hardware-id"; then
    echo "Detected hardware, applying fix..."
    # ... configuration
fi

# Package check pattern
if has_package "package-name"; then
    # ... action
fi

# Config existence check
if has_config "$HOME/.config/app"; then
    # ... action
fi
```

---

## Safety and Rollback

### Backup Strategy

1. **Automatic Backups:**
   - All existing configs backed up before modification
   - Timestamped: `config.backup_20251207_123456`
   - Stored in: `~/.local/state/dotfiles/backups/`

2. **Manual Backup:**
   ```bash
   # Before running patches
   ./scripts/omarchy/helpers/backup.sh $HOME/.config/hypr
   ```

3. **List Backups:**
   ```bash
   ls -lh ~/.local/state/dotfiles/backups/
   ```

### Rollback Procedure

If something goes wrong:

```bash
# 1. Check the log
tail -f ~/.local/state/dotfiles/omarchy-patches.log

# 2. Identify problematic config
# Example: Hyprland config issue

# 3. Remove symlink
rm ~/.config/hypr

# 4. Restore from backup
cp -r ~/.local/state/dotfiles/backups/hypr.backup_TIMESTAMP ~/.config/hypr

# 5. Re-login or restart service
```

### Dry Run Mode

Always test with dry run first:

```bash
./scripts/omarchy/install.sh --dry-run
```

This will:
- ✓ Run all checks
- ✓ Show what WOULD be done
- ✗ NOT make any changes
- ✓ Output to log for review

---

## Questions for User

Before implementing, please provide answers to these questions:

### 1. Package Management

**Which Omarchy default packages do you want to REMOVE?**

Categories to consider:
- [ ] Terminal emulators (kitty, foot, etc.)
- [ ] Text editors (specific ones?)
- [ ] Browsers (firefox, chromium, etc.)
- [ ] File managers
- [ ] Media players
- [ ] Development tools
- [ ] System utilities
- [ ] Desktop applications

Please list specific packages you want removed.

**Which additional packages do you want to INSTALL?**

You already have some in your aliases (fzf, ripgrep, eza). List any others.

### 2. Configuration Strategy

For applications where Omarchy already has configs (like Hyprland):

**Preferred approach:**
- [ ] **Option A (Recommended):** Keep Omarchy's structure, layer customizations on top
  - Preserve Omarchy's default sourcing
  - Add your custom overrides
  - Benefit from Omarchy updates
  
- [ ] **Option B:** Completely replace with your configs
  - Full control
  - Won't get Omarchy updates
  - Need to maintain all configs yourself

- [ ] **Option C:** Hybrid approach
  - Some apps use Omarchy defaults (e.g., hyprlock, hypridle)
  - Others fully custom (e.g., zsh, nvim)

### 3. Theme Integration

Your `omarchy_backup/` has themes. What do you want?

- [ ] Integrate existing themes with Omarchy's theme switcher
- [ ] Keep themes separate from Omarchy
- [ ] Use only Omarchy's default themes
- [ ] Create new custom themes from scratch

**Do you want to:**
- [ ] Keep using Omarchy's theme switcher GUI?
- [ ] Switch themes manually?
- [ ] Have a CLI theme switcher?

### 4. Stow Integration

How should the patch scripts work with stow?

- [ ] **Independent (Recommended):** Scripts and stow work together
  - Stow manages dotfiles
  - Scripts create patches/symlinks
  
- [ ] **Replace stow:** Scripts handle everything
  - No more stow usage
  - All management via scripts

- [ ] **Stow only:** Keep using stow, minimal scripts

### 5. Installation Timing

When should patches run?

- [ ] **Manual:** Run `./scripts/omarchy/install.sh` when you want
- [ ] **On fresh install:** Part of initial Omarchy setup
- [ ] **On login:** Automatic via systemd service or .zshrc
- [ ] **On update:** When dotfiles repo is updated (git pull hook)

### 6. Customization Priorities

Rank your top 5 applications by importance (1=most important):

- [ ] Hyprland (window manager)
- [ ] Zsh (shell)
- [ ] Neovim (editor)
- [ ] Terminal (ghostty/alacritty)
- [ ] Git
- [ ] Starship (prompt)
- [ ] Zellij (multiplexer)
- [ ] Bat (cat replacement)
- [ ] Others: _______________

### 7. Special Requirements

**Do you need:**
- [ ] Multi-machine support (different configs per machine)?
- [ ] Private config management (secrets, emails)?
- [ ] Theme auto-switching (time-based, dark/light)?
- [ ] Hardware-specific patches (similar to Omarchy's hardware/ dir)?
- [ ] Migration scripts for updates?

### 8. Development Workflow

**How do you update your dotfiles?**
- [ ] Edit directly in `~/.files/` repo
- [ ] Test changes, then commit
- [ ] Pull from remote regularly
- [ ] Multiple branches for experiments

**Should scripts support:**
- [ ] Dev mode (edit configs in place, see changes immediately)?
- [ ] Staging (test configs before applying)?
- [ ] Profiles (work, personal, minimal, etc.)?

---

## Recommended Next Steps

After answering the questions above:

1. **Review and Adjust Plan:**
   - Customize based on your answers
   - Remove unnecessary components
   - Add specialized scripts if needed

2. **Implementation Order:**
   - Phase 1: Helpers & foundation (universal utilities)
   - Phase 2: Preflight (ensures safety)
   - Phase 3: Your top 3 priority apps (test with real usage)
   - Phase 4: Remaining apps
   - Phase 5: Themes
   - Phase 6: Polish & documentation

3. **Testing Strategy:**
   - Use `--dry-run` for all initial runs
   - Test one config at a time
   - Keep backup of working system
   - Document any issues encountered

4. **Documentation:**
   - Update README.md with usage instructions
   - Add troubleshooting section
   - Document customization points
   - Create CONTRIBUTING.md if sharing publicly

---

## Additional Resources

- **Omarchy Repository:** https://github.com/basecamp/omarchy
- **Omarchy Docs:** https://omarchy.org
- **Your Dotfiles:** `/home/mombe090/.files/`
- **This Plan:** `/home/mombe090/.files/agents/plan/omarchy/dotfiles-evolution-plan.md`

---

**Plan Version:** 1.0  
**Last Updated:** December 7, 2025  
**Status:** Awaiting user input for implementation
