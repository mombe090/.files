# Mombe090 Dotfiles

Welcome to the comprehensive documentation for my cross-platform dotfiles and configurations.

## 🎯 Quick Navigation

<div class="grid cards" markdown>

-   :material-rocket-launch: **Just Integration Specification**

    ---

    Modern task runner integration for unified command interface across all platforms.

    [:octicons-arrow-right-24: Read the spec](specs/just-integration/specification.md)

-   :material-package-variant: **Installation Guide**

    ---

    Get started with installing and configuring your development environment.

    [:octicons-arrow-right-24: Install now](specs/just-integration/getting-started/installation.md)

-   :material-book-open-variant: **Usage Guide**

    ---

    Learn common workflows and best practices.

    [:octicons-arrow-right-24: Learn more](specs/just-integration/usage/workflows.md)

-   :material-code-braces: **Development**

    ---

    Contribute to the project and understand design decisions.

    [:octicons-arrow-right-24: Contribute](specs/just-integration/development/contributing.md)

</div>

## 📚 Overview

This documentation covers:

- **Just Integration** - Modern task runner for unified command interface (2026-02-04)
- Cross-platform dotfiles (Linux, macOS, Windows)
- Installation and configuration workflows
- Development and contribution guidelines

## 🚀 What's New

### Just Integration Specification (2026-02-04)

A comprehensive plan to integrate `just` as a unified task runner, providing:

- ✅ Consistent commands across all platforms
- ✅ 50+ recipes organized in modular files
- ✅ New workflows: `doctor`, `verify`, `update`, `sync`
- ✅ Self-documenting via `just --list`
- ✅ Backward compatible with existing scripts

[Read the full specification →](specs/just-integration/specification.md)

## 💡 Key Features

- **Cross-Platform**: Linux, macOS, Windows support
- **Modular**: Clean separation of concerns
- **Modern Tools**: mise, stow, zsh, neovim, and more
- **Well Documented**: Comprehensive specs and guides
- **Battle Tested**: Proven scripts with just as friendly interface

## 🛠️ Technology Stack

<div class="grid cards" markdown>

-   **Task Runner**

    `just` - Modern command runner

-   **Package Manager**

    `mise` - Universal tool version manager

-   **Symlink Manager**

    `stow` - GNU Stow for dotfiles

-   **Shell**

    `zsh` with Zinit plugin manager

-   **Editor**

    `neovim` with LazyVim

-   **Terminal**

    `alacritty`, `ghostty`, `wezterm`

</div>

## 📖 Documentation Structure

```
docs/
└── specs/
    └── just-integration/
        ├── specification.md        # Main specification
        ├── architecture.md         # Architecture details
        ├── recipes.md              # Recipe reference
        ├── implementation.md       # Implementation plan
        ├── getting-started/        # Installation guides
        ├── usage/                  # Usage examples
        ├── development/            # Development docs
        └── reference/              # Technical reference
```

## 🤝 Contributing

Contributions are welcome! Check out:

- [Contributing Guide](specs/just-integration/development/contributing.md)
- [Testing Guide](specs/just-integration/development/testing.md)
- [Design Decisions](specs/just-integration/development/decisions.md)

## 📜 License

MIT License - Feel free to use and modify for your own needs.

---

**Last Updated**: February 4, 2026
