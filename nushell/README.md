# Nushell

A new type of shell that works with structured data.

## Overview

Nushell (Nu) is a modern, cross-platform shell written in Rust that brings a fresh approach to shell scripting. Unlike traditional shells that work with raw text streams, Nushell treats data as structured information, making it easier to work with files, APIs, databases, and system commands.

## Key Features

- **Cross-platform**: Works seamlessly on Linux, macOS, BSD, and Windows
- **Structured data**: Everything is data - pipelines work with tables, records, and typed values
- **Built-in data formats**: Native support for JSON, YAML, TOML, CSV, XML, SQLite, Excel, and more
- **Modern UX**: Syntax highlighting, autocompletion, and helpful error messages
- **Functional approach**: Immutable data structures and functional programming concepts
- **Extensible**: Powerful plugin system for adding custom functionality

## Installation

### macOS / Linux

**Using Homebrew:**

```bash
brew install nushell
```

**Using Nix:**

```bash
nix profile install nixpkgs#nushell
```

### Windows

**Using winget:**

```powershell
winget install nushell
```

### Other Methods

- Download pre-built binaries from [GitHub Releases](https://github.com/nushell/nushell/releases)
- Install via package managers: See [Repology](https://repology.org/project/nushell/versions) for all available packages
- Build from source: Clone the [repository](https://github.com/nushell/nushell) and run `cargo install --path .`

## Quick Start

After installation, launch Nushell by typing:

```bash
nu
```

### Basic Examples

**List files as structured data:**

```nushell
ls | where type == "dir" | sort-by size
```

**Work with JSON data:**

```nushell
open data.json | get items | where price > 100
```

**Fetch data from APIs:**

```nushell
http get https://api.github.com/repos/nushell/nushell | get stargazers_count
```

**Process CSV files:**

```nushell
open data.csv | where status == "active" | select name email | save filtered.csv
```

## Configuration

Nushell stores its configuration files in the standard config directory:

- **Linux/macOS**: `~/.config/nushell/`
- **Windows**: `%APPDATA%\nushell\`

Main configuration files:

- `config.nu` - Main Nushell configuration
- `env.nu` - Environment variables and startup commands

To locate your config path in Nu:

```nushell
$nu.config-path
```

Default configurations are available at the [sample_config](https://github.com/nushell/nushell/tree/main/crates/nu-utils/src/default_files) directory.

## Documentation

- **[The Nushell Book](https://www.nushell.sh/book/)** - Comprehensive guide and tutorials
- **[Command Reference](https://www.nushell.sh/commands/)** - Complete list of built-in commands
- **[Cookbook](https://www.nushell.sh/cookbook/)** - Practical examples and recipes
- **[Language Guide](https://www.nushell.sh/lang-guide/)** - In-depth language reference

## Community

- **Discord**: [Join the Nushell Discord](https://discord.gg/NtAbbGn)
- **GitHub**: [nushell/nushell](https://github.com/nushell/nushell)
- **Website**: [www.nushell.sh](https://www.nushell.sh/)

## Philosophy

Nushell follows these core principles:

1. **Cross-platform first** - Commands work the same everywhere
2. **Structured data** - Treat everything as typed, structured information
3. **Modern usability** - Contemporary UX expectations (autocomplete, syntax highlighting, etc.)
4. **Compatibility** - Works alongside existing platform tools
5. **Functional approach** - Pipelines transform data without mutation

## License

Nushell is released under the [MIT License](https://github.com/nushell/nushell/blob/main/LICENSE).
