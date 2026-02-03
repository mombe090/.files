# JavaScript Packages Installation - When Does It Run?

## Installation Flow

```
./install.sh --full
│
├── 1. Check prerequisites (git, curl)
├── 2. Backup existing configs
├── 3. Install Homebrew (macOS)
├── 4. Install mise
├── 5. Install core tools (zsh, stow)
├── 6. Install optional tools (bat, eza, fzf, etc.)
├── 7. Install .NET SDK
├── 8. Install mise tools from config
│        └── If bun is in mise config, it gets installed here
├── 9. Stow configurations (zsh, mise, zellij, bat, nvim, starship)
│
└── 10. POST-INSTALL SETUP ← JS PACKAGES INSTALL HERE!
    ├── Create ~/.gitconfig.local
    ├── Create ~/.env, ~/.envrc
    │
    └── ┌─ Check if bun is available ─┐
        │                              │
        ├─ YES: bun is installed       │
        │   ├── Show bun version       │
        │   ├── Run install-js-packages.sh --yes
        │   │   ├── Read js.pkg.yml
        │   │   ├── Install typescript
        │   │   ├── Install prettier
        │   │   ├── Install eslint
        │   │   ├── ... (25+ packages)
        │   │   └── Show summary
        │   └── ✓ JS packages complete │
        │                              │
        └─ NO: bun not found           │
            └── Skip JS packages       │
            └── Show instructions      │
```

---

## Expected Output (WITH bun)

```bash
[STEP] Running post-install setup...

[INFO] Creating ~/.gitconfig.local for personal git settings...
[INFO] Created ~/.env for environment variables
[INFO] Created ~/.envrc for direnv

[STEP] Checking for JavaScript/TypeScript package installation...
[INFO] bun detected (version: 1.1.38)
[INFO] Installing JavaScript/TypeScript packages globally...

[STEP] Reading package list from: /home/user/.files/_scripts/linux/config/js.pkg.yml
[INFO] Found 25 packages to install

[INFO] Installing: typescript
[✓] typescript installed

[INFO] Installing: tsx
[✓] tsx installed

[INFO] Installing: prettier
[✓] prettier installed

... (all packages) ...

[✓] Installation complete!

Summary:
  ✓ Installed: 25
  ⊗ Failed: 0
  → Skipped: 0
  Total: 25

[✓] JavaScript packages installation complete
[✓] Post-install setup complete
```

---

## Expected Output (WITHOUT bun)

```bash
[STEP] Running post-install setup...

[INFO] Creating ~/.gitconfig.local for personal git settings...
[INFO] Created ~/.env for environment variables
[INFO] Created ~/.envrc for direnv

[STEP] Checking for JavaScript/TypeScript package installation...
[INFO] bun not available, skipping JavaScript packages installation
[INFO] To install JS packages later:
  1. Install bun: curl -fsSL https://bun.sh/install | bash
  2. Restart shell: exec $SHELL -l
  3. Run: ./_scripts/linux/sh/installers/install-js-packages.sh

[✓] Post-install setup complete
```

---

## How to Ensure bun is Available

### Option 1: Add bun to mise config (Recommended)

**Before running install.sh:**

1. Edit `mise/.config/mise/config.toml`:
   ```toml
   [tools]
   bun = "latest"
   node = "lts"
   # ... other tools
   ```

2. Run installation:
   ```bash
   ./install.sh --full
   ```

3. mise will install bun during step 8
4. JS packages will auto-install during step 10

---

### Option 2: Install bun manually first

```bash
# Install bun
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc  # or ~/.zshrc

# Verify
bun --version

# Then run install
./install.sh --full
```

---

### Option 3: Install bun after main installation

```bash
# Run installation (JS packages will be skipped)
./install.sh --full

# Install bun
curl -fsSL https://bun.sh/install | bash
exec $SHELL -l

# Install JS packages manually
cd ~/.files
./_scripts/linux/sh/installers/install-js-packages.sh
```

---

## Debugging

### "I don't see JS packages installing"

Check if bun is in your PATH:

```bash
# Check if bun is available
command -v bun

# Check bun version
bun --version

# If not found, install bun
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc
```

### "JS packages installed but I don't see output"

The output should appear right after:
```
[STEP] Checking for JavaScript/TypeScript package installation...
```

If you don't see this line, check the logs or run manually:
```bash
./_scripts/linux/sh/installers/install-js-packages.sh --yes
```

### "Installation failed with errors"

Check the error messages and run diagnostics:
```bash
# Check bun works
bun --version

# Check config file exists
cat _scripts/linux/config/js.pkg.yml

# Try manual installation
./_scripts/linux/sh/installers/install-js-packages.sh
```

---

## What Gets Installed

Default packages from `_scripts/linux/config/js.pkg.yml`:

**Package Managers:**
- pnpm, yarn

**TypeScript:**
- typescript, tsx, ts-node, @types/node

**Linting/Formatting:**
- eslint, prettier, @biomejs/biome

**Build Tools:**
- vite, esbuild, tsup

**Testing:**
- vitest, jest

**Dev Tools:**
- nodemon, concurrently, rimraf, dotenv-cli

**CLI Tools:**
- http-server, serve, npm-check-updates, depcheck

**Documentation:**
- typedoc, jsdoc

**Total: ~25 packages**

---

## Summary

✅ JS packages install **automatically** if bun is available
✅ Runs during **post_install** (step 10, at the very end)
✅ Non-blocking (doesn't fail main installation)
✅ Clear output showing what's happening
✅ Instructions provided if bun not available

**To see it in action:** Make sure bun is installed before running `./install.sh --full`!
