# Quick Start: install-js-packages.sh

## Usage in Your VM

### 1. Install bun first

```bash
# Option 1: Via mise (if you have mise installed)
mise use -g bun@latest

# Option 2: Direct install
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc  # or ~/.zshrc

# Verify
bun --version
```

### 2. Run the script

```bash
cd ~/.files

# View packages to be installed
cat scripts/config/js.pkg.yml

# Install packages (interactive, asks for confirmation)
./scripts/install-js-packages.sh

# Or install without confirmation
./scripts/install-js-packages.sh --yes
```

### 3. Customize packages (optional)

```bash
# Edit the config file
nano scripts/config/js.pkg.yml

# Add or remove packages as needed
# packages:
#   - typescript
#   - your-package-here

# Then install
./scripts/install-js-packages.sh
```

### 4. Other commands

```bash
# List installed global packages
./scripts/install-js-packages.sh --list

# Update all packages to latest
./scripts/install-js-packages.sh --update

# Show help
./scripts/install-js-packages.sh --help
```

---

## What Gets Installed (Default)

The default config includes:

**Package Managers:**
- pnpm
- yarn

**TypeScript:**
- typescript
- tsx
- ts-node
- @types/node

**Linting & Formatting:**
- eslint
- prettier
- @biomejs/biome

**Build Tools:**
- vite
- esbuild
- tsup

**Testing:**
- vitest
- jest

**Dev Tools:**
- nodemon
- concurrently
- rimraf
- dotenv-cli

**CLI Tools:**
- http-server
- serve
- npm-check-updates
- depcheck

**Documentation:**
- typedoc
- jsdoc

---

## How It Works

1. **Reads YAML config** - Parses `scripts/config/js.pkg.yml`
2. **Shows package list** - Displays what will be installed
3. **Asks confirmation** - Unless `--yes` flag is used
4. **Installs with bun** - Uses `bun add -g <package>`
5. **Shows summary** - Installed, failed, skipped counts

---

## Troubleshooting

### "bun is not installed"

Install bun first (see step 1 above).

### "command not found: bun" after installation

```bash
# Restart shell
exec $SHELL -l

# Or add to PATH manually
export PATH="$HOME/.bun/bin:$PATH"
```

### Package installation fails

```bash
# Try updating bun first
bun upgrade

# Or install package manually
bun add -g <package-name>
```

### Check what's installed globally

```bash
bun pm ls -g
```

---

## Notes

- Packages are installed **globally** (available system-wide)
- Config file uses simple YAML format (no complex features)
- Script skips already-installed packages
- Failed installations don't stop the process
- You can re-run anytime to install missing packages
