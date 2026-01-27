# Mise Installation

Install [mise](https://mise.jdx.dev) to manage all development tools from `.mise.toml`.

## Quick Start

```bash
# 1. Install mise
./scripts/install-mise.sh

# 2. Activate in current shell
source ~/.zshrc

# 3. Install all tools from .mise.toml
cd ~/.files
mise install
```

## Files

- **`.mise.toml`** - Defines all tools and versions
- **`install-mise.sh`** - Installs mise + configures shell

## Common Commands

```bash
mise install           # Install all tools from .mise.toml
mise list              # Show installed tools
mise upgrade           # Update all tools
mise use node@20       # Pin specific version
mise doctor            # Verify installation
```

## Customization

Edit `.mise.toml` to add/remove tools or pin versions:

```toml
[tools]
node = "20.0.0"        # Pin version
python = "latest"      # Use latest
```
