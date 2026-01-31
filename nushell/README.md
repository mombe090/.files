# Nushell Configuration

Modern shell with structured data pipelines and powerful scripting capabilities.

## Overview

[Nushell](https://www.nushell.sh/) is a new kind of shell that operates on structured data. It treats everything as structured data (like tables), making it easier to work with output from commands, APIs, and files.

## Key Features

- **Cross-platform**: Works seamlessly on Linux, macOS, BSD, and Windows
- **Structured data**: Everything is data - pipelines work with tables, records, and typed values
- **Built-in data formats**: Native support for JSON, YAML, TOML, CSV, XML, SQLite, Excel, and more
- **Modern UX**: Syntax highlighting, autocompletion, and helpful error messages
- **Functional approach**: Immutable data structures and functional programming concepts
- **Extensible**: Powerful plugin system for adding custom functionality

## Installation

### Automated Installation

Use the provided script to install Nushell:

```bash
./scripts/install-nushell.sh
```

**macOS**: Installs via Homebrew
**Linux**: Downloads and installs the latest binary release to `~/.local/bin`

### Manual Installation

**macOS:**
```bash
brew install nushell
```

**Linux:**
Download from [Nushell releases](https://github.com/nushell/nushell/releases)

**Linux:**
Download from [Nushell releases](https://github.com/nushell/nushell/releases)

## Configuration Files

After stowing (`./scripts/manage-stow.sh stow nushell`), the following files will be symlinked:

- `~/.config/nushell/env.nu` - Environment configuration (runs first)
- `~/.config/nushell/config.nu` - Shell configuration (runs second)

## Features

### Environment (`env.nu`)

- **Editor**: Configured to use `nvim`
- **PATH Management**: Automatically includes:
  - `~/.local/bin`
  - `~/.venv/bin` (Python UV tools)
  - `~/.bun/bin`
  - `~/.cargo/bin`
- **Mise Integration**: Automatically activates mise-managed tools
- **Homebrew Integration**: Auto-detects Apple Silicon vs Intel macOS

### Shell Configuration (`config.nu`)

- **Edit Mode**: Vi keybindings by default
- **History**: SQLite-based with 100k entries
- **Completions**: Case-insensitive, quick, partial matching
- **Shell Integration**: OSC sequences for better terminal integration
- **Color Scheme**: Carefully chosen colors for readability
- **Table Display**: Rounded borders, auto-wrapping

### Aliases

**Basic Navigation:**
- `ll` → `ls -l`
- `la` → `ls -a`
- `lla` → `ls -la`
- `..` → `cd ..`
- `...` → `cd ../..`

**Git:**
- `g` → `git`
- `gs` → `git status`
- `ga` → `git add`
- `gc` → `git commit`
- `gp` → `git push`
- `gl` → `git pull`

**Modern Tools** (if installed):
- `cat` → `bat` (syntax highlighting)
- `ls` → `eza --icons` (better ls)

### Custom Commands

- `dotfiles` - Jump to ~/.files directory
- `nu-config` - Edit config.nu
- `nu-env` - Edit env.nu
- `nu-reload` - Reload Nushell configuration

## Usage

### Starting Nushell

```bash
nu
```

### Structured Data Examples

### Structured Data Examples

```nushell
# List files as a table
ls | where size > 1mb | sort-by modified

# Work with JSON
curl https://api.github.com/repos/nushell/nushell | from json | get stargazers_count

# Pipeline operations
ps | where cpu > 10 | sort-by cpu | reverse | first 10

# CSV manipulation
open data.csv | where age > 25 | sort-by name | save filtered.csv
```

### Custom Commands

```nushell
# Jump to dotfiles
dotfiles

# Edit Nushell config
nu-config

# Reload configuration
nu-reload
```

## Keybindings

**Vi Mode** (default):
- `Tab` - Completion menu
- `Ctrl+R` - History search
- `Ctrl+L` - Clear screen
- Normal vi motions work (hjkl, w, b, etc.)

**Insert Mode:**
- Default insert mode keybindings
- `Esc` to enter normal mode

## Directory Structure

```
nushell/
└── .config/
    └── nushell/
        ├── env.nu        # Environment configuration
        └── config.nu     # Shell configuration
```

## Troubleshooting

### Command not found after installation

**Linux users**: Ensure `~/.local/bin` is in your PATH:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Add to your `.bashrc` or `.zshrc` for persistence.

### Mise not activating

The `env.nu` includes mise activation. If it doesn't work:

```nushell
# Check if mise is available
which mise

# Manually activate
mise activate nu | save ~/.config/nushell/mise.nu
source ~/.config/nushell/mise.nu
```

### Config changes not applied

Reload configuration:

```nushell
nu-reload
```

Or restart Nushell:

```bash
exit
nu
```

## Documentation and Resources

## Documentation and Resources

- **[The Nushell Book](https://www.nushell.sh/book/)** - Comprehensive guide and tutorials
- **[Command Reference](https://www.nushell.sh/commands/)** - Complete list of built-in commands
- **[Cookbook](https://www.nushell.sh/cookbook/)** - Practical examples and recipes
- **[Language Guide](https://www.nushell.sh/lang-guide/)** - In-depth language reference
- **[Discord](https://discord.gg/NtAbbGn)** - Join the Nushell community
- **[GitHub](https://github.com/nushell/nushell)** - Source code and issues

## Tips

1. **View as Table**: Most command outputs are automatically formatted as tables
2. **Column Selection**: Use `select column1 column2` to pick specific columns
3. **Filtering**: Use `where condition` to filter rows
4. **Data Formats**: Built-in support for JSON, YAML, TOML, CSV, XML
5. **Type System**: Everything has a type - use `describe` to see it

## Version

Tested with Nushell 0.99+

