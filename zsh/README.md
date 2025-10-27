# Zsh Configuration

Feature-rich shell configuration with aliases, completions, and modern tools.

## Features

### Modern Tool Replacements

- `eza` → `ls` (with icons and colors)
- `bat` → `cat` (syntax highlighting)
- `nvim` → `vim`

### Alias Categories

#### Git

- `g`, `ga`, `gc`, `gco`, `gp`, `gl`, `gst`, `gb`, `gd`, `glg`
- Fast Git workflow shortcuts

#### Kubernetes

- `k`, `kubectl` → `kubecolor` (colored output)
- `kg`, `kgp`, `kgd`, `kgs` (get resources)
- `kn`, `kx` (namespace/context switching)
- `klogs`, `klogsf` (logs, follow logs)

#### FluxCD

- `frk` (reconcile kustomization)
- `frh` (reconcile helmrelease)
- `fget` (flux get)

#### Infrastructure

- `tf`, `tfp`, `tfa`, `tfi` (Terraform shortcuts)
- `an`, `ap`, `av` (Ansible shortcuts)

#### Navigation

- `..`, `...`, `....` (quick parent directory navigation)
- `~` (go home)

### Configuration Files

```
~/.config/zsh/
├── aliases.zsh           # All aliases
├── completions.zsh       # Shell completions
├── completions-post.zsh  # Post-load completions
├── env.zsh              # Environment variables
├── fzf.git.zsh          # FZF Git integration
├── history.zsh          # History settings
├── Keybindings.zsh      # Custom keybindings
└── themes/              # Prompt themes
```

## Installation

```bash
stow zsh
```

Then source in your `.zshrc`:

```bash
source ~/.config/zsh/aliases.zsh
source ~/.config/zsh/env.zsh
# ... other files
```

## Usage

The aliases and functions are loaded automatically. Examples:

```bash
ll                    # Enhanced ls with eza
cat file.txt          # bat with syntax highlighting
k get pods            # kubectl get pods with colors
tf plan               # terraform plan
..                    # cd ..
```

## OS-Specific Features

### macOS

- `python` aliased to `python3`
- `code` opens VS Code
- Nix Darwin rebuild shortcuts

### Linux

- Standard tool replacements

## Customization

1. Add aliases in `aliases.zsh`
2. Set environment variables in `env.zsh`
3. Add keybindings in `Keybindings.zsh`
4. Configure completions in `completions.zsh`
