# Delta Configuration

Git diff viewer with syntax highlighting and side-by-side comparison.

## What is Delta?

Delta is a syntax-highlighting pager for git, diff, and grep output. It provides beautiful, readable diffs with line numbers and Git integration.

## Features

- **Theme**: Catppuccin Mocha
- **Display**: Side-by-side diff view
- **Navigation**: Use `n` and `N` to move between diff sections
- **Integration**: Automatically used by Git for diffs and merges

## Installation

```bash
stow delta
```

## Usage

Delta is integrated into Git (via `.gitconfig`), so it's used automatically:

```bash
git diff              # Uses delta automatically
git show              # Uses delta automatically
git log -p            # Uses delta for patches
```

## Customization

The theme is located at `~/.config/delta/themes/catppuccin.gitconfig` and can be changed by modifying the Git config include path.
