# Ghostty Terminal Configuration

Modern, fast terminal emulator configuration using Ghostty.

## What is Ghostty?

Ghostty is a fast, feature-rich terminal emulator with native platform integration and modern rendering capabilities.

## Features

- **Theme**: Catppuccin Frappe
- **Font**: CaskaydiaMono Nerd Font Mono at 16pt
- **Transparency**: 90% opacity with 20px blur radius
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
