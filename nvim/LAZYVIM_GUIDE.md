# LazyVim & Neovim Lua Plugin Guide

## Table of Contents

- [Understanding the Architecture](#understanding-the-architecture)
- [How Lazy.nvim Works](#how-lazynvim-works)
- [LazyVim Structure](#lazyvim-structure)
- [Creating Custom Plugins](#creating-custom-plugins)
- [Plugin Configuration Patterns](#plugin-configuration-patterns)
- [Essential Commands](#essential-commands)
- [Your Current Setup](#your-current-setup)

---

## Understanding the Architecture

### The Bootstrap Process

When Neovim starts, it follows this flow:

```text
init.lua → config/lazy.lua → lazy.nvim (plugin manager) → LazyVim → Your plugins
```

**File: `init.lua`** (Entry point)

```lua
require("config.lazy")
```

This single line starts everything. It loads `lua/config/lazy.lua`.

**File: `lua/config/lazy.lua`** (Bootstrap & Configuration)

```lua
-- 1. Check if lazy.nvim exists, if not clone it
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath
  })
end

-- 2. Add lazy.nvim to runtime path
vim.opt.rtp:prepend(lazypath)

-- 3. Setup lazy.nvim with plugin specs
require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },  -- LazyVim base
    { import = "plugins" },  -- Your custom plugins from lua/plugins/
  },
})
```

---

## How Lazy.nvim Works

### Core Concepts

**1. Lazy Loading**
Plugins load only when needed, not at startup:

```lua
{
  "plugin-name",
  event = "VeryLazy",     -- Load after startup
  cmd = "Command",        -- Load when command is run
  keys = "<leader>x",     -- Load when key is pressed
  ft = "python",          -- Load for specific filetype
}
```

**2. Plugin Specification**
Each plugin is a Lua table with properties:

```lua
{
  "username/repo-name",           -- GitHub repo (required)
  dependencies = { "other/plugin" }, -- Dependencies
  config = function() end,        -- Setup code
  opts = {},                      -- Options (shortcut for config)
  enabled = true,                 -- Enable/disable
  lazy = true,                    -- Lazy load?
  priority = 1000,                -- Load order (higher = earlier)
}
```

**3. Return Tables**
Every file in `lua/plugins/` must return a table or array:

```lua
-- Single plugin
return {
  "plugin/name",
  opts = {},
}

-- Multiple plugins
return {
  { "plugin/one" },
  { "plugin/two" },
}
```

---

## LazyVim Structure

### Directory Layout

```text
~/.config/nvim/
├── init.lua                    # Entry point
├── lua/
│   ├── config/                # Core configuration
│   │   ├── lazy.lua          # Lazy.nvim bootstrap
│   │   ├── options.lua       # Vim options (set commands)
│   │   ├── keymaps.lua       # Keybindings
│   │   └── autocmds.lua      # Autocommands
│   └── plugins/              # Your custom plugins
│       ├── example.lua       # Plugin examples (disabled)
│       ├── harpoon.lua       # Custom plugin config
│       └── *.lua             # Each file auto-loaded
└── lazyvim.json              # LazyVim extras config
```

### How Files Load

1. **Auto-loading**: Every `.lua` file in `lua/plugins/` is automatically imported
2. **Merging**: LazyVim merges your configs with its defaults
3. **Override**: Your settings override LazyVim's defaults

---

## Creating Custom Plugins

### Pattern 1: Add New Plugin

```lua
-- lua/plugins/my-plugin.lua
return {
  "author/plugin-name",
  dependencies = { "required/plugin" },
  config = function()
    require("plugin-name").setup({
      option1 = true,
      option2 = "value",
    })
  end,
}
```

### Pattern 2: Configure Existing Plugin

```lua
-- Override LazyVim's telescope config
return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      layout_strategy = "horizontal",
    },
  },
}
```

### Pattern 3: Disable Plugin

```lua
return {
  "plugin/name",
  enabled = false,
}
```

### Pattern 4: Add Keybindings

```lua
return {
  "plugin/name",
  keys = {
    { "<leader>x", "<cmd>Command<cr>", desc = "Description" },
    {
      "<leader>y",
      function()
        require("plugin").do_something()
      end,
      desc = "Do something"
    },
  },
}
```

---

## Plugin Configuration Patterns

### The `opts` Shortcut

These are equivalent:

```lua
-- Long form
{
  "plugin/name",
  config = function()
    require("plugin").setup({
      option = true,
    })
  end,
}

-- Short form (opts)
{
  "plugin/name",
  opts = {
    option = true,
  },
}
```

### Extending Options (Function Form)

When you need to merge with defaults:

```lua
{
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    -- opts contains LazyVim's defaults
    vim.list_extend(opts.ensure_installed, {
      "bash",
      "lua",
      "python",
    })
  end,
}
```

### Dependencies with Configuration

```lua
{
  "main/plugin",
  dependencies = {
    {
      "dependency/plugin",
      config = function()
        -- Configure dependency
      end,
    },
  },
}
```

---

## Essential Commands

### Lazy.nvim Commands

```vim
:Lazy              " Open Lazy UI
:Lazy sync         " Install/Update/Clean plugins
:Lazy update       " Update plugins
:Lazy clean        " Remove unused plugins
:Lazy check        " Check for updates
:Lazy log          " Show recent updates
:Lazy profile      " Show startup time
```

### LazyVim Commands

```vim
:LazyExtras        " Browse/Install LazyVim extras
:LazyHealth        " Check health
:LazyRoot          " Show project root detection
```

### Mason (LSP/Tools Manager)

```vim
:Mason             " Open Mason UI
:MasonUpdate       " Update Mason packages
:MasonLog          " Show Mason logs
```

---

## Your Current Setup

### Enabled LazyVim Extras

From your `lazyvim.json`:

**AI:**

- `copilot` - GitHub Copilot
- `copilot-chat` - Copilot Chat

**Languages:**

- ansible, docker, git, helm, java, json, markdown
- python, ruby, tailwind, terraform, toml, typescript, yaml

**Coding:**

- `yanky` - Better yank/paste

**Editor:**

- `neo-tree` - File explorer

**Utilities:**

- `dot` - Dotfile support

### Your Custom Plugins

**1. Harpoon** (`lua/plugins/harpoon.lua`)
Quick file navigation:

```text
<leader>H  - Mark file
<leader>h  - Show marks
<leader>1-5 - Jump to file 1-5
```

**How it works:**

```lua
return {
  "theprimeagen/harpoon",
  branch = "harpoon2",                    -- Use v2 branch
  dependencies = { "nvim-lua/plenary.nvim" }, -- Required dependency
  config = function()
    require("harpoon"):setup()            -- Initialize plugin
  end,
  keys = {                                -- Lazy-load on these keys
    {
      "<leader>H",
      function()
        require("harpoon"):list():append()  -- Call Lua API
      end,
      desc = "harpoon file",
    },
    -- ... more keybindings
  },
}
```

**Key concepts:**

- `branch = "harpoon2"` - Uses specific branch
- `dependencies` - Ensures plenary.nvim loads first
- `config` - Runs setup function
- `keys` - Lazy loads only when keys are pressed
- `function()` - Call plugin API with Lua

---

## Deep Dive: How Plugins Work

### 1. Plugin Loading Lifecycle

```text
Startup → Check keys/events/cmds → Need plugin? → Load → Run config → Ready
```

### 2. The Setup Pattern

Most plugins follow this pattern:

```lua
require("plugin-name").setup({
  -- Configuration options
})
```

Why? Because:

- It's a Lua convention
- Allows runtime configuration
- Separates plugin code from user config

### 3. Lua Module System

```lua
-- Plugin provides this module:
-- ~/.local/share/nvim/lazy/plugin-name/lua/plugin-name/init.lua
return {
  setup = function(opts)
    -- Plugin initialization
  end,
  some_function = function()
    -- Plugin API
  end,
}

-- You call it like this:
require("plugin-name").setup()
require("plugin-name").some_function()
```

### 4. Event System

Plugins can hook into Neovim events:

```lua
{
  "plugin/name",
  event = "BufReadPre",  -- When? Before reading buffer
  config = function()
    -- What? Setup plugin
  end,
}
```

Common events:

- `VeryLazy` - After startup
- `BufReadPre` - Before opening file
- `InsertEnter` - Entering insert mode
- `LspAttach` - When LSP connects

### 5. Keybinding Pattern

```lua
keys = {
  {
    "keys",           -- What to press
    "command",        -- What to execute (string)
    desc = "text",    -- Description (shows in which-key)
    mode = "n",       -- Mode (n=normal, v=visual, i=insert)
  },
  {
    "keys",
    function()        -- Or use Lua function
      -- Custom logic
    end,
    desc = "text",
  },
}
```

---

## Practical Examples

### Example 1: Add a New Plugin

Let's add `vim-surround` for quote/bracket manipulation:

```lua
-- lua/plugins/surround.lua
return {
  "kylechui/nvim-surround",
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({})
  end,
}
```

### Example 2: Customize Telescope

```lua
-- lua/plugins/telescope.lua
return {
  "nvim-telescope/telescope.nvim",
  keys = {
    -- Add custom keybinding
    {
      "<leader>fC",
      "<cmd>Telescope colorscheme<cr>",
      desc = "Find Colorscheme",
    },
  },
  opts = {
    defaults = {
      file_ignore_patterns = { "node_modules", ".git/" },
    },
  },
}
```

### Example 3: Add LSP Server

```lua
-- lua/plugins/lsp.lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      bashls = {},  -- Bash language server
      gopls = {     -- Go language server with options
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
          },
        },
      },
    },
  },
}
```

### Example 4: Add Mason Tools

```lua
-- lua/plugins/mason.lua
return {
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      "stylua",      -- Lua formatter
      "shfmt",       -- Shell formatter
      "prettier",    -- JS/TS/JSON formatter
      "ruff",        -- Python linter
    },
  },
}
```

---

## Debugging Tips

### 1. Check Plugin Status

```vim
:Lazy
```

Look for:

- Red X = Not loaded
- Green check = Loaded
- Clock = Lazy (not yet loaded)

### 2. Profile Startup Time

```vim
:Lazy profile
```

See which plugins slow down startup.

### 3. Test Plugin Loading

```lua
-- Add to plugin spec
config = function()
  print("Plugin loaded!")
  require("plugin").setup()
end,
```

### 4. Check Keybindings

```vim
:Telescope keymaps
```

Shows all active keybindings.

### 5. Inspect Plugin Options

```lua
:lua =require("plugin")
```

---

## Common Patterns in Your Config

### Pattern: Import LazyVim Extra

```lua
-- lua/config/lazy.lua
{ import = "lazyvim.plugins.extras.lang.python" }
```

This imports pre-configured Python support (LSP, formatters, linters).

### Pattern: Multiple Plugins in One File

```lua
-- lua/plugins/ui.lua
return {
  { "plugin/one", opts = {} },
  { "plugin/two", opts = {} },
  { "plugin/three", opts = {} },
}
```

Organize related plugins together.

### Pattern: Conditional Configuration

```lua
return {
  "plugin/name",
  cond = function()
    return vim.fn.executable("command") == 1
  end,
}
```

Only enable if command exists.

---

## Next Steps

1. **Explore LazyVim Extras**: `:LazyExtras` to see available configs
2. **Read Plugin Docs**: Check GitHub repos for API documentation
3. **Experiment**: Create `lua/plugins/test.lua` and try adding plugins
4. **Check Keymaps**: Use `<leader>sk` (search keymaps) to see all bindings
5. **Watch Plugins**: Star repos on GitHub to follow updates

---

## Useful Resources

- LazyVim Docs: <https://lazyvim.org>
- Lazy.nvim Docs: <https://github.com/folke/lazy.nvim>
- Neovim Lua Guide: `:help lua-guide`
- Your Config: `~/.config/nvim/`

---

## Quick Reference Card

```vim
# LazyVim Leader Key
<leader> = <Space>

# Essential Commands
:Lazy              - Plugin manager UI
:LazyExtras        - Install language/feature packs
:Mason             - Install LSP/formatters/linters
:Telescope         - Fuzzy finder
:checkhealth       - Diagnose issues

# File Navigation (Telescope)
<leader>ff         - Find files
<leader>fg         - Live grep
<leader>fb         - Find buffers
<leader>fr         - Recent files

# LSP
gd                 - Go to definition
gr                 - Go to references
K                  - Hover documentation
<leader>ca         - Code actions
<leader>rn         - Rename

# File Explorer (Neo-tree)
<leader>e          - Toggle file tree

# Your Custom (Harpoon)
<leader>H          - Mark file
<leader>h          - Show marks
<leader>1-5        - Jump to marked file
```

---

## Happy Vimming! 🚀
