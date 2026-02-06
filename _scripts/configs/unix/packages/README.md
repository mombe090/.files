# Unix Package Configuration System

## Overview

This directory contains YAML-based package configurations for Unix-like systems. Configurations are split into **professional (pro)** and **personal (perso)** to support both work and personal machines, similar to the Windows package configuration system.

## Directory Structure

```text
unix/packages/
├── README.md                    # This file
├── common/                      # Common package configs (shared structure)
│   ├── pro/                     # Professional/work-safe packages
│   │   ├── brew.pkg.yml        # macOS Homebrew
│   │   ├── apt.pkg.yml         # Debian/Ubuntu
│   │   └── js.pkg.yml          # JavaScript packages
│   └── perso/                   # Personal packages (includes pro + personal)
│       ├── brew.pkg.yml        # macOS Homebrew
│       ├── apt.pkg.yml         # Debian/Ubuntu
│       └── js.pkg.yml          # JavaScript packages
├── pro/                         # Legacy professional packages (deprecated)
│   ├── brew.pkg.yml            # macOS Homebrew
│   └── apt.pkg.yml             # Debian/Ubuntu
└── perso/                       # Legacy personal packages (deprecated)
    ├── brew.pkg.yml            # macOS Homebrew
    ├── apt.pkg.yml             # Debian/Ubuntu
    ├── dnf.pkg.yml             # Fedora/RHEL
    └── pacman.pkg.yml          # Arch Linux
```

**Note**: The package system now uses `common/pro/` and `common/perso/` structure.
Legacy `pro/` and `perso/` directories are kept for backward compatibility.

## Professional vs Personal

### Professional (pro/)

Work-safe packages suitable for company/work computers:

- Essential development tools
- Standard language runtimes
- Common DevOps tools
- No experimental or personal tools

**Supported Systems:**

- macOS (Homebrew)
- Ubuntu/Debian (APT)

### Personal (perso/)

All professional packages PLUS personal additions:

- Experimental runtimes (Deno, Bun)
- Additional cloud tools
- Personal productivity tools
- Media/entertainment tools

**Supported Systems:**

- macOS (Homebrew)
- Ubuntu/Debian (APT)
- Fedora/RHEL (DNF)
- Arch Linux (Pacman)

## Configuration Files

### Package Managers

**Professional packages (`common/pro/`):**

- **`brew.pkg.yml`** - macOS Homebrew packages
- **`apt.pkg.yml`** - Debian/Ubuntu APT packages
- **`js.pkg.yml`** - JavaScript/TypeScript packages (via Bun)

**Personal packages (`common/perso/`):**

- **`brew.pkg.yml`** - macOS Homebrew packages (pro + personal)
- **`apt.pkg.yml`** - Debian/Ubuntu APT packages (pro + personal)
- **`js.pkg.yml`** - JavaScript/TypeScript packages (pro + personal)

**Legacy locations** (deprecated, kept for backward compatibility):

- `pro/*.pkg.yml` - Old professional package configs
- `perso/*.pkg.yml` - Old personal package configs (includes DNF, Pacman)

### Version Managers

**Mise tools are now managed via `mise/.config/mise/config.toml`** instead of `mise.pkg.yml`.

This allows for better version control and mise-native configuration.

### JavaScript/TypeScript

- **`js.pkg.yml`** - Professional JavaScript packages via Bun
- **`js.pkg.personal.yml`** - Personal JavaScript packages

## Configuration Format

### Package Manager Configs (brew/apt/dnf/pacman)

```yaml
category_name:
  - name: package-name
    description: Short description of the package
    category: category_name
    optional: true              # Optional field - skip in minimal install
    note: "Additional information"  # Optional field
    tap: tap-name              # Homebrew only - custom tap
    ppa: true                  # APT only - requires PPA
    aur: true                  # Pacman only - AUR package
```

### Mise Config

```yaml
category_name:
  - name: tool-name
    version: latest            # Can be: latest, 1.2.3, or version range
    description: Tool description
    category: category_name
    optional: true             # Optional field
```

## Categories

### Common Categories

- **essentials** - Core utilities (git, curl, stow, zsh)
- **development** - Dev tools (neovim, tmux, fzf, ripgrep, bat, eza)
- **build_tools** - Build systems (cmake, ninja, pkg-config)
- **libraries** - Development libraries (openssl, libffi, readline)
- **runtimes** - Language runtimes (python, node, go, rust)
- **cloud** - DevOps tools (kubectl, helm, k9s, terraform, docker)
- **fonts** - Programming fonts (Cascadia Code, JetBrains Mono, Fira Code)

### Platform-Specific

- **casks** (Homebrew) - GUI applications
- **aur_tools** (Arch) - AUR helpers

## Usage

### Manual Installation (Future)

```bash
# Install all packages from a specific config
./install-packages.sh --config apt.pkg.yml

# Install specific category
./install-packages.sh --config apt.pkg.yml --category essentials

# Skip optional packages
./install-packages.sh --config apt.pkg.yml --skip-optional
```

### Current Installation

Currently integrated with `_scripts/install.sh` which:

1. Detects your OS and package manager
2. Installs essential packages directly
3. Uses mise for language runtimes and modern CLI tools

## Design Philosophy

### 1. Package Manager Preference

Native PM → Mise → Build from Source

- Use native package managers for system-level tools
- Use mise for language runtimes and dev tools (cross-platform consistency)
- Only build from source as last resort

### 2. Version Management

**Language Runtimes**: Always prefer mise

- ✅ `mise install node@latest`
- ❌ `brew install node`

**Reason**: Mise allows multiple versions, easy switching, and cross-platform consistency

**System Tools**: Use native package manager

- ✅ `apt install git`
- ❌ `mise install git`

**Reason**: System integration, automatic updates via OS

### 3. Optional Packages

Mark heavy/specialized packages as `optional: true`:

- Large language runtimes (Java, Ruby) when not primary
- Optional cloud tools (when not using that platform)
- Alternative tools (multiple text editors)

This allows minimal vs. full installation modes.

### 4. Platform Differences

#### Package Names

Some packages have different names across platforms:

| Tool | Homebrew | APT | DNF | Pacman |
|------|----------|-----|-----|--------|
| fd   | `fd`     | `fd-find` | `fd-find` | `fd` |
| bat  | `bat`    | `bat` | `bat` | `bat` |
| delta| `delta`  | N/A (use mise) | N/A (use mise) | `git-delta` |

Use `note:` field to document platform-specific quirks.

#### Build Tools

- **Debian/Ubuntu**: `build-essential`
- **Fedora/RHEL**: `@Development Tools` (group)
- **Arch**: `base-devel`
- **macOS**: Xcode Command Line Tools

### 5. Fonts

**macOS (Homebrew)**:

- Use cask fonts: `brew install --cask font-jetbrains-mono-nerd-font`
- Tap required: `homebrew/cask-fonts`

**Linux**:

- Use distro packages when available
- Font files installed to `~/.local/share/fonts/` or `/usr/share/fonts/`
- Run `fc-cache -fv` after installation

## Migration Path

### Phase 1: Documentation (Current)

✅ Create YAML configs for all package managers
✅ Document structure and conventions

### Phase 2: Parser Script

- [ ] Create `install-packages.sh` script
- [ ] Parse YAML configs
- [ ] Handle categories and optional flags
- [ ] Detect OS and use appropriate config

### Phase 3: Integration

- [ ] Integrate with `_scripts/install.sh`
- [ ] Add to Just recipes
- [ ] Support minimal vs. full modes

### Phase 4: Maintenance

- [ ] Update configs as needed
- [ ] Add new tools
- [ ] Remove deprecated packages

## Examples

### Adding a New Package

**To apt.pkg.yml**:

```yaml
development:
  - name: neofetch
    description: System information tool
    category: development
    optional: true
```

**To mise config** (`mise/.config/mise/config.toml`):

```toml
[tools]
bottom = "latest"  # Cross-platform graphical process monitor
node = "20"        # Node.js LTS
python = "3.11"    # Python
```

### Platform-Specific Notes

**Homebrew tap**:

```yaml
fonts:
  - name: font-hack-nerd-font
    description: Hack with Nerd Font icons
    category: fonts
    tap: homebrew/cask-fonts
```

**APT PPA**:

```yaml
development:
  - name: zoxide
    description: Smarter cd command
    category: development
    ppa: true
    note: "May require: add-apt-repository ppa:zoxide/zoxide"
```

**AUR package**:

```yaml
aur_tools:
  - name: yay
    description: AUR helper written in Go
    category: aur_tools
    aur: true
    note: "Install from AUR: https://aur.archlinux.org/packages/yay"
```

## Maintenance

### Updating Versions

For mise tools, use `latest` to always get newest version:

```yaml
- name: node
  version: latest  # Always get latest stable
```

For pinned versions (when needed):

```yaml
- name: python
  version: 3.12    # Pin to 3.12.x
```

### Deprecation

Mark deprecated packages:

```yaml
- name: old-tool
  description: Old tool (DEPRECATED - use new-tool instead)
  category: development
  deprecated: true
  replacement: new-tool
```

## References

- [Homebrew Formulae](https://formulae.brew.sh/)
- [Ubuntu Packages](https://packages.ubuntu.com/)
- [Fedora Packages](https://packages.fedoraproject.org/)
- [Arch Packages](https://archlinux.org/packages/)
- [Mise Registry](https://mise.jdx.dev/registry.html)
