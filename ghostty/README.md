# Ghostty Terminal Configuration

Modern, fast terminal emulator configuration using Ghostty.

## What is Ghostty?

Ghostty is a fast, feature-rich terminal emulator with native platform integration and modern rendering capabilities.

## Features

- **Theme**: Catppuccin Macchiato
- **Font**: CaskaydiaMono Nerd Font Mono at 12pt
- **Transparency**: 97.88% opacity, no blur (aligned with Alacritty)
- **Shell Integration**: ZSH with enhanced features
- **macOS**: Option key as Alt, official icon

## Installation

```bash
stow ghostty
```

## Usage

```bash
ghostty
```

Features enabled:

- Copy on select
- Mouse hiding while typing
- Background blur for aesthetics
- Shell integration for enhanced features

## Useful Commands

```bash
ghostty +list-fonts          # Show available fonts
ghostty +list-keybinds --default  # Show default keybindings
```

## Customization

Edit `~/.config/ghostty/config` to modify theme, fonts, or transparency settings.
