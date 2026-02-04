# Nushell Configuration Architecture

## Folder Structure

```
~/.config/nushell/
├── config.nu              # Main entry point
├── env.nu                 # Environment variables
│
├── ui/                    # User Interface Components
│   ├── theme.nu           # Color scheme & syntax highlighting
│   ├── menus.nu           # Interactive menus
│   └── keybindings.nu     # Keyboard shortcuts
│
├── core/                  # Core Shell Behavior
│   └── hooks.nu           # Shell hooks & integrations
│
├── aliases/               # Commands & Shortcuts
│   ├── commands.nu        # Custom commands & basic aliases
│   ├── git-aliases.nu     # Git shortcuts (100+ aliases)
│   └── kubernetes-aliases.nu  # Kubernetes CLI shortcuts
│
└── integrations/          # External Tools
    └── external-tools.nu  # Starship, Carapace, Atuin, Zoxide
```

## Module Dependency Graph

```
config.nu (Main Entry Point)
    │
    ├── ui/
    │   ├── theme.nu ──────────► Color scheme & syntax highlighting
    │   ├── menus.nu ──────────► Completion, history, help menus
    │   └── keybindings.nu ────► Keyboard shortcuts
    │
    ├── core/
    │   └── hooks.nu ──────────► Shell hooks & direnv integration
    │
    ├── aliases/
    │   ├── commands.nu ───────► Custom commands & basic aliases
    │   │       └── setup_tree_alias
    │   ├── git-aliases.nu ────► Git shortcuts (Oh My Zsh style)
    │   │       ├── git-main-branch
    │   │       ├── git-develop-branch
    │   │       └── 100+ aliases
    │   └── kubernetes-aliases.nu ─► Kubernetes CLI shortcuts
    │           ├── setup_kubectl_aliases
    │           └── setup_kubectl_context_aliases
    │
    └── integrations/
        └── external-tools.nu ─► Tool integrations
                ├── init_starship
                ├── init_carapace
                ├── init_atuin
                ├── init_zoxide
                └── init_all
```

## Configuration Flow

```
1. Shell starts
   ↓
2. Nushell loads config.nu
   ↓
3. Import modules from organized folders
   ├── ui/theme.nu (exports functions)
   ├── ui/menus.nu (exports functions)
   ├── ui/keybindings.nu (exports functions)
   ├── core/hooks.nu (exports functions)
   ├── aliases/commands.nu (exports functions & aliases)
   ├── aliases/git-aliases.nu (exports aliases)
   ├── aliases/kubernetes-aliases.nu (exports functions)
   └── integrations/external-tools.nu (exports functions)
   ↓
4. Set $env.config with imported values
   ├── color_config: (theme dark_theme)
   ├── hooks: (hooks hooks)
   ├── menus: (menus menus)
   └── keybindings: (keybindings keybindings)
   ↓
5. Initialize external tools
   ├── init_all() → Starship, Carapace, Atuin, Zoxide
   ├── setup_tree_alias() → eza or tree
   ├── setup_kubectl_aliases() → k, kg, kd, etc.
   └── setup_kubectl_context_aliases() → kc, kns
   ↓
6. Shell ready with all configurations loaded
```

## Module Responsibilities

| Folder | Module | Purpose | Exports | Dependencies |
|--------|--------|---------|---------|--------------|
| **ui/** | `theme.nu` | Visual styling | `dark_theme` function | None |
| **ui/** | `menus.nu` | Interactive menus | `menus` function | None |
| **ui/** | `keybindings.nu` | Key mappings | `keybindings` function | None |
| **core/** | `hooks.nu` | Shell hooks | `hooks` function | None |
| **aliases/** | `commands.nu` | Custom commands | Functions, aliases | None |
| **aliases/** | `git-aliases.nu` | Git shortcuts | Helper functions, aliases | None |
| **aliases/** | `kubernetes-aliases.nu` | K8s shortcuts | Setup functions | kubectl, kubectx |
| **integrations/** | `external-tools.nu` | Tool integrations | Init functions | starship, carapace, atuin, zoxide |

## Folder Organization

### `ui/` - User Interface Components
All visual and interactive elements that define how the shell looks and feels:
- **Colors & Themes** - Visual appearance
- **Menus** - Interactive selection interfaces
- **Keybindings** - How user input is mapped

### `core/` - Core Shell Behavior
Fundamental shell behavior and lifecycle hooks:
- **Hooks** - Pre/post execution, environment changes
- **Shell Integration** - Terminal protocol support

### `aliases/` - Commands & Shortcuts
All user-facing commands and aliases for productivity:
- **Basic Commands** - File operations, navigation
- **Git Workflows** - Version control shortcuts
- **Kubernetes** - Container orchestration tools

### `integrations/` - External Tools
Third-party tool integrations and their initialization:
- **Prompt** - Starship cross-shell prompt
- **Completions** - Carapace auto-complete engine
- **History** - Atuin synchronized shell history
- **Navigation** - Zoxide smart directory jumping

## Data Flow

### Theme Application
```
ui/theme.nu → dark_theme() → $env.config.color_config
```

### Menu Configuration
```
ui/menus.nu → menus() → $env.config.menus
```

### Keybinding Setup
```
ui/keybindings.nu → keybindings() → $env.config.keybindings
```

### Hook Integration
```
core/hooks.nu → hooks() → $env.config.hooks
```

### External Tool Initialization
```
integrations/external-tools.nu → init_all() → {
    init_starship() → Check cache → Generate/Load → Source
    init_carapace() → Check cache → Generate/Load → Source
    init_atuin() → Check cache → Generate/Load → Source
    init_zoxide() → Check cache → Generate/Load → Source
}
```

## Platform Detection

```
if $nu.os-info.name == 'windows' {
    # Use Windows paths: C:/Users/#{USERNAME}#/.cache/
} else {
    # Use Unix paths: ~/.cache/
}
```

## Cache Strategy

```
Tool Cache Location:
├── Windows: C:/Users/#{USERNAME}#/.cache/{tool}/init.nu
└── Unix: ~/.cache/{tool}/init.nu

Cache Check:
1. Does init.nu exist?
   ├── Yes → Source it directly (fast)
   └── No → Generate it, save it, then source it (first run)
```

## Customization Points

### 1. Change Theme
Edit `ui/theme.nu`:
```nu
export def dark_theme [] {
    { ... your colors ... }
}
```

### 2. Add Keybinding
Edit `ui/keybindings.nu`:
```nu
export def keybindings [] {
    [
        ...existing...
        {
            name: your_custom_binding
            modifier: control
            keycode: char_x
            mode: [vi_insert]
            event: { ... }
        }
    ]
}
```

### 3. Add Custom Command
Edit `aliases/commands.nu`:
```nu
export def my-command [] {
    # your code
}
```

### 4. Add Git Alias
Edit `aliases/git-aliases.nu`:
```nu
export alias gp = git push origin HEAD
```

### 5. Add Tool Integration
Edit `integrations/external-tools.nu`:
```nu
export def init_mytool [] {
    try {
        mytool init nu | save ~/.cache/mytool/init.nu
        source ~/.cache/mytool/init.nu
    }
}
```

Then add to `init_all`:
```nu
export def init_all [] {
    init_starship
    init_carapace
    init_atuin
    init_zoxide
    init_mytool  # Add here
}
```

### 6. Create New Module in Appropriate Folder
For Docker commands, create `aliases/docker-aliases.nu`:
```nu
export alias d = docker
export alias dc = docker compose
export alias dps = docker ps -a
```

Then import in `config.nu`:
```nu
use ~/.config/nushell/aliases/docker-aliases.nu *
```

## Testing

To test the modular configuration:

```bash
# Test in a clean shell
nu -c "source ~/.config/nushell/config.nu; g status"

# Check module imports from folders
nu -c "use ~/.config/nushell/ui/theme.nu; theme dark_theme"

# Test specific folder modules
nu -c "use ~/.config/nushell/aliases/git-aliases.nu *; g status"
nu -c "use ~/.config/nushell/aliases/commands.nu *; ll"

# Verify external tools
nu -c "source ~/.config/nushell/config.nu; which starship carapace atuin zoxide"

# List all module files by folder
ls ~/.config/nushell/ui/
ls ~/.config/nushell/core/
ls ~/.config/nushell/aliases/
ls ~/.config/nushell/integrations/
```
