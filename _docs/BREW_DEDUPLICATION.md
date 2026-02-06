# Brew Package Deduplication & macOS-Only Installation

## Summary

Fixed package installation to:

1. ✅ Only install Homebrew packages on macOS
2. ✅ Remove all duplicates between brew.pkg.yml and mise config
3. ✅ Keep pro packages minimal and work-safe

## Changes Made

### 1. macOS-Only Brew Installation

**File**: `_scripts/unix/installers/install-packages.sh`

Added check to skip Homebrew installation on non-macOS systems:

```bash
# Check if we should skip brew on non-macOS
local os
os=$(detect_os)
if [[ "$pm" == "brew" ]] && [[ "$os" != "macos" ]]; then
    log_warning "Homebrew is only supported on macOS, skipping package installation"
    exit 0
fi
```

### 2. Removed Mise Duplicates from brew.pkg.yml

Analyzed `mise/.config/mise/config.toml` and removed ALL duplicate packages from both pro and perso brew configs.

**Tools managed by mise** (removed from brew.pkg.yml):

- **CLI Tools**: bat, eza, fd, ripgrep, fzf, zoxide, jq, yq
- **Dev Tools**: neovim, tmux, direnv, delta
- **Shell**: starship
- **Monitoring**: htop, btop
- **Git**: github-cli (gh), lazygit
- **Cloud/DevOps**: kubectl, helm, terraform, awscli, argocd, kind, k9s, opentofu
- **Languages**: node, bun, python, go, rust, ruby
- **Other**: shellcheck, vivid, tree-sitter, uv

### 3. Professional Packages (Pro)

**File**: `common/pro/brew.pkg.yml`

Kept ONLY work-safe, essential packages NOT in mise:

**Essentials** (5 packages):

- git, curl, wget, stow, zsh

**Development** (1 package):

- tree (directory display)

**Build Tools** (2 packages):

- cmake, pkg-config

**Fonts** (3 packages):

- font-cascadia-code
- font-jetbrains-mono-nerd-font
- font-fira-code-nerd-font

**Libraries** (3 packages):

- openssl@3, readline, sqlite

**Total**: 14 packages (down from 40+)

**Removed categories**:

- shell_tools (all in mise)
- monitoring (all in mise)
- cloud (all in mise)
- runtimes (all in mise)

### 4. Personal Packages (Perso)

**File**: `common/perso/brew.pkg.yml`

All pro packages PLUS personal additions:

**Additional Personal Tools** (5 packages):

- youtube-dl (optional)
- ffmpeg (optional)
- imagemagick (optional)
- pandoc (optional)
- ghostscript (optional)

**Total**: 19 packages (pro 14 + personal 5)

## Benefits

### ✅ No Duplicates

- Mise handles all CLI tools, dev tools, languages
- Brew only handles macOS-specific packages (fonts, libraries)
- Clear separation of responsibilities

### ✅ Minimal Pro Profile

- Only 14 essential work-safe packages
- No experimental or personal tools
- Suitable for company computers

### ✅ Platform-Specific

- Brew only runs on macOS
- Other package managers (apt, dnf, pacman) work on Linux
- Automatic platform detection

### ✅ Clear Documentation

- Each file documents what's included/excluded
- Notes explain why duplicates were removed
- References mise config for managed tools

## Package Distribution

```text
┌─────────────────────────────────────────┐
│ Mise (mise/.config/mise/config.toml)   │
├─────────────────────────────────────────┤
│ ✓ CLI Tools (bat, eza, fd, rg, fzf)   │
│ ✓ Dev Tools (nvim, tmux, delta)        │
│ ✓ Shell (starship, direnv, zoxide)     │
│ ✓ Languages (node, python, go, rust)   │
│ ✓ Cloud (kubectl, helm, terraform)     │
│ ✓ Data (jq, yq)                         │
│ ✓ Git (gh, lazygit)                     │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ Brew Pro (common/pro/brew.pkg.yml)     │
├─────────────────────────────────────────┤
│ ✓ Essentials (git, curl, wget, zsh)    │
│ ✓ Build Tools (cmake, pkg-config)      │
│ ✓ Fonts (Nerd Fonts)                    │
│ ✓ Libraries (openssl, readline, sqlite)│
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ Brew Perso (common/perso/brew.pkg.yml) │
├─────────────────────────────────────────┤
│ ✓ All Pro packages                      │
│ ✓ Personal (ffmpeg, imagemagick, etc)  │
└─────────────────────────────────────────┘
```

## Verification

### Test Pro Installation (Dry Run)

```bash
bash _scripts/unix/installers/install-packages.sh --pro --dry-run
```

**Output**:

- ✅ Only installs on macOS
- ✅ 5 essentials + 1 dev + 2 build + 3 fonts + 3 libs = 14 packages
- ✅ No mise duplicates
- ✅ All work-safe

### Test Perso Installation (Dry Run)

```bash
bash _scripts/unix/installers/install-packages.sh --perso --dry-run
```

**Output**:

- ✅ All pro packages (14)
- ✅ Plus 5 personal packages
- ✅ Total: 19 packages

## Files Modified

1. `_scripts/unix/installers/install-packages.sh` - Added macOS-only check
2. `_scripts/configs/unix/packages/common/pro/brew.pkg.yml` - Removed duplicates, kept minimal
3. `_scripts/configs/unix/packages/common/perso/brew.pkg.yml` - Cleaned up duplicates

## Result

✅ **Clean separation**: Mise handles tools, Brew handles macOS-specific packages
✅ **No duplicates**: Every package is managed by exactly one system
✅ **Platform-aware**: Brew only installs on macOS
✅ **Work-safe pro**: Only 14 essential packages, no experimental tools
✅ **Documented**: Clear notes explain what's managed where

Perfect for both work (pro) and personal (perso) machines! 🎉
