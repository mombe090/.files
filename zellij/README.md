# Zellij Configuration

Modern terminal multiplexer with tmux-compatible keybindings.

## What is Zellij?

Zellij is a terminal workspace with batteries included. It's a modern alternative to tmux/screen with a user-friendly interface and plugin system.

## Features

- **Clear Keybindings**: tmux-compatible with vim-style navigation
- **Modes**: Pane, Tab, Resize, Move, Scroll, Search, Session
- **Plugins**: Session manager, plugin manager, file picker
- **Alt Key Navigation**: Quick pane/tab switching
- **Copy on Select**: Automatic clipboard integration

## Installation

```bash
stow zellij
```

## Key Modes

- `Ctrl+p` - Pane mode (create, navigate, close panes)
- `Ctrl+t` - Tab mode (create, rename, navigate tabs)
- `Ctrl+n` - Resize mode
- `Ctrl+h` - Move mode
- `Ctrl+s` - Scroll mode
- `Ctrl+o` - Session mode
- `Ctrl+g` - Lock mode

## Common Keybindings

### Panes

- `Ctrl+p n` - New pane
- `Ctrl+p d` - New pane below
- `Ctrl+p r` - New pane right
- `Ctrl+p hjkl` - Navigate panes
- `Ctrl+p f` - Fullscreen toggle
- `Ctrl+p x` - Close pane

### Tabs

- `Ctrl+t n` - New tab
- `Ctrl+t r` - Rename tab
- `Ctrl+t 1-9` - Go to tab 1-9
- `Ctrl+t hjkl` - Navigate tabs
- `Ctrl+t x` - Close tab

### Quick Navigation (Alt Keys)

- `Alt+hjkl` - Move focus
- `Alt+n` - New pane
- `Alt+f` - Toggle floating panes
- `Alt++-=` - Resize panes

## Usage

```bash
zellij                # Start new session
zellij attach         # Attach to session
zellij ls             # List sessions
```

Aliased as `zj` in zsh configuration.

## Plugins

- Session Manager (`Ctrl+o w`)
- Plugin Manager (`Ctrl+o p`)
- Configuration (`Ctrl+o c`)

## Customization

### Theme

Using **Catppuccin Mocha** theme with custom blue accents (replacing default green):

**Theme Features:**

- Active tab background: Blue (#89B4FA / RGB 137 180 250)
- Focused pane borders: Blue (#89B4FA / RGB 137 180 250)
- Text highlights: Blue accents throughout
- Exit success indicators: Blue instead of green
- Base colors: Catppuccin Mocha palette

**Theme Locations:**

- Main config: `~/.config/zellij/config.kdl` (embedded theme at lines 455-574)
- Theme file: `~/.config/zellij/themes/catppuccin-mocha.kdl`
- Theme directory: Set via `theme_dir` directive

**Why Blue Instead of Green?**
The default Catppuccin theme uses green for active elements. This custom version replaces all green (166 227 161) with blue (137 180 250) for a more cohesive visual experience.

**Color Mappings:**

| Component | Original (Green) | Custom (Blue) |
|-----------|------------------|---------------|
| `ribbon_selected.background` | 166 227 161 | 137 180 250 |
| `frame_selected.base` | 166 227 161 | 137 180 250 |
| `table_title.base` | 166 227 161 | 137 180 250 |
| `emphasis_2` (all components) | 166 227 161 | 137 180 250 |
| `exit_code_success.base` | 166 227 161 | 137 180 250 |

To change themes, edit `theme "catppuccin-mocha"` in `config.kdl`.

### UI Preferences

**Disabled Features:**

- Welcome screen: `welcome_screen false` (line 252)
- Startup tips: `show_startup_tips false` (line 447)

These settings provide a clean, distraction-free startup experience.

### Configuration

Edit `~/.config/zellij/config.kdl` to modify:

- Keybindings and modes
- Theme selection and colors
- Plugin configuration
- UI behavior (welcome screen, tips, etc.)

**Key Configuration Sections:**

- Lines 1-235: Keybindings (clear-defaults=true)
- Lines 239-254: Plugin definitions
- Line 272: Theme selection
- Line 301: Theme directory
- Lines 455-574: Embedded Catppuccin Mocha (blue variant)
