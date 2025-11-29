# Zellij Catppuccin Theme Implementation Plan

## Overview

Replace the default green status bar in Zellij with a cohesive Catppuccin Mocha theme that matches the existing terminal aesthetic.

## Current State

- **Config Location**: `~/.config/zellij/config.kdl`
- **Current Theme**: Default (no theme section defined)
- **Issue**: Green status bar doesn't match Catppuccin aesthetic
- **Target Theme**: Catppuccin Mocha (darker variant with better contrast)

## Catppuccin Mocha Color Palette

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| Base       | `#1E1E2E` | Background |
| Text       | `#CDD6F4` | Foreground text |
| Surface0   | `#313244` | Secondary background |
| Surface1   | `#45475A` | Tertiary background |
| Surface2   | `#585B70` | Quaternary background |
| Overlay0   | `#6C7086` | Overlay |
| Overlay1   | `#7F849C` | Overlay |
| Subtext0   | `#A6ADC8` | Muted text |
| Subtext1   | `#BAC2DE` | Muted text |
| Red        | `#F38BA8` | Error states |
| Green      | `#A6E3A1` | Success states |
| Yellow     | `#F9E2AF` | Warning states |
| Blue       | `#89B4FA` | Info states |
| Pink       | `#F5C2E7` | Accent |
| Teal       | `#94E2D5` | Accent |
| Peach      | `#FAB387` | Accent |
| Lavender   | `#B4BEFE` | Accent |

## Implementation Steps

### 1. Create Theme Section

Add a `themes` block to the config file (after line 273, where theme selection comment is):

```kdl
themes {
    catppuccin-mocha {
        fg "#CDD6F4"
        bg "#1E1E2E"
        black "#45475A"
        red "#F38BA8"
        green "#A6E3A1"
        yellow "#F9E2AF"
        blue "#89B4FA"
        magenta "#F5C2E7"
        cyan "#94E2D5"
        white "#BAC2DE"
        orange "#FAB387"
    }
}
```

### 2. Enable Theme

Uncomment and modify the theme line (around line 272):

```kdl
theme "catppuccin-mocha"
```

### 3. Expected Visual Changes

- **Status Bar**: Will use Surface0/Surface1 instead of bright green
- **Active Tab**: Blue (`#89B4FA`) highlight
- **Mode Indicators**: Color-coded by mode:
  - Normal: Green (`#A6E3A1`)
  - Locked: Red (`#F38BA8`)
  - Pane: Yellow (`#F9E2AF`)
  - Tab: Blue (`#89B4FA`)
  - Resize: Pink (`#F5C2E7`)
  - Move: Teal (`#94E2D5`)
  - Scroll/Search: Orange (`#FAB387`)
- **Text**: Consistent Catppuccin text color throughout (`#CDD6F4`)

### 4. Testing Checklist

- [ ] Restart Zellij session
- [ ] Verify status bar colors match theme
- [ ] Test different modes (Ctrl+p, Ctrl+t, Ctrl+n, etc.)
- [ ] Check tab colors when multiple tabs open
- [ ] Verify pane borders match theme
- [ ] Ensure text is readable in all contexts

## File Modifications

### Files to Edit

1. `/Users/mombe090/.files/zellij/.config/zellij/config.kdl`
   - Add `themes` section after line 273
   - Enable theme by uncommenting/modifying line 272

### Backup Strategy

- Zellij config is already in git repository
- Can revert via `git checkout` if needed
- Config is well-commented, easy to identify changes

## Additional Enhancements (Optional)

### Create Additional Variants

Could add other Catppuccin flavors for variety:

- `catppuccin-mocha` (darkest)
- `catppuccin-frappe` (dark)
- `catppuccin-latte` (light)

### Theme Directory

Could create separate theme files in:

```text
~/.config/zellij/themes/catppuccin-macchiato.kdl
```

Then reference via:

```kdl
theme_dir "~/.config/zellij/themes"
```

## References

- [Catppuccin Palette](https://github.com/catppuccin/catppuccin)
- [Zellij Theme Documentation](https://zellij.dev/documentation/themes)
- Existing implementations:
  - `/Users/mombe090/.files/alacritty/.config/alacritty/themes/catppuccin_mocha.toml`
  - `/Users/mombe090/.files/bat/.config/bat/themes/Catppuccin Mocha.tmTheme`

## Success Criteria

- ✅ Green status bar replaced with Catppuccin colors
- ✅ All UI elements use consistent color palette
- ✅ Theme matches Alacritty/terminal aesthetic
- ✅ All modes have distinct, readable colors
- ✅ Configuration is maintainable and documented
