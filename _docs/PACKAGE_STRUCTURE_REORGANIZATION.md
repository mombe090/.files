# Package Structure Reorganization - common/pro & common/perso

## Summary

Successfully reorganized package configurations to use a cleaner `common/pro/` and `common/perso/` structure instead of having configs scattered across `common/`, `pro/`, and `perso/` directories.

## New Structure

```text
_scripts/configs/unix/packages/
├── README.md
├── common/
│   ├── pro/                     # Professional/work-safe packages
│   │   ├── brew.pkg.yml        # macOS Homebrew
│   │   ├── apt.pkg.yml         # Debian/Ubuntu
│   │   └── js.pkg.yml          # JavaScript packages
│   └── perso/                   # Personal (pro + personal packages)
│       ├── brew.pkg.yml        # macOS Homebrew (includes personal tools)
│       ├── apt.pkg.yml         # Debian/Ubuntu (includes personal tools)
│       └── js.pkg.yml          # JavaScript packages (includes personal)
├── pro/                         # Legacy (kept for backward compatibility)
│   ├── brew.pkg.yml
│   └── apt.pkg.yml
└── perso/                       # Legacy (kept for backward compatibility)
    ├── brew.pkg.yml
    ├── apt.pkg.yml
    ├── dnf.pkg.yml
    └── pacman.pkg.yml
```

## Changes Made

### 1. Created New Directory Structure

**Created:**

- `common/pro/` - Professional/work-safe packages
- `common/perso/` - Personal packages (includes all pro + personal additions)

### 2. Moved Configs

**Professional packages** (`common/pro/`):

- ✅ `brew.pkg.yml` - Work-safe Homebrew packages
- ✅ `apt.pkg.yml` - Work-safe APT packages
- ✅ `js.pkg.yml` - Work-safe JavaScript packages

**Personal packages** (`common/perso/`):

- ✅ `brew.pkg.yml` - All pro packages + personal tools (youtube-dl, ffmpeg, etc.)
- ✅ `apt.pkg.yml` - All pro packages + personal tools
- ✅ `js.pkg.yml` - All pro packages + personal frameworks (next, vue, angular, etc.)

### 3. Updated Scripts

**install-packages.sh:**

- Updated `install_packages_with_common()` to use `common/pro/` or `common/perso/`
- Falls back to legacy `pro/` and `perso/` directories if new structure doesn't exist
- Maintains backward compatibility

**install-js-packages.sh:**

- Updated to use `common/pro/js.pkg.yml` and `common/perso/js.pkg.yml`
- Falls back to old locations if new files don't exist
- Simplified config checking logic

### 4. Package Differences

#### Professional (`common/pro/`)

Work-safe packages suitable for company computers:

- Essential dev tools (git, curl, wget, stow, zsh, jq)
- Development tools (neovim, tmux, tree, ripgrep, fd, fzf, bat, eza, zoxide)
- Build tools (cmake, gcc, make)
- Shell tools (starship, htop, btop)
- Modern fonts (Cascadia Code, JetBrains Mono, Fira Code)
- Libraries (openssl, readline, sqlite, libffi, zlib)
- JavaScript tools (pnpm, yarn, typescript, eslint, prettier, vite, jest)

#### Personal (`common/perso/`)

All professional packages PLUS:

- **Media tools**: youtube-dl, ffmpeg, imagemagick, pandoc, ghostscript
- **Cloud tools**: terraform, kubectl, helm (optional)
- **JS frameworks**: vercel, netlify-cli, firebase-tools, create-next-app, nuxi, angular-cli, vue-cli, gatsby-cli, astro
- **Personal dev**: ngrok, localtunnel, pm2

## Benefits

✅ **Clearer Organization**: All configs in one place (`common/`)
✅ **Profile-Based**: Clear separation between `pro/` and `perso/`
✅ **Single Source**: No duplication between common and profile-specific
✅ **Backward Compatible**: Legacy locations still work
✅ **Easier Maintenance**: Update one file per profile instead of common + profile-specific

## Usage

### Install Professional Packages

```bash
just install_pro
# or
bash _scripts/install.sh --pro
```

Uses packages from:

- `common/pro/brew.pkg.yml` (macOS)
- `common/pro/apt.pkg.yml` (Linux)
- `common/pro/js.pkg.yml` (JavaScript)

### Install Personal Packages

```bash
just install_perso
# or
bash _scripts/install.sh --perso
```

Uses packages from:

- `common/perso/brew.pkg.yml` (macOS)
- `common/perso/apt.pkg.yml` (Linux)
- `common/perso/js.pkg.yml` (JavaScript)

### Install Specific Package Manager

```bash
# Install only Homebrew packages (pro)
bash _scripts/unix/installers/install-packages.sh --pro

# Install only APT packages (perso)
bash _scripts/unix/installers/install-packages.sh --perso
```

## Files Modified

1. **Created:**
   - `common/pro/brew.pkg.yml`
   - `common/pro/apt.pkg.yml`
   - `common/pro/js.pkg.yml`
   - `common/perso/brew.pkg.yml`
   - `common/perso/apt.pkg.yml`
   - `common/perso/js.pkg.yml`

2. **Updated:**
   - `_scripts/unix/installers/install-packages.sh`
   - `_scripts/unix/installers/install-js-packages.sh`
   - `_scripts/configs/unix/packages/README.md`

3. **Kept (backward compatibility):**
   - `pro/brew.pkg.yml`
   - `pro/apt.pkg.yml`
   - `perso/brew.pkg.yml`
   - `perso/apt.pkg.yml`
   - `perso/dnf.pkg.yml`
   - `perso/pacman.pkg.yml`

## Migration Notes

- New installations automatically use `common/pro/` and `common/perso/`
- Existing installations continue to work with legacy directories
- Scripts check new locations first, then fall back to legacy
- No action required for existing users
- Can gradually migrate by copying legacy configs to new structure

## Testing

```bash
# Verify structure
ls -la _scripts/configs/unix/packages/common/pro/
ls -la _scripts/configs/unix/packages/common/perso/

# Test installation (dry run)
bash _scripts/unix/installers/install-packages.sh --pro --dry-run
bash _scripts/unix/installers/install-packages.sh --perso --dry-run

# Test JS packages
bash _scripts/unix/installers/install-js-packages.sh --help
```

All tests passing ✅

All tests passing ✅
