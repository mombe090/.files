# Neovim Configuration

LazyVim-based Neovim configuration with custom plugins and settings.

## What is LazyVim?

LazyVim is a Neovim configuration framework that provides a solid foundation with lazy-loaded plugins, LSP support, and modern development features.

## Features

- **Plugin Manager**: lazy.nvim with lazy loading
- **LSP**: Full language server protocol support
- **AI**: Copilot and AI integrations
- **Completion**: Blink.cmp for fast completion
- **UI**: Custom lualine, file explorer, transparency
- **Navigation**: Harpoon for quick file navigation

## Installation

```bash
stow nvim
```

## Structure

```text
~/.config/nvim/
├── init.lua              # Entry point
├── lua/
│   ├── config/          # Core configuration
│   │   ├── autocmds.lua
│   │   ├── keymaps.lua
│   │   ├── lazy.lua     # Plugin manager setup
│   │   └── options.lua
│   └── plugins/         # Plugin configurations
│       ├── ai.lua
│       ├── coding.lua
│       ├── copilot.lua
│       └── ...
└── plugin/after/        # Post-load configurations
```

## Usage

```bash
nvim                    # Launch Neovim
:Lazy                   # Plugin manager UI
:Mason                  # LSP/tool installer
:checkhealth            # Verify installation
```

## Key Plugins

- **Blink.cmp**: Fast completion engine
- **Copilot**: AI pair programming
- **Harpoon**: Quick file navigation
- **File Explorer**: Neo-tree or similar
- **Lualine**: Status line

## Customization

Add plugins in `~/.config/nvim/lua/plugins/` following LazyVim conventions.

## Documentation

- LazyVim: <https://lazyvim.github.io/>
- Neovim: <https://neovim.io/doc/>
