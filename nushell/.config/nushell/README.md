# Nushell Configuration - Modular Structure

This Nushell configuration is organized into separate modules grouped by functionality for easier maintenance and customization.

## File Structure

```
~/.config/nushell/
├── config.nu                    # Main configuration file (imports all modules)
├── env.nu                       # Environment variables
│
├── ui/                          # User Interface Components
│   ├── theme.nu                 # Color scheme and syntax highlighting
│   ├── menus.nu                 # Completion and help menus
│   └── keybindings.nu          # Keyboard shortcuts
│
├── core/                        # Core Shell Configuration
│   └── hooks.nu                # Shell hooks (pre_prompt, etc.)
│
├── aliases/                     # Commands & Aliases
│   ├── commands.nu             # Custom commands and basic aliases
│   ├── git-aliases.nu          # Git aliases (Oh My Zsh style)
│   └── kubernetes-aliases.nu   # Kubernetes/kubectl aliases
│
└── integrations/               # External Tool Integrations
    └── external-tools.nu       # Starship, Carapace, Atuin, Zoxide
```

## Module Descriptions

### `config.nu` (Main)
- Central configuration file
- Imports all other modules from organized folders
- Contains main `$env.config` settings
- Initializes external tools and aliases

### UI Components (`ui/`)

#### `ui/theme.nu`
- Color scheme configuration
- Syntax highlighting rules
- Uses dark theme by default
- Exports `dark_theme` function

#### `ui/menus.nu`
- Completion menu (Tab)
- IDE completion menu (Ctrl+N)
- History menu (Ctrl+R)
- Help menu (F1)

#### `ui/keybindings.nu`
- Tab completion
- History search
- Clear screen
- Cancel command
- Quit shell

### Core Configuration (`core/`)

#### `core/hooks.nu`
- Pre-prompt hooks (direnv integration)
- Environment change hooks
- Display output formatting

### Commands & Aliases (`aliases/`)

#### `aliases/commands.nu`
- Enhanced `cx` command (cd + ls)
- File operation aliases (`l`, `ll`, `c`)
- Editor aliases (`v`)
- Tree command setup (eza/tree)

#### `aliases/git-aliases.nu`
- Comprehensive git aliases (Oh My Zsh style)
- Helper functions (main-branch, develop-branch)
- Over 100 git shortcuts

#### `aliases/kubernetes-aliases.nu`
- kubectl aliases (`k`, `kg`, `kd`, etc.)
- kubectx/kubens aliases
- Conditional loading (only if tools installed)

### External Integrations (`integrations/`)

#### `integrations/external-tools.nu`
- Starship prompt initialization
- Carapace completions
- Atuin shell history
- Zoxide smart cd
- Cross-platform support (Windows/Unix)
- Cache management

## Usage

### Edit Specific Configuration

To modify a specific aspect of your configuration:

```bash
# Edit theme/colors
nvim ~/.config/nushell/ui/theme.nu

# Edit keybindings
nvim ~/.config/nushell/ui/keybindings.nu

# Edit menus
nvim ~/.config/nushell/ui/menus.nu

# Edit git aliases
nvim ~/.config/nushell/aliases/git-aliases.nu

# Edit kubernetes aliases
nvim ~/.config/nushell/aliases/kubernetes-aliases.nu

# Edit custom commands
nvim ~/.config/nushell/aliases/commands.nu

# Edit external tools setup
nvim ~/.config/nushell/integrations/external-tools.nu

# Edit hooks
nvim ~/.config/nushell/core/hooks.nu
```

### Add New Modules

1. Create a new `.nu` file in the appropriate folder:
   - `ui/` for interface components
   - `core/` for shell behavior
   - `aliases/` for commands and shortcuts
   - `integrations/` for external tool setups

2. Export your functions/aliases with `export`
3. Add `use ~/.config/nushell/<folder>/your-module.nu *` to `config.nu`

Example - Adding Docker aliases:
```nu
# ~/.config/nushell/aliases/docker-aliases.nu
export alias d = docker
export alias dc = docker compose
export alias dps = docker ps
```

Then in `config.nu`:
```nu
use ~/.config/nushell/aliases/docker-aliases.nu *
```

### Reload Configuration

After making changes:
```nu
source ~/.config/nushell/config.nu
```

Or restart your shell.

## Benefits of Modular Structure

✅ **Easy to maintain** - Find and edit specific configurations quickly  
✅ **Clean organization** - Related settings grouped in folders  
✅ **Intuitive structure** - Know where to look based on folder names  
✅ **Reusable** - Share individual modules across machines  
✅ **Version control friendly** - Track changes to specific areas  
✅ **Fast loading** - Nushell's module system is efficient  
✅ **No conflicts** - Each module has clear responsibility  
✅ **Scalable** - Easy to add new modules in appropriate folders  

## Cross-Platform Support

The configuration automatically detects your platform:
- **Windows**: Uses `C:/Users/#{USERNAME}#/.cache/` paths
- **macOS/Linux**: Uses `~/.cache/` paths

External tools check if cache files exist before regenerating them for faster startup.

## Requirements

### Core Tools
- Nushell 0.99.0+

### Optional Tools (auto-detected)
- **starship** - Cross-shell prompt
- **carapace** - Advanced completions
- **atuin** - Shell history sync
- **zoxide** - Smart directory jumper
- **eza** - Modern ls replacement
- **kubectl** - Kubernetes CLI
- **kubectx/kubens** - Kubernetes context/namespace switcher
- **direnv** - Directory-based environments

## Troubleshooting

### Module not found
Ensure the module file exists and the path in `config.nu` is correct:
```nu
# Check all module files
ls ~/.config/nushell/*/*.nu

# Check specific folders
ls ~/.config/nushell/ui/
ls ~/.config/nushell/aliases/
ls ~/.config/nushell/integrations/
ls ~/.config/nushell/core/
```

### Commands not available
Make sure to import with `*` to export all functions:
```nu
use ~/.config/nushell/aliases/commands.nu *
```

### Windows cache issues
Replace `#{USERNAME}#` with your actual Windows username in `external-tools.nu`.

## Migration from Single File

Your original config has been split into modules. All functionality remains the same, just better organized!

To verify everything works:
```nu
# Test a git alias
g status

# Test kubernetes alias (if installed)
k get pods

# Test custom command
cx /tmp
```
