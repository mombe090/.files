# manage-stow.sh Usage Guide

## Quick Reference

```bash
# Stow default packages (zsh, mise, zellij, bat, nvim, starship)
./scripts/manage-stow.sh stow

# Stow specific packages
./scripts/manage-stow.sh stow zsh git nvim

# Re-stow (update symlinks after changes)
./scripts/manage-stow.sh restow

# Unstow (remove symlinks)
./scripts/manage-stow.sh unstow zellij

# List available packages
./scripts/manage-stow.sh list

# Show stow status
./scripts/manage-stow.sh status
```

---

## Default Packages

The following packages are stowed by default:

1. **zsh** - Zsh shell configuration
2. **mise** - Mise version manager config
3. **zellij** - Zellij terminal multiplexer
4. **bat** - Bat (cat replacement) config
5. **nvim** - Neovim configuration
6. **starship** - Starship prompt config

---

## Commands

### `stow` - Create Symlinks

Stows packages by creating symlinks from the dotfiles repo to your home directory.

```bash
# Stow default packages
./scripts/manage-stow.sh stow

# Stow specific packages
./scripts/manage-stow.sh stow git alacritty ghostty

# Alias
./scripts/manage-stow.sh -s
```

**What it does:**
- Creates symlinks for config files
- Skips already-stowed packages
- Shows summary of stowed/failed/skipped

### `restow` - Update Symlinks

Re-stows packages to update symlinks (useful after pulling updates).

```bash
# Restow default packages
./scripts/manage-stow.sh restow

# Restow specific packages
./scripts/manage-stow.sh restow nvim zsh

# Alias
./scripts/manage-stow.sh -r
```

**When to use:**
- After `git pull` to update symlinks
- After editing dotfiles structure
- To refresh broken symlinks

### `unstow` - Remove Symlinks

Removes symlinks for specified packages.

```bash
# Unstow default packages
./scripts/manage-stow.sh unstow

# Unstow specific packages
./scripts/manage-stow.sh unstow zellij hypr

# Alias
./scripts/manage-stow.sh -u
```

**When to use:**
- Before removing a package directory
- To temporarily disable a config
- To clean up old symlinks

### `list` - Show Available Packages

Lists all available packages in the dotfiles repo.

```bash
./scripts/manage-stow.sh list
```

**Output example:**
```
Available packages in /Users/user/.files:

  ✓ zsh (default)
  ✓ mise (default)
  ✓ zellij (default)
  ✓ bat (default)
  ✓ nvim (default)
  ✓ starship (default)
  - git
  - alacritty
  - ghostty
  - delta
  - hypr
  - nushell

Default packages: zsh mise zellij bat nvim starship
```

### `status` - Show Stow Status

Shows which default packages are currently stowed.

```bash
./scripts/manage-stow.sh status
```

**Output example:**
```
Stow status for default packages:

  ✓ zsh (stowed)
  ✓ mise (stowed)
  ✓ zellij (stowed)
  ○ bat (not stowed)
  ✓ nvim (stowed)
  ✓ starship (stowed)
```

---

## Common Workflows

### Initial Setup

```bash
# After cloning dotfiles
git clone https://github.com/user/dotfiles.git ~/.files
cd ~/.files

# Install stow
./scripts/install-stow.sh

# Stow default packages
./scripts/manage-stow.sh stow
```

### After Updating Dotfiles

```bash
# Pull latest changes
git pull

# Update symlinks
./scripts/manage-stow.sh restow
```

### Adding a New Package

```bash
# Create package directory
mkdir ~/.files/mynewconfig

# Add config files
mkdir -p ~/.files/mynewconfig/.config/mynewconfig
cp myconfig.conf ~/.files/mynewconfig/.config/mynewconfig/

# Stow the new package
./scripts/manage-stow.sh stow mynewconfig
```

### Removing a Package

```bash
# Unstow first
./scripts/manage-stow.sh unstow oldpackage

# Then remove directory
rm -rf ~/.files/oldpackage
```

### Debugging Stow Issues

```bash
# Check status
./scripts/manage-stow.sh status

# List available packages
./scripts/manage-stow.sh list

# Try restowing
./scripts/manage-stow.sh restow

# If conflicts, backup and remove old configs
./scripts/backup.sh
rm ~/.zshrc  # or conflicting file
./scripts/manage-stow.sh stow zsh
```

---

## Integration with install.sh

The main `install.sh` script uses `manage-stow.sh` automatically:

**Full installation:**
- Stows default packages: zsh, mise, zellij, bat, nvim, starship

**Minimal installation:**
- Stows only: zsh, git

You can always add more packages later:

```bash
./scripts/manage-stow.sh stow alacritty ghostty delta
```

---

## Package Structure

Each package is a directory containing dotfiles:

```
package-name/
├── .config/
│   └── package-name/
│       └── config.conf -> ~/.config/package-name/config.conf
├── .somerc -> ~/.somerc
└── bin/
    └── script.sh -> ~/bin/script.sh
```

When stowed, files are symlinked to your home directory preserving the structure.

---

## Tips

- **Check before stowing:** Use `./scripts/manage-stow.sh list` to see available packages
- **Verify after stowing:** Use `./scripts/manage-stow.sh status` to confirm
- **Restow after changes:** Always restow after pulling updates or editing dotfiles
- **Backup first:** Run `./scripts/backup.sh` before stowing if you have existing configs
- **Use specific packages:** You don't need to stow everything, pick what you need

---

## Troubleshooting

### "Conflicts with existing file"

```bash
# Backup existing file
mv ~/.config/conflicting/file ~/.config/conflicting/file.backup

# Or use backup script
./scripts/backup.sh

# Then stow
./scripts/manage-stow.sh stow package-name
```

### "Package not found"

```bash
# Check if package directory exists
ls ~/.files/package-name

# List available packages
./scripts/manage-stow.sh list
```

### "Stow not installed"

```bash
./scripts/install-stow.sh
```

### Broken symlinks

```bash
# Unstow and restow
./scripts/manage-stow.sh unstow package-name
./scripts/manage-stow.sh stow package-name
```
