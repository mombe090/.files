# Omarchy Patching Strategy - Injection Approach

**Date:** December 7, 2025
**Strategy:** Source injection instead of symlinks
**Principle:** Idempotent, non-destructive configuration patching

---

## Core Concept

Instead of symlinking entire config directories, we:

1. **Create custom config files** in your dotfiles
2. **Inject source statements** into Omarchy's existing configs
3. **Make it idempotent** - safe to run multiple times
4. **Preserve Omarchy's structure** - layer on top, don't replace

---

## Example: Hyprland Monitor Configuration

### Current Omarchy Structure

```bash
~/.config/hypr/hyprland.conf
# Contains:
source = ~/.local/share/omarchy/default/hypr/autostart.conf
source = ~/.local/share/omarchy/default/hypr/bindings/media.conf
# ... other omarchy defaults
source = ~/.config/hypr/monitors.conf  # User overrides
```

### Your Dotfiles Structure

```
.files/
└── hypr/
    └── .config/
        └── hypr/
            └── custom/
                ├── monitors_custom.conf
                ├── bindings_custom.conf
                ├── workspaces_custom.conf
                └── autostart_custom.conf
```

### What the Patch Script Does

1. **Copy custom configs** to `~/.config/hypr/custom/`
2. **Inject source line** at the end of `~/.config/hypr/hyprland.conf`:
   ```bash
   # Custom dotfiles overrides
   source = ~/.config/hypr/custom/monitors_custom.conf
   source = ~/.config/hypr/custom/bindings_custom.conf
   source = ~/.config/hypr/custom/workspaces_custom.conf
   source = ~/.config/hypr/custom/autostart_custom.conf
   ```
3. **Check if already present** - don't duplicate lines

### Benefits

✅ **Non-destructive** - Original Omarchy configs untouched
✅ **Idempotent** - Safe to run multiple times
✅ **Updatable** - Edit files in dotfiles, re-run patch
✅ **Omarchy-compatible** - Benefit from Omarchy updates
✅ **Clear separation** - Your customizations in `custom/` directory

---

## Implementation Pattern

### Helper Function: Idempotent Source Injection

```bash
inject_source() {
    local config_file="$1"
    local source_line="$2"
    local marker="$3"  # Optional: comment marker to identify our additions

    # Check if source line already exists
    if grep -Fxq "$source_line" "$config_file" 2>/dev/null; then
        log_info "Source already present: $source_line"
        return 0
    fi

    # Backup original
    backup_file "$config_file"

    # Add marker comment if provided
    if [[ -n "$marker" ]]; then
        if ! grep -q "$marker" "$config_file" 2>/dev/null; then
            echo "" >> "$config_file"
            echo "$marker" >> "$config_file"
        fi
    fi

    # Inject source line
    echo "$source_line" >> "$config_file"
    log_success "Injected: $source_line"
}
```

### Usage Example: Hyprland Patch

```bash
#!/usr/bin/env bash
# config/hypr.sh - Hyprland configuration patch

log_info "Applying Hyprland patches..."

DOTFILES_HYPR="$DOTFILES_ROOT/hypr/.config/hypr"
TARGET_HYPR="$HOME/.config/hypr"
CUSTOM_DIR="$TARGET_HYPR/custom"

# Create custom directory
mkdir -p "$CUSTOM_DIR"

# Copy custom configs from dotfiles
for conf in monitors_custom.conf bindings_custom.conf workspaces_custom.conf; do
    if [[ -f "$DOTFILES_HYPR/$conf" ]]; then
        cp "$DOTFILES_HYPR/$conf" "$CUSTOM_DIR/$conf"
        log_info "Copied: $conf"
    fi
done

# Inject source lines idempotently
MARKER="# === Custom Dotfiles Overrides ==="
inject_source "$TARGET_HYPR/hyprland.conf" "$MARKER"

for conf in monitors_custom.conf bindings_custom.conf workspaces_custom.conf; do
    if [[ -f "$CUSTOM_DIR/$conf" ]]; then
        SOURCE_LINE="source = $CUSTOM_DIR/$conf"
        inject_source "$TARGET_HYPR/hyprland.conf" "$SOURCE_LINE"
    fi
done

log_success "Hyprland patches applied"
```

---

## Directory Structure per Application

### Hyprland

```
~/.config/hypr/
├── hyprland.conf              # Omarchy's main config (we inject into this)
├── monitors.conf              # Omarchy user overrides (untouched)
├── input.conf                 # Omarchy user overrides (untouched)
└── custom/                    # Our custom additions
    ├── monitors_custom.conf
    ├── bindings_custom.conf
    ├── workspaces_custom.conf
    └── autostart_custom.conf
```

### Zsh

```
~/.zshrc                       # Omarchy's zshrc (we inject into this)
~/.config/zsh/                 # Omarchy's zsh configs
~/.config/zsh/custom/          # Our custom additions
    ├── aliases_custom.zsh
    ├── functions_custom.zsh
    ├── completions_custom.zsh
    └── env_custom.zsh
```

### Git

```
~/.gitconfig                   # We append our custom sections
~/.config/git/                 # Additional git configs
    └── custom/
        ├── aliases_custom.conf
        └── delta_custom.conf
```

### Alacritty

```
~/.config/alacritty/
├── alacritty.toml             # Omarchy's config (we inject into this)
└── custom/
    └── overrides.toml         # Our customizations
```

---

## Pattern for Each App

### 1. Create Custom Directory

```bash
mkdir -p "$HOME/.config/<app>/custom"
```

### 2. Copy Custom Configs from Dotfiles

```bash
cp "$DOTFILES_ROOT/<app>/.config/<app>/custom_file.conf" \
   "$HOME/.config/<app>/custom/custom_file.conf"
```

### 3. Inject Source Line

```bash
inject_source "$HOME/.config/<app>/main.conf" \
              "source = ~/.config/<app>/custom/custom_file.conf"
```

### 4. Make Idempotent

- Check if source line exists before adding
- Use markers to identify our additions
- Backup before modification

---

## Advantages Over Symlinks

| Aspect | Symlinks | Injection |
|--------|----------|-----------|
| **Omarchy Updates** | Conflicts possible | No conflicts |
| **Partial Overrides** | All or nothing | Granular control |
| **Debugging** | Hidden in links | Clear file structure |
| **Stow Compatibility** | Complex | Simple |
| **Rollback** | Remove link | Remove source line |
| **Transparency** | Less visible | Very visible |

---

## Implementation Checklist

### Helper Functions Needed

- [x] `inject_source()` - Idempotent source injection
- [x] `backup_file()` - Already planned
- [x] `log_*()` - Already planned
- [ ] `remove_source()` - For uninstall/rollback
- [ ] `verify_injection()` - Verify source lines work

### Per-App Patches

Each app patch script should:

1. ✅ Create `custom/` directory structure
2. ✅ Copy custom configs from dotfiles
3. ✅ Inject source lines idempotently
4. ✅ Verify configs are valid
5. ✅ Log all operations

---

## Example Implementation

### Dotfiles Structure

```
.files/
├── hypr/
│   └── .config/
│       └── hypr/
│           ├── monitors_custom.conf
│           ├── bindings_custom.conf
│           └── workspaces_custom.conf
│
├── zsh/
│   └── .config/
│       └── zsh/
│           └── custom/
│               ├── aliases_custom.zsh
│               └── functions_custom.zsh
│
└── scripts/
    └── omarchy/
        ├── helpers/
        │   └── inject.sh          # inject_source() function
        └── config/
            ├── hypr.sh            # Hyprland patches
            └── zsh.sh             # Zsh patches
```

### Hyprland Custom Config Example

**File:** `.files/hypr/.config/hypr/monitors_custom.conf`

```bash
# Custom monitor configuration
# This file is sourced by hyprland.conf via patch script

monitor=DP-1,2560x1440@144,0x0,1
monitor=HDMI-A-1,1920x1080@60,2560x0,1

workspace=1,monitor:DP-1
workspace=2,monitor:DP-1
workspace=3,monitor:HDMI-A-1
```

### After Patch Runs

**File:** `~/.config/hypr/hyprland.conf` (末尾に追加)

```bash
# ... existing Omarchy configs ...

# === Custom Dotfiles Overrides ===
source = ~/.config/hypr/custom/monitors_custom.conf
source = ~/.config/hypr/custom/bindings_custom.conf
source = ~/.config/hypr/custom/workspaces_custom.conf
```

---

## Rollback Strategy

### Remove Source Lines

```bash
remove_custom_sources() {
    local config_file="$1"
    local marker="# === Custom Dotfiles Overrides ==="

    # Backup before modification
    backup_file "$config_file"

    # Remove everything from marker to end
    sed -i "/$marker/,\$d" "$config_file"

    log_info "Removed custom sources from: $config_file"
}
```

### Or Remove Specific Line

```bash
remove_source() {
    local config_file="$1"
    local source_line="$2"

    backup_file "$config_file"
    grep -Fxv "$source_line" "$config_file" > "$config_file.tmp"
    mv "$config_file.tmp" "$config_file"

    log_info "Removed source: $source_line"
}
```

---

## Summary

This injection approach is:

✅ **Cleaner** - No symlink complexity
✅ **Safer** - Original configs preserved
✅ **Flexible** - Easy to add/remove patches
✅ **Transparent** - Clear what's being changed
✅ **Idempotent** - Run as many times as needed
✅ **Omarchy-friendly** - Works with their update system

This is the strategy we'll implement in the actual patch scripts!
