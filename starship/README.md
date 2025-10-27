# Starship Prompt Configuration

Cross-shell prompt with Git, Kubernetes, and system information.

## What is Starship?

Starship is a fast, customizable, cross-shell prompt written in Rust. It shows contextual information about your current directory and environment.

## Features

### Display Elements

- **OS Icon**: Shows OS-specific icon (Arch, Ubuntu, macOS, Windows)
- **Username**: Always visible
- **Hostname**: Visible on SSH connections
- **Directory**: Current path with home symbol
- **Git**: Branch name and status (staged, modified, ahead/behind)
- **Kubernetes**: Current context and namespace

### Git Status Icons

- `󰋗` Untracked files
- `󰛿` Modified files
- `󰐗` Staged files
- `󱍸` Renamed files
- `󰍶` Deleted files
- `󰘽` Up-to-date
- `󰜘` Stashed changes

## Installation

```bash
stow starship
```

Add to your shell config:

```bash
eval "$(starship init zsh)"    # For zsh
eval "$(starship init bash)"   # For bash
```

## Usage

The prompt updates automatically based on your current directory and Git repository status.

## Customization

Edit `~/starship.toml` to:

- Add/remove modules
- Change icons
- Modify colors
- Adjust truncation settings

## Documentation

Learn more: <https://starship.rs/config/>
