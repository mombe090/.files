# Git Configuration

Global Git configuration with aliases, delta integration, and GitHub CLI credential helper.

## Features

### Aliases

- `co` = checkout
- `br` = branch
- `ci` = commit
- `st` = status

### Integrations

- **Delta**: Syntax-highlighted diffs with side-by-side view
- **GitHub CLI**: Credential helper for GitHub/Gist authentication
- **Merge Strategy**: zdiff3 for better conflict resolution

### Settings

- Default branch: `master`
- Pull strategy: Rebase
- User: Mamadou Yaya DIALLO

## Installation

```bash
stow git
```

## Usage

```bash
git st              # git status
git co main         # git checkout main
git ci -m "msg"     # git commit -m "msg"
```

Delta is automatically used for all diff operations.

## Files

- `.gitconfig` - Main Git configuration
- `.gitignore_global` - Global ignore patterns

## Customization

Edit `~/.gitconfig` to:

- Add more aliases
- Change default branch
- Modify delta settings
