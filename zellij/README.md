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

Edit `~/.config/zellij/config.kdl` to modify keybindings, themes, or add plugins.
