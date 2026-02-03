# Quick Start: install-js-packages.sh

## NEW: Professional vs Personal Packages

The script now supports **two separate config files**:

1. **Professional packages** (`js.pkg.yml`) - Safe for work/company PCs
   - TypeScript, ESLint, Prettier, Vite, Jest, etc.
   - Development tools that are standard across all environments

2. **Personal packages** (`js.pkg.personal.yml`) - For personal use only
   - Next.js, Vercel CLI, Firebase, framework CLIs, etc.
   - Tools you use for personal projects but not at work

This separation helps you:
- ✅ Install professional tools on your company PC
- ✅ Keep personal tools separate (install only on personal machines)
- ✅ Install both on your personal dev machine with one command

---

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

### 2. Install Packages

```bash
cd ~/.files

# OPTION A: Install professional packages ONLY (safe for work PC)
./scripts/install-js-packages.sh
# or
./scripts/install-js-packages.sh --install

# OPTION B: Install personal packages ONLY
./scripts/install-js-packages.sh --personal

# OPTION C: Install BOTH professional AND personal (personal machine)
./scripts/install-js-packages.sh --all

# OPTION D: Install without confirmation prompt
./scripts/install-js-packages.sh --yes
./scripts/install-js-packages.sh --personal --yes
./scripts/install-js-packages.sh --all --yes
```

### 3. View Package Lists

```bash
# View professional packages
cat scripts/config/js.pkg.yml

# View personal packages
cat scripts/config/js.pkg.personal.yml
```

### 4. Customize Packages

```bash
# Edit professional packages (safe for work)
nano scripts/config/js.pkg.yml

# Edit personal packages (personal projects only)
nano scripts/config/js.pkg.personal.yml

# Add or remove packages as needed
# packages:
#   - typescript
#   - your-package-here

# Then install
./scripts/install-js-packages.sh              # Install professional
./scripts/install-js-packages.sh --personal   # Install personal
```

### 5. Update Packages

```bash
# Update professional packages
./scripts/install-js-packages.sh --update

# Update personal packages
./scripts/install-js-packages.sh --update-personal

# List installed global packages
./scripts/install-js-packages.sh --list
```

### 6. Show Help

```bash
./scripts/install-js-packages.sh --help
```

---

## What Gets Installed

### Professional Packages (`js.pkg.yml`)

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

### Personal Packages (`js.pkg.personal.yml`)

**Personal CLI Tools:**
- vercel
- netlify-cli
- firebase-tools

**Personal Frameworks:**
- next
- nuxt
- @angular/cli
- @vue/cli
- create-react-app
- gatsby-cli
- astro

**Personal Dev Tools:**
- ngrok
- localtunnel
- pm2

---

## Usage Scenarios

### Scenario 1: Work/Company PC

```bash
# Install ONLY professional packages
./scripts/install-js-packages.sh --yes

# Result: TypeScript, ESLint, Vite, etc. (safe for work)
# Skips: Vercel CLI, Next.js, personal frameworks
```

### Scenario 2: Personal Dev Machine

```bash
# Install BOTH professional AND personal packages
./scripts/install-js-packages.sh --all --yes

# Result: Everything (work tools + personal tools)
```

### Scenario 3: Personal Side Project PC

```bash
# Install professional packages first
./scripts/install-js-packages.sh --yes

# Later, add personal tools when needed
./scripts/install-js-packages.sh --personal --yes
```

---

## How It Works

1. **Reads YAML config** - Parses professional or personal config file
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

### Config file not found

```bash
# Script will auto-create default config files
# Just run the script and it will create them for you
./scripts/install-js-packages.sh
```

---

## Notes

- Packages are installed **globally** (available system-wide)
- Config files use simple YAML format (no complex features)
- Script skips already-installed packages
- Failed installations don't stop the process
- You can re-run anytime to install missing packages
- **NEW**: Separate professional and personal packages for better organization
- **NEW**: Safe to use on company PCs (just don't install personal packages)

---

## Command Reference

| Command | Description |
|---------|-------------|
| `./scripts/install-js-packages.sh` | Install professional packages (default) |
| `./scripts/install-js-packages.sh --personal` | Install personal packages only |
| `./scripts/install-js-packages.sh --all` | Install both professional AND personal |
| `./scripts/install-js-packages.sh --yes` | Skip confirmation prompt |
| `./scripts/install-js-packages.sh --list` | List globally installed packages |
| `./scripts/install-js-packages.sh --update` | Update professional packages |
| `./scripts/install-js-packages.sh --update-personal` | Update personal packages |
| `./scripts/install-js-packages.sh --help` | Show help message |
