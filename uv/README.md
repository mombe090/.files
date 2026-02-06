# UV Python Tools Management

This package manages global Python tools using [UV](https://docs.astral.sh/uv/) with a virtual environment.

## Overview

UV is a fast Python package installer and resolver written in Rust. This dotfiles package:
- Configures UV settings via `~/.config/uv/uv.toml`
- Manages Python tools via `~/pyproject.toml`
- Creates a virtual environment at `~/.venv` for global tools
- Automatically adds `~/.venv/bin` to PATH

## Structure

```
uv/
├── .config/uv/uv.toml      # UV configuration
└── pyproject.toml          # Python dependencies
```

When stowed, creates:
- `~/.config/uv/uv.toml` - UV config
- `~/pyproject.toml` - Python project file
- `~/.venv/` - Virtual environment (created on first install)

## Installed Tools

### Security & Infrastructure as Code
- **checkov** - Security scanner for IaC (Terraform, K8s, Docker, etc.)

### Development Tools
- **ty** - Python type checker and formatter
- **pytest** - Testing framework
- **ruff** - Fast Python linter & formatter (installed via mise, not pip)

### DevOps & Cloud
- **ansible** - Configuration management
- **ansible-lint** - Ansible best practices linter

### Utilities
- **httpie** - Modern HTTP client
- **ipython** - Enhanced Python REPL
- **rich** - Rich terminal output library
- **pyyaml** - YAML parser
- **jinja2** - Template engine

## Usage

### Initial Setup

```bash
# Stow the UV package
cd ~/.files
./_scripts/linux/sh/tools/manage-stow.sh stow uv

# Install all tools (creates ~/.venv and syncs packages)
./_scripts/linux/sh/installers/install-uv-tools.sh install
```

### Install Optional Dependencies

```bash
# Data science tools
./_scripts/linux/sh/installers/install-uv-tools.sh install data

# AWS/Azure tools
./_scripts/linux/sh/installers/install-uv-tools.sh install aws
```

### Managing Tools

```bash
# Add a new tool to pyproject.toml dependencies array, then:
cd ~
uv sync

# Update all tools
./_scripts/linux/sh/installers/install-uv-tools.sh update
# or
cd ~ && uv sync --upgrade

# List installed tools
./_scripts/linux/sh/installers/install-uv-tools.sh list

# Sync tools (install missing, remove unused)
./_scripts/linux/sh/installers/install-uv-tools.sh sync
```

### Using the Tools

All installed tools are available in your PATH (via `~/.venv/bin`):

```bash
# Security scanning
checkov -d ./terraform

# Code formatting (ruff via mise)
ruff format script.py

# Linting (ruff via mise)
ruff check .

# Type checking with ty
ty check .

# Testing
pytest tests/

# HTTP requests
http GET https://api.github.com

# Ansible
ansible-playbook playbook.yml

# Enhanced Python REPL
ipython
```

## Why UV with venv?

UV with virtual environments provides:
- 10-100x faster than pip
- Isolated dependencies (no conflicts with system Python)
- Better dependency resolution
- Automatic virtual environment management
- `uv sync` ensures exact reproducibility

## Virtual Environment

- **Location**: `~/.venv`
- **Activation**: Automatic via PATH (configured in `zsh/.config/zsh/env.zsh`)
- **PATH**: `~/.venv/bin` is prepended to PATH
- **Management**: UV handles creation and synchronization

No need to manually activate - tools are automatically available!

## Configuration

### UV Config (`~/.config/uv/uv.toml`)
Edit to customize UV behavior:
- Binary wheel preferences
- Cache settings
- System package usage

### Python Project (`~/pyproject.toml`)
Edit to:
- Add/remove Python tools
- Manage optional dependencies
- Configure tool-specific settings

## Workflow

```bash
# 1. Stow UV package
cd ~/.files && ./_scripts/linux/sh/tools/manage-stow.sh stow uv

# 2. Create venv and install tools
./_scripts/linux/sh/installers/install-uv-tools.sh install

# 3. Tools are now available in PATH
checkov --version
ansible --version
pytest --version

# 4. Add a new tool
# Edit ~/pyproject.toml, then:
uv sync

# 5. Update all tools
./_scripts/linux/sh/installers/install-uv-tools.sh update
```

## Troubleshooting

### Tools not in PATH

Ensure `~/.venv/bin` is in your PATH. This is configured in `zsh/.config/zsh/env.zsh`:
```bash
export PATH="$HOME/.venv/bin:$PATH"
```

Restart your shell:
```bash
exec $SHELL -l
```

### Upgrade UV

```bash
# Via mise (recommended)
mise upgrade uv
```

### Recreate virtual environment

```bash
rm -rf ~/.venv
./_scripts/linux/sh/installers/install-uv-tools.sh install
```

### Clear UV cache

```bash
uv cache clean
```

## Integration with Dotfiles

This package integrates with:
- **mise** - UV itself is installed via mise
- **zsh** - `~/.venv/bin` added to PATH in env.zsh
- **stow** - Package managed via stow

When you run `mise install`, UV is automatically installed.
When you stow this package, the config and pyproject.toml are symlinked.
When you run the install script, the venv is created and tools are synced.

## References

- [UV Documentation](https://docs.astral.sh/uv/)
- [UV GitHub](https://github.com/astral-sh/uv)
- [Python Packaging Guide](https://packaging.python.org/)
