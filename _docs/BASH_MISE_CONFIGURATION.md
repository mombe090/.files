# Bash Configuration with Mise Support - January 29, 2026

## Summary

Created a bash configuration package for dotfiles that properly integrates with mise for tool management.

## Changes Made

### 1. Created Bash Package for Stow

**Files Created:**
- `bash/.bashrc` - Bash interactive shell configuration
- `bash/.bash_profile` - Bash login shell configuration

### 2. Configuration Features

#### `.bashrc` includes:
- Mise activation: `eval "$(mise activate bash)"`
- Bun PATH configuration
- Environment file sourcing (.env, .envrc)
- History settings
- Bash completion
- Starship prompt integration

#### `.bash_profile` includes:
- Sources `.bashrc` for login shells
- XDG Base Directory specification
- Local bin PATH addition

### 3. Updated Scripts

**`scripts/manage-stow.sh`:**
- Added `bash` to `DEFAULT_PACKAGES` list
- Bash configs now stowed automatically with full installation

**`scripts/install-js-packages.sh`:**
- Kept bash shebang (`#!/usr/bin/env bash`)
- Added mise activation directly in script: `eval "$(mise activate bash)"`
- Works in both bash and zsh

## How It Works

### Interactive Bash Shell
When you start an interactive bash session:
```bash
$ bash
$ source ~/.bashrc  # Or automatically on login via .bash_profile
$ tsc --version
Version 5.9.3
```

The `.bashrc` activates mise, which adds all mise-installed tools to PATH:
- Bun (and bun-installed global packages)
- Node.js
- Python, Go, Rust, Ruby
- All CLI tools (bat, eza, fd, ripgrep, etc.)

### Non-Interactive Scripts
Scripts that run in non-interactive bash need to activate mise themselves:
```bash
#!/usr/bin/env bash
if command -v mise &> /dev/null; then
  eval "$(mise activate bash)"
fi
# Now bun and other mise tools are available
```

## Installation

### On New System
```bash
cd ~/.files
./scripts/manage-stow.sh stow bash
```

This symlinks:
- `~/.bashrc` → `.files/bash/.bashrc`
- `~/.bash_profile` → `.files/bash/.bash_profile`

### Verification

```bash
# Start new bash session
bash --login

# Check PATH includes mise tools
echo $PATH | grep mise

# Check bun is available
which bun
bun --version

# Check global packages work
tsc --version
eslint --version
prettier --version
```

## Why Bash AND Zsh?

- **Zsh**: Primary shell for interactive use (better completion, plugins)
- **Bash**: Used by many scripts, system tools, and SSH sessions
- **Both need mise**: Tools installed via mise should work in both shells

## Key Points

1. **Mise activation is shell-specific**:
   - Zsh: `eval "$(mise activate zsh)"`
   - Bash: `eval "$(mise activate bash)"`

2. **Interactive vs Non-Interactive**:
   - Interactive shells (login): Source `.bashrc` / `.zshrc`
   - Non-interactive (scripts): Must activate mise manually

3. **Bun global packages**:
   - Installed to `~/.bun/bin`
   - PATH configured in both bash and zsh configs
   - Available after mise activation

## Testing Results

### Bash Interactive Shell ✅
```bash
$ ssh user@host
$ bash -i
$ tsc --version
Version 5.9.3
```

### Install Script (Non-Interactive) ✅
```bash
$ ./scripts/install-js-packages.sh --list
/home/user/.bun/install/global node_modules (737)
├── typescript@5.9.3
├── eslint@9.39.2
... (all 23 packages)
```

### Both Shells Work ✅
```bash
# In bash
$ bash -l -c "tsc --version"
Version 5.9.3

# In zsh
$ zsh -l -c "tsc --version"
Version 5.9.3
```

## Files Modified

- ✅ `bash/.bashrc` - NEW
- ✅ `bash/.bash_profile` - NEW
- ✅ `scripts/manage-stow.sh` - Added bash to defaults
- ✅ `scripts/install-js-packages.sh` - Uses bash with mise activation

## Related Documentation

- `docs/BUN_PATH_CONFIGURATION.md` - Bun PATH setup
- `zsh/.config/zsh/env.zsh` - Zsh environment config (includes bun PATH)
- `zsh/.zshrc` - Zsh config (includes mise activation)

## Note on `typescript --version`

The command is `tsc --version`, NOT `typescript --version`:
- ✅ `tsc --version` - TypeScript compiler (correct)
- ❌ `typescript --version` - Package name (not a command)

Other examples:
- Package: `eslint` → Command: `eslint`
- Package: `prettier` → Command: `prettier`
- Package: `typescript` → Command: `tsc`
