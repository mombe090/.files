# UV Package Structure Summary

## Overview

The UV package manages Python tools via UV (which is installed via mise) using a virtual environment at `~/.venv`.

## Clear Separation of Concerns

### Tools Installed via mise (CLI tools)
These are in `mise/.config/mise/config.toml`:
- **uv** - Fast Python package manager (line 88)
- **ruff** - Python linter & formatter (line 87)
- Other non-Python tools...

### Tools Installed via UV/venv (Python packages)
These are in `uv/pyproject.toml` and installed in `~/.venv`:
- **checkov** - IaC security scanner
- **ty** - Python type checker and formatter
- **ansible** - Configuration management
- **ansible-lint** - Ansible linter
- **pytest** - Testing framework
- **httpie** - HTTP client
- **ipython** - Enhanced REPL
- **rich** - Terminal formatting
- **pyyaml, toml, jinja2** - Utilities

## Directory Structure

```
uv/
├── .config/
│   └── uv/
│       └── uv.toml              # UV configuration
├── pyproject.toml               # Python dependencies
├── README.md                    # Documentation
└── STRUCTURE.md                 # This file
```

When stowed:
```
~/
├── .config/uv/uv.toml          # Symlinked from uv/.config/uv/uv.toml
├── pyproject.toml              # Symlinked from uv/pyproject.toml
└── .venv/                      # Created by uv venv
    ├── bin/
    │   ├── checkov
    │   ├── ansible
    │   ├── pytest
    │   ├── ipython
    │   └── ...
    ├── lib/
    └── pyvenv.cfg
```

## Why This Structure?

1. **pyproject.toml at ~/** - Standard location for Python project
2. **UV config at ~/.config/uv/** - Standard UV configuration location
3. **Virtual environment at ~/.venv** - Isolated Python environment
4. **PATH includes ~/.venv/bin** - Tools automatically available
5. **UV via mise** - Don't install UV as a Python package when it's already via mise
6. **Ruff via mise** - CLI tools better managed by mise than pip

## Usage Flow

1. **Install mise tools** (includes UV and ruff):
   ```bash
   mise install
   ```

2. **Stow UV package** (creates ~/pyproject.toml):
   ```bash
   cd ~/.files
   ./scripts/manage-stow.sh stow uv
   ```

3. **Create venv and install Python packages**:
   ```bash
   ./scripts/install-uv-tools.sh install
   # or manually:
   cd ~
   uv venv          # Creates ~/.venv
   uv sync          # Installs packages from pyproject.toml
   ```

4. **Use the tools** (automatically in PATH):
   ```bash
   checkov -d ./terraform      # From ~/.venv/bin
   ruff check .                # From mise
   ty check .                  # From ~/.venv/bin
   ansible-playbook play.yml   # From ~/.venv/bin
   ```

## PATH Configuration

In `zsh/.config/zsh/env.zsh`:
```bash
# UV virtual environment for global Python tools
export PATH="$HOME/.venv/bin:$PATH"
```

This makes all tools in the virtual environment available without activation.

## UV Commands

### Create virtual environment
```bash
cd ~
uv venv          # Creates ~/.venv using system Python
```

### Sync packages
```bash
cd ~
uv sync          # Installs all dependencies from pyproject.toml
uv sync --extra data    # Also install data science extras
uv sync --upgrade       # Update all packages
```

### List packages
```bash
~/.venv/bin/pip list
```

## Key Benefits

- ✅ **No duplication** - UV installed once via mise
- ✅ **Clear separation** - CLI tools (mise) vs Python packages (UV/venv)
- ✅ **Standard locations** - ~/.config/uv/, ~/pyproject.toml, ~/.venv
- ✅ **Isolated environment** - No conflicts with system Python
- ✅ **Global availability** - All tools in PATH via ~/.venv/bin
- ✅ **Easy updates** - `mise upgrade` for mise tools, `uv sync --upgrade` for Python tools
- ✅ **Reproducible** - `uv sync` ensures exact package versions
- ✅ **Fast** - UV is 10-100x faster than pip

## What Gets Stowed

```bash
~/.files/uv/pyproject.toml          → ~/pyproject.toml
~/.files/uv/.config/uv/uv.toml      → ~/.config/uv/uv.toml
```

The stow command creates these symlinks, making the configuration and package list available.

## What Gets Created by UV

```bash
~/.venv/                             # Virtual environment
~/.venv/bin/                         # Executables (checkov, ansible, pytest, etc.)
~/.venv/lib/python3.x/site-packages/ # Installed packages
```

## Workflow Example

```bash
# Initial setup
cd ~/.files
./scripts/manage-stow.sh stow uv
./scripts/install-uv-tools.sh install

# Add a new package
echo 'requests>=2.31.0' >> ~/pyproject.toml  # Add to dependencies
cd ~ && uv sync                               # Install

# Update all packages
cd ~ && uv sync --upgrade

# Install with extras
./scripts/install-uv-tools.sh install data   # Data science tools
./scripts/install-uv-tools.sh install aws    # AWS/Azure tools
```

## Comparison: uv pip vs uv venv + sync

### Old way (uv pip):
```bash
uv pip install -e .      # Installs to system or active venv
```

### New way (uv venv + sync):
```bash
uv venv                  # Create isolated venv at ~/.venv
uv sync                  # Install from pyproject.toml
```

**Advantages of venv + sync:**
- Isolated from system Python
- Reproducible (lockfile support)
- Faster
- Better dependency resolution
- Standard workflow
