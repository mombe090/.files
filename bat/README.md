# Bat Configuration

Enhanced `cat` replacement with syntax highlighting and Git integration.

## What is Bat?

Bat is a `cat` clone with syntax highlighting, Git integration, line numbers, and automatic paging. It supports over 200 programming languages.

## Features

- **Theme**: TwoDark (Atom-inspired dark theme)
- **Display**: Line numbers, Git changes, file headers
- **Paging**: Disabled by default for quick viewing
- **Custom Syntax Mappings**:
  - `*.ino` files as C++
  - `.ignore` files as Git Ignore syntax

## Installation

```bash
stow bat
```

## Usage

```bash
bat file.txt              # View file with syntax highlighting
bat file1.txt file2.txt   # View multiple files
bat -A file.txt           # Show non-printable characters
```

Aliased as `cat` in zsh configuration, so just use:

```bash
cat file.txt  # Actually uses bat
```

## Customization

Edit `~/.config/bat/config` to:

- Change theme (`--theme`)
- Modify style (`--style`)
- Enable paging (`--paging=auto`)
