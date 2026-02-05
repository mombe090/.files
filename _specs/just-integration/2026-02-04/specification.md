# Just Integration Specification

## Document Overview

**Title**: Justfile Integration for Dotfiles Repository
**Version**: 1.0.0
**Date**: February 4, 2026
**Status**: Planning Phase
**Author**: Automated Specification

---

## 1. Executive Summary

### 1.1 Problem Statement

The dotfiles repository currently has a fragmented command interface:

- **Linux/macOS**: `install.sh` + 13 individual installer scripts + management tools
- **Windows**: `install.ps1` + 7 PowerShell scripts + `stow.ps1`
- **No unified interface** across platforms
- **Poor discoverability** - users must read documentation to find scripts
- **Repetitive workflows** - no single command for common tasks (update, verify, sync)
- **Manual verification** - users must check installations manually

### 1.2 Proposed Solution

Integrate `just` (modern command runner) as a **unified task interface** that:

- Provides consistent commands across all platforms (Linux/macOS/Windows)
- Wraps existing scripts (keeping them functional)
- Adds missing workflows (doctor, update, sync, verify)
- Self-documents via `just --list`
- Uses **snake_case** naming convention for all recipes

### 1.3 Success Criteria

✅ Users can run `just --list` to discover all available commands
✅ Common workflows become single commands (`just update`, `just doctor`)
✅ Installation works with `just install_full` or `just install_minimal`
✅ Cross-platform support (OS-specific recipes where needed)
✅ Backward compatibility (all existing scripts still work)
✅ Clear documentation in `specs/just-integration.md`

---

## 2. Architecture

### 2.1 File Structure

```
~/.files/
├── justfile                          # Main entry point (imports all modules)
├── .just/                            # Modular recipe files
│   ├── _helpers.just                 # Shared variables & functions
│   ├── install.just                  # Installation recipes
│   ├── stow.just                     # Stow management recipes
│   ├── mise.just                     # Mise/tool management recipes
│   ├── verify.just                   # Verification & health check
│   ├── maintenance.just              # Update, backup, cleanup
│   ├── windows.just                  # Windows-specific recipes
│   └── dev.just                      # Development/testing recipes
├── specs/
│   └── just-integration.md           # This specification document
└── _scripts/
    └── just/
        ├── install-just.sh           # Install just on Linux/macOS
        ├── install-just.ps1          # Install just on Windows
        └── bootstrap.sh              # One-command bootstrap
```

### 2.2 Module Responsibilities

| Module | Purpose | Key Recipes |
|--------|---------|-------------|
| `justfile` | Main entry, imports all modules | `default`, `help`, `bootstrap` |
| `_helpers.just` | Shared variables, OS detection | Variables, helper functions |
| `install.just` | Installation workflows | `install_full`, `install_minimal`, `install_component` |
| `stow.just` | Symlink management | `stow`, `unstow`, `restow`, `stow_list` |
| `mise.just` | Tool version management | `mise_install`, `mise_upgrade`, `mise_list` |
| `verify.just` | Health checks & verification | `doctor`, `verify`, `check_path` |
| `maintenance.just` | Updates & maintenance | `update`, `sync`, `backup_*`, `clean` |
| `windows.just` | Windows-specific tasks | `win_install_*`, `win_stow`, `win_setup_*` |
| `dev.just` | Development helpers | `test`, `lint`, `format` |

### 2.3 Dependency Graph

```
justfile (main)
  ├─→ _helpers.just (always loaded first)
  ├─→ install.just
  │     ├─→ mise.just (mise_install)
  │     └─→ stow.just (stow after install)
  ├─→ verify.just
  │     └─→ _helpers.just (use OS detection)
  ├─→ maintenance.just
  │     ├─→ stow.just (restow after update)
  │     └─→ verify.just (verify after update)
  └─→ windows.just (conditional, Windows only)
```

### 2.4 Cross-Platform Strategy

**OS Detection:**

```just
# In _helpers.just
os_type := os()              # Returns: "linux", "macos", or "windows"
is_windows := if os() == "windows" { "true" } else { "false" }
is_unix := if os() == "windows" { "false" } else { "true" }
```

**Platform-Specific Recipes:**

```just
# Conditional execution
[unix]
some_unix_recipe:
    ./script.sh

[windows]
some_windows_recipe:
    pwsh -File script.ps1

# Unified recipe with branching
cross_platform_recipe:
    #!/usr/bin/env bash
    if [ "{{os()}}" = "windows" ]; then
        pwsh -File script.ps1
    else
        ./script.sh
    fi
```

---

## 3. Recipe Reference

### 3.1 Core Recipes (Main Entry)

| Recipe | Description | Platform | Example |
|--------|-------------|----------|---------|
| `default` | Show all available recipes | All | `just` |
| `help` | Show detailed help | All | `just help` |
| `bootstrap` | Install just itself + basic setup | All | `just bootstrap` |

### 3.2 Installation Recipes (`install.just`)

| Recipe | Description | Delegates To | Example |
|--------|-------------|--------------|---------|
| `install_full` | Full installation (all tools) | `./install.sh --full` | `just install_full` |
| `install_minimal` | Minimal installation (core only) | `./install.sh --minimal` | `just install_minimal` |
| `install_component COMP` | Install specific component | Individual scripts | `just install_component mise` |
| `install_homebrew` | Install Homebrew (macOS) | `install-homebrew.sh` | `just install_homebrew` |
| `install_mise` | Install mise version manager | `install-mise.sh` | `just install_mise` |
| `install_essentials` | Install build tools | `install-essentials.sh` | `just install_essentials` |
| `install_zsh` | Install zsh shell | `install-zsh.sh` | `just install_zsh` |
| `install_stow` | Install GNU Stow | `install-stow.sh` | `just install_stow` |
| `install_fonts` | Install modern Nerd Fonts | `install-modern-fonts.sh` | `just install_fonts` |
| `install_dotnet` | Install .NET SDK | `install-dotnet.sh` | `just install_dotnet` |
| `install_docker` | Install Docker (Ubuntu) | `install-docker.sh` | `just install_docker` |
| `install_js_packages TYPE` | Install JS packages (pro/personal/all) | `install-js-packages.sh` | `just install_js_packages pro` |
| `install_lazyvim` | Install LazyVim | `install-lazyvim.sh` | `just install_lazyvim` |
| `install_nushell` | Install Nushell | `install-nushell.sh` | `just install_nushell` |
| `install_uv_tools` | Install UV Python tools | `install-uv-tools.sh` | `just install_uv_tools` |
| `install_clawdbot` | Install Clawdbot CLI (optional) | `install-clawdbot.sh` | `just install_clawdbot` |

### 3.3 Stow Recipes (`stow.just`)

| Recipe | Description | Delegates To | Example |
|--------|-------------|--------------|---------|
| `stow PKG=""` | Stow package(s) | `manage-stow.sh stow` | `just stow nvim` |
| `unstow PKG=""` | Unstow package(s) | `manage-stow.sh unstow` | `just unstow wezterm` |
| `restow PKG=""` | Restow package(s) | `manage-stow.sh restow` | `just restow` |
| `stow_list` | List available packages | `manage-stow.sh status` | `just stow_list` |
| `stow_status` | Show stow status | `manage-stow.sh status` | `just stow_status` |

### 3.4 Mise Recipes (`mise.just`)

| Recipe | Description | Delegates To | Example |
|--------|-------------|--------------|---------|
| `mise_install` | Install tools from mise config | `mise install` | `just mise_install` |
| `mise_upgrade` | Upgrade all mise tools | `mise upgrade` | `just mise_upgrade` |
| `mise_list` | List installed tools | `mise list` | `just mise_list` |
| `mise_use TOOL` | Add tool to global config | `mise use -g TOOL` | `just mise_use node@20` |
| `mise_outdated` | Show outdated tools | `mise outdated` | `just mise_outdated` |

### 3.5 Verification Recipes (`verify.just`) ⭐ **NEW**

| Recipe | Description | Implementation | Example |
|--------|-------------|----------------|---------|
| `doctor` | Comprehensive health check | New script: `_scripts/doctor.sh` | `just doctor` |
| `verify` | Verify all installations | New script: `_scripts/verify.sh` | `just verify` |
| `verify_core` | Verify core tools only | `verify.sh --core` | `just verify_core` |
| `check_path` | Check PATH configuration | Helper function | `just check_path` |
| `check_shell` | Verify shell setup | Helper function | `just check_shell` |

**Doctor checks:**

- ✅ Git configuration (`.gitconfig.local` exists)
- ✅ Shell setup (zsh default, zinit installed)
- ✅ PATH configuration (mise, bun, dotnet in PATH)
- ✅ Symlink status (no broken symlinks)
- ✅ Tool versions (check for outdated)
- ✅ Dependencies (build tools installed)

### 3.6 Maintenance Recipes (`maintenance.just`) ⭐ **NEW**

| Recipe | Description | Implementation | Example |
|--------|-------------|----------------|---------|
| `update` | Update everything | `git pull` + `mise upgrade` + JS packages + `restow` | `just update` |
| `sync` | Sync dotfiles | `git pull` + `restow` + verify | `just sync` |
| `backup_create` | Create backup of configs | `_scripts/tools/backup.sh` | `just backup_create` |
| `backup_list` | List backups | New: list backups | `just backup_list` |
| `backup_restore TIMESTAMP` | Restore backup | New: restore backup | `just backup_restore 20260204` |
| `clean` | Clean temp files | Remove backups, caches | `just clean` |
| `uninstall` | Uninstall dotfiles | `_scripts/tools/uninstall.sh` | `just uninstall` |

### 3.7 Windows Recipes (`windows.just`)

| Recipe | Description | Delegates To | Example |
|--------|-------------|--------------|---------|
| `win_install_packages TYPE` | Install packages | `install.ps1 -Type TYPE` | `just win_install_packages pro` |
| `win_install_fonts` | Install Nerd Fonts | `Install-ModernFonts.ps1` | `just win_install_fonts` |
| `win_stow PKG` | Stow using PowerShell | `stow.ps1 PKG` | `just win_stow wezterm` |
| `win_setup_powershell` | Setup PowerShell profile | `setup-windows.ps1` | `just win_setup_powershell` |
| `win_install_js_packages` | Install JS packages | `install-js-packages.ps1` | `just win_install_js_packages` |

### 3.8 Development Recipes (`dev.just`)

| Recipe | Description | Implementation | Example |
|--------|-------------|----------------|---------|
| `test` | Run all tests | pre-commit hooks + verify | `just test` |
| `test_stow` | Test stow config | Dry run stow | `just test_stow` |
| `lint` | Lint shell scripts | shellcheck + markdownlint | `just lint` |
| `format` | Format code | shfmt | `just format` |

---

## 4. Implementation Strategy

### 4.1 Phase 1: Bootstrap & Core (Week 1)

**Goal**: Get just installed and basic recipes working

**Deliverables**:

1. ✅ `_scripts/just/install-just.sh` - Install just (Linux/macOS)
2. ✅ `_scripts/just/install-just.ps1` - Install just (Windows)
3. ✅ `_scripts/just/bootstrap.sh` - One-command setup
4. ✅ `justfile` - Main entry point with imports
5. ✅ `.just/_helpers.just` - OS detection, variables
6. ✅ `.just/install.just` - Wrap existing install.sh
7. ✅ `.just/stow.just` - Wrap manage-stow.sh

**Testing**: Install just, run `just install_full`, verify it works

### 4.2 Phase 2: New Workflows (Week 2)

**Goal**: Add missing workflows (doctor, update, verify)

**Deliverables**:

1. ✅ `_scripts/doctor.sh` - Health check script (new)
2. ✅ `_scripts/verify.sh` - Verification script (new)
3. ✅ `.just/verify.just` - Doctor and verify recipes
4. ✅ `.just/maintenance.just` - Update, sync, backup recipes
5. ✅ `.just/mise.just` - Mise management recipes

**Testing**: Run `just doctor`, `just verify`, `just update`

### 4.3 Phase 3: Cross-Platform & Polish (Week 3)

**Goal**: Windows support and documentation

**Deliverables**:

1. ✅ `.just/windows.just` - Windows-specific recipes
2. ✅ `.just/dev.just` - Development recipes
3. ✅ Update `README.md` with just examples
4. ✅ Create `JUSTFILE.md` reference documentation
5. ✅ Test on all platforms (Linux, macOS, Windows)

**Testing**: Full integration test on all platforms

### 4.4 Phase 4: Migration & Adoption (Week 4)

**Goal**: Make just the recommended interface

**Deliverables**:

1. ✅ Update all docs to mention `just` as primary interface
2. ✅ Add `just` to recommended installations
3. ✅ Keep `install.sh` as fallback (backward compatibility)
4. ✅ Add CI/CD using just recipes (optional)
5. ✅ Community feedback and iteration

---

## 5. Key Design Decisions

### 5.1 Naming Convention: snake_case

**Decision**: Use `snake_case` for all recipe names

**Rationale**:

- Consistent with existing file names in repository
- Easy to type (no shift key needed)
- Common in shell scripting
- Examples: `install_full`, `mise_upgrade`, `backup_create`

### 5.2 Modular Structure (.just/ folder)

**Decision**: Split recipes into logical modules in `.just/` folder

**Rationale**:

- **Maintainability**: Easier to find and edit specific recipes
- **Clarity**: Clear separation of concerns
- **Scalability**: Easy to add new modules
- **Reusability**: Modules can import each other
- **Follows best practices**: Similar to Makefile includes

**Alternative Rejected**: Single large `justfile` (would be 500+ lines, hard to maintain)

### 5.3 Wrap Existing Scripts (Don't Rewrite)

**Decision**: Justfile calls existing scripts, doesn't replace them

**Rationale**:

- **Backward Compatibility**: Existing workflows continue to work
- **Risk Mitigation**: Proven scripts remain functional
- **Incremental Adoption**: Users can try just without commitment
- **Separation**: Just is UI layer, scripts are implementation

**Example**:

```just
# Good: Wraps existing script
install_mise:
    ./_scripts/linux/sh/installers/install-mise.sh

# Avoid: Reimplementing in justfile
install_mise:
    #!/usr/bin/env bash
    curl https://mise.run | sh
    # ... (reimplementing install-mise.sh logic)
```

### 5.4 Cross-Platform via Conditional Recipes

**Decision**: Use `[unix]`, `[windows]` attributes + OS detection

**Rationale**:

- **Native just feature**: Built-in OS detection
- **Clean syntax**: Clear which recipes work where
- **Flexibility**: Can have OS-specific + unified recipes
- **User-friendly**: Users don't need to know OS details

**Alternative Rejected**: Separate justfiles per OS (would fragment interface)

### 5.5 New Helper Scripts for Gaps

**Decision**: Create new scripts (`doctor.sh`, `verify.sh`, `update.sh`) called by just

**Rationale**:

- **Fills identified gaps**: doctor, verify, update workflows missing
- **Reusable**: Scripts can be called independently or via just
- **Testable**: Easier to test scripts than just recipes
- **Follows pattern**: Consistent with existing architecture

---

## 6. Bootstrap Process

### 6.1 Cold Start (No just installed)

**Problem**: How do users install just if they need just to install just?

**Solution**: Three-stage bootstrap

**Stage 1: Manual (One-time)**

```bash
# Linux/macOS
curl -fsSL https://just.systems/install.sh | bash -s -- --to ~/.local/bin

# OR via homebrew
brew install just

# Windows
winget install --id Casey.Just
# OR
choco install just
```

**Stage 2: Scripted Bootstrap (Recommended)**

```bash
# Clone dotfiles
git clone https://github.com/mombe090/.files.git ~/.files
cd ~/.files

# Run bootstrap (installs just + basic setup)
./_scripts/just/bootstrap.sh

# Now just is available
just --version
just install_full
```

**Stage 3: Just Available**

```bash
# After just is installed, use it for everything
just install_mise
just stow nvim
just doctor
```

### 6.2 Bootstrap Script Responsibilities

`_scripts/just/bootstrap.sh`:

1. ✅ Check if just is already installed
2. ✅ Detect OS (Linux/macOS/Windows)
3. ✅ Install just via appropriate method
4. ✅ Add just to PATH
5. ✅ Verify installation
6. ✅ Show next steps (`just --list`)

**Exit with clear message**:

```
✓ Just installed successfully!

Next steps:
  1. Run: just --list        # See all available commands
  2. Run: just install_full  # Install everything
  3. Run: just doctor        # Verify installation

Documentation: cat README.md
```

---

## 7. Variables & Configuration

### 7.1 Built-in Variables (in `_helpers.just`)

```just
# OS detection
os_type := os()                                    # "linux", "macos", "windows"
is_windows := if os() == "windows" { "true" } else { "false" }
is_unix := if os() == "windows" { "false" } else { "true" }

# Paths
dotfiles_root := justfile_directory()
scripts_dir := dotfiles_root / "_scripts"
linux_scripts := scripts_dir / "linux/sh"
windows_scripts := scripts_dir / "windows/pwsh"
installers := linux_scripts / "installers"
tools := linux_scripts / "tools"

# User home
home := env_var("HOME")                            # Unix
userprofile := env_var_or_default("USERPROFILE", home)  # Windows

# Target directory
config_dir := home / ".config"
stow_target := config_dir

# Colors (for output)
color_reset := "\033[0m"
color_green := "\033[0;32m"
color_blue := "\033[0;34m"
color_yellow := "\033[1;33m"
color_red := "\033[0;31m"
```

### 7.2 User Configuration (Optional)

Users can create `.justenv` file in dotfiles root:

```bash
# .justenv - User-specific settings (not tracked in git)
export MISE_INSTALL_PATH=/usr/local/bin
export DOTFILES_BACKUP_DIR=$HOME/.dotfiles-backups
export JS_PACKAGE_TYPE=pro  # or personal
```

Just automatically loads `.justenv` if it exists.

---

## 8. Error Handling

### 8.1 Principles

1. **Fail Fast**: Stop on first error (default `just` behavior)
2. **Clear Messages**: Explain what failed and how to fix
3. **Graceful Degradation**: Optional features don't block core
4. **Rollback Support**: Backups before destructive operations

### 8.2 Example Pattern

```just
install_component COMP:
    #!/usr/bin/env bash
    set -euo pipefail

    # Validate component exists
    if [ ! -f "{{installers}}/install-{{COMP}}.sh" ]; then
        echo "❌ Unknown component: {{COMP}}"
        echo "Available: mise, dotnet, fonts, js-packages, ..."
        exit 1
    fi

    # Run installer
    echo "📦 Installing {{COMP}}..."
    if {{installers}}/install-{{COMP}}.sh; then
        echo "✅ {{COMP}} installed successfully"
    else
        echo "❌ Failed to install {{COMP}}"
        echo "Check logs above for details"
        exit 1
    fi
```

### 8.3 Backup Before Destructive Ops

```just
# Always backup before stow
stow PKG="":
    @echo "Creating backup..."
    @just backup_create
    @echo "Stowing {{PKG}}..."
    @{{tools}}/manage-stow.sh stow {{PKG}}
```

---

## 9. Documentation Plan

### 9.1 User-Facing Documentation

**README.md updates**:

- Add "Quick Start with Just" section
- Replace script commands with just equivalents
- Add `just --list` as discovery mechanism

**New: JUSTFILE.md**:

- Complete recipe reference
- Usage examples for each recipe
- Troubleshooting guide
- Migration guide from scripts

**Inline Documentation**:

- Each recipe has description shown in `just --list`
- Comments explain complex recipes

### 9.2 Developer Documentation

**specs/just-integration.md** (this document):

- Architecture and design decisions
- Module responsibilities
- Testing strategy

**CONTRIBUTING.md updates**:

- How to add new recipes
- Naming conventions
- Testing requirements

---

## 10. Testing Strategy

### 10.1 Manual Testing Checklist

**Linux (Debian):**

- [ ] `just bootstrap` installs just
- [ ] `just install_full` works
- [ ] `just doctor` detects issues
- [ ] `just update` updates everything
- [ ] `just stow nvim` creates symlinks
- [ ] `just verify` checks installations

**macOS:**

- [ ] Same as Linux
- [ ] Homebrew integration works

**Windows (PowerShell 7):**

- [ ] `just bootstrap` installs just
- [ ] `just win_install_packages pro` works
- [ ] `just win_stow wezterm` creates symlinks
- [ ] `just doctor` detects issues

### 10.2 Automated Testing (Future)

**Pre-commit hook**:

```bash
just test  # Runs lint, format check, dry-run tests
```

**CI/CD (GitHub Actions)**:

```yaml
# .github/workflows/test.yml
- name: Test justfile
  run: |
    just --summary  # Validate syntax
    just test       # Run tests
```

### 10.3 Dry-Run Support

Many recipes support `--dry-run`:

```bash
just stow_dry_run nvim     # Show what would be stowed
just install_dry_run mise  # Show what would be installed
```

---

## 11. Success Metrics

### 11.1 User Experience Metrics

✅ **Discoverability**: Users can find commands via `just --list`
✅ **Simplicity**: Common tasks are 1-2 word commands
✅ **Consistency**: Same commands work across OS
✅ **Documentation**: Inline help via descriptions

### 11.2 Functional Metrics

✅ **Coverage**: 90%+ of existing scripts have just recipes
✅ **Backward Compatibility**: All existing scripts still work
✅ **New Features**: doctor, verify, update, sync recipes added
✅ **Cross-Platform**: Works on Linux, macOS, Windows

### 11.3 Adoption Metrics

✅ **Documentation**: README updated with just examples
✅ **Default**: Recommended in installation guide
✅ **Tested**: Works on 3+ platforms

---

## 12. Future Enhancements

### 12.1 Phase 2 Features (Post-Launch)

1. **Interactive Mode**: `just install` → menu (like current install.sh)
2. **Profiles**: `just install_profile work` → install work-specific tools
3. **Dependency Visualization**: `just show_dependencies` → ASCII tree
4. **Auto-Update**: `just self_update` → update justfile from git
5. **Hooks**: Pre/post hooks for customization

### 12.2 Community Contributions

- **Package-Specific Recipes**: Easy to add new tools
- **OS-Specific Enhancements**: Platform maintainers add recipes
- **Documentation**: Community examples

---

## 13. Migration Guide (For Users)

### 13.1 Before (Current)

```bash
# Full install
./install.sh --full

# Update
git pull
./_scripts/linux/sh/tools/manage-stow.sh restow
mise upgrade

# Verify
gcc --version
dotnet --version
# ... (many manual checks)
```

### 13.2 After (With Just)

```bash
# Full install
just install_full

# Update
just update

# Verify
just doctor
```

### 13.3 Compatibility

**All existing workflows still work!**
Just is an **additional interface**, not a replacement.

---

## 14. Workflow Analysis Summary

Based on comprehensive analysis of the dotfiles repository, the following workflows and gaps were identified:

### 14.1 Common User Workflows

1. **Fresh Installation on New Machine**
   - Current: `./install.sh` (interactive menu)
   - Proposed: `just install_full` or `just install_minimal`

2. **Update Existing Installation** ⭐ **HIGH PRIORITY GAP**
   - Current: Fragmented (git pull + mise upgrade + JS packages + restow)
   - Proposed: `just update` (single command)

3. **Manage Dotfiles (Stow/Unstow)**
   - Current: `manage-stow.sh` (works well)
   - Proposed: `just stow PKG`, `just restow`

4. **Add New Tool/Package**
   - Current: Manual multi-step process
   - Proposed: `just install_component TOOL`

5. **Post-Install Verification** ⭐ **HIGH PRIORITY GAP**
   - Current: Manual checks required
   - Proposed: `just doctor`, `just verify`

### 14.2 Identified Gaps & New Features

**High Priority (Phase 1-2):**

1. **Health Check / Doctor Command** - Comprehensive system diagnostics
2. **Unified Update Command** - Single command to update everything
3. **Verification Script** - Automated installation verification
4. **Smart Sync** - git pull + restow + verify in one command

**Medium Priority (Phase 3-4):**

5. **Component Installation** - Install specific tools without full reinstall
6. **Enhanced Backup Management** - List, restore, cleanup backups
7. **Rollback Support** - Remove specific components or undo installation

**Low Priority (Future):**

8. **Machine-Specific Overrides** - Local profiles per machine
9. **Dependency Visualization** - Show what depends on what
10. **Migration Guides** - Handle breaking changes gracefully

### 14.3 Pain Points Addressed

| Pain Point | Current Impact | Just Solution |
|-----------|----------------|---------------|
| **Multiple update commands** | High - confusing workflow | `just update` |
| **Manual verification** | High - error-prone | `just doctor` |
| **No clear next steps** | High - user confusion | Better completion message |
| **PATH issues** | Medium - requires restart | `just check_path` |
| **Stow conflicts** | Medium - no preview | `just stow_dry_run` |
| **Cross-platform differences** | Low - documentation issue | Unified `just` interface |

### 14.4 Simplification Opportunities

**Quick Wins** (High Value, Low Effort):

1. ✅ Create `doctor.sh` - comprehensive health check (~200 lines)
2. ✅ Create `verify.sh` - verification script (~150 lines)
3. ✅ Create `update.sh` - unified update command (~100 lines)
4. ✅ Improve completion message - clearer next steps (~20 lines)

**Medium-Term Improvements**:

5. ✅ Add `--component` flag to install.sh (~50 lines)
6. ✅ Enhanced backup management (~150 lines)
7. ✅ Justfile integration (this spec)

---

## 15. Appendix

### 15.1 Justfile Example (Main Entry)

```just
# Import all modules
import '.just/_helpers.just'
import '.just/install.just'
import '.just/stow.just'
import '.just/mise.just'
import '.just/verify.just'
import '.just/maintenance.just'
import '.just/windows.just'
import '.just/dev.just'

# Default recipe - show help
default:
    @just --list --unsorted

# Show detailed help
help:
    @echo "Dotfiles Management with Just"
    @echo ""
    @echo "Common Commands:"
    @echo "  just install_full        - Full installation"
    @echo "  just install_minimal     - Minimal installation"
    @echo "  just update              - Update everything"
    @echo "  just doctor              - Health check"
    @echo "  just stow PKG            - Stow package"
    @echo ""
    @echo "For full list: just --list"
    @echo "For specific help: just --show RECIPE"

# Bootstrap: Install just itself + basic setup
bootstrap:
    @echo "🚀 Bootstrapping dotfiles..."
    @./_scripts/just/bootstrap.sh
```

### 15.2 Module Example (verify.just)

```just
# verify.just - Health checks and verification recipes

# Run comprehensive health check
doctor:
    @echo "🏥 Running health check..."
    @_scripts/doctor.sh

# Verify all installations
verify:
    @echo "✅ Verifying installations..."
    @_scripts/verify.sh

# Verify core tools only
verify_core:
    @_scripts/verify.sh --core

# Check PATH configuration
check_path:
    @echo "🔍 Checking PATH..."
    @_scripts/verify.sh --path-only

# Check shell setup
check_shell:
    @echo "🐚 Checking shell setup..."
    @_scripts/verify.sh --shell-only
```

### 15.3 Module Example (maintenance.just)

```just
# maintenance.just - Update, backup, and cleanup recipes

# Update everything (git pull + mise + packages + restow)
update:
    @echo "🔄 Updating dotfiles..."
    git pull
    @echo "📦 Upgrading mise tools..."
    mise upgrade
    @echo "📦 Updating JS packages..."
    ./_scripts/linux/sh/installers/install-js-packages.sh --update || true
    @echo "🔗 Restowing configurations..."
    just restow
    @echo "✅ Update complete!"

# Sync dotfiles (quick git pull + restow)
sync:
    @echo "🔄 Syncing dotfiles..."
    git pull
    just restow
    @echo "✅ Sync complete!"

# Create backup of current configurations
backup_create:
    @echo "💾 Creating backup..."
    @./_scripts/linux/sh/tools/backup.sh

# List all backups
backup_list:
    @echo "📋 Available backups:"
    @ls -lh ~/.dotfiles-backup-* 2>/dev/null || echo "No backups found"

# Clean temporary files and old backups
clean:
    @echo "🧹 Cleaning up..."
    @find ~/.dotfiles-backup-* -type d -mtime +30 -exec rm -rf {} \; 2>/dev/null || true
    @echo "✅ Cleanup complete!"

# Uninstall dotfiles and restore backups
uninstall:
    @echo "⚠️  This will remove dotfiles and restore backups"
    @read -p "Are you sure? [y/N] " confirm && [ "$$confirm" = "y" ] || exit 1
    @./_scripts/linux/sh/tools/uninstall.sh
```

### 15.4 Implementation Checklist

When approved and ready to implement, create these files in order:

**Phase 1: Bootstrap & Core**

1. [ ] `_scripts/just/install-just.sh` - Install just (Linux/macOS)
2. [ ] `_scripts/just/install-just.ps1` - Install just (Windows)
3. [ ] `_scripts/just/bootstrap.sh` - One-command bootstrap
4. [ ] `.just/_helpers.just` - Shared variables, OS detection
5. [ ] `justfile` - Main entry point with imports
6. [ ] `.just/install.just` - Installation recipes
7. [ ] `.just/stow.just` - Stow management recipes
8. [ ] `.just/mise.just` - Mise recipes

**Phase 2: New Workflows**

9. [ ] `_scripts/doctor.sh` - Health check script (NEW)
10. [ ] `_scripts/verify.sh` - Verification script (NEW)
11. [ ] `.just/verify.just` - Doctor and verify recipes
12. [ ] `.just/maintenance.just` - Update, sync, backup recipes

**Phase 3: Cross-Platform & Polish**

13. [ ] `.just/windows.just` - Windows-specific recipes
14. [ ] `.just/dev.just` - Development recipes
15. [ ] Update `README.md` with just examples
16. [ ] Create `JUSTFILE.md` reference documentation
17. [ ] Update `.gitignore` to include `.justenv`

**Phase 4: Testing & Documentation**

18. [ ] Test on Linux (Debian/Ubuntu)
19. [ ] Test on macOS
20. [ ] Test on Windows (PowerShell 7)
21. [ ] Create usage examples and tutorials
22. [ ] Update CONTRIBUTING.md with just conventions

---

**End of Specification**

---

## Summary

This specification outlines a comprehensive plan to integrate `just` as a unified task runner for the dotfiles repository. The approach:

- **Wraps existing scripts** (no rewrites needed)
- **Adds missing workflows** (doctor, verify, update, sync)
- **Uses modular structure** (`.just/` folder with 8 modules)
- **Maintains backward compatibility** (all existing scripts still work)
- **Uses snake_case naming** (consistent with existing files)
- **Cross-platform support** (Linux, macOS, Windows)
- **50+ recipes planned** across 8 modules
- **4-phase implementation** (bootstrap → new features → polish → adoption)

**Next Step**: Await approval before implementation begins.
