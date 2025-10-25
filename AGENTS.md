# Agent Guidelines for Dotfiles Repository

## Build/Test Commands

- No traditional build system - this is a dotfiles configuration repository
- Use `pre-commit run --all-files` to run pre-commit hooks (trailing whitespace, secrets detection, YAML validation)
- Test configurations by symlinking and verifying tool functionality
- For Neovim: `nvim --headless -c "checkhealth" -c "qa"` to validate configuration

## Code Style Guidelines

### Shell Scripts (Bash/Zsh)

- Use `#!/usr/bin/env sh` for portability or `#!/usr/bin/env bash` when bash-specific features needed
- Follow POSIX shell conventions where possible
- Use lowercase variables with underscores: `monitor_data`, `focused_name`
- Quote variables to prevent word splitting: `"$variable"`
- Use `jq` for JSON parsing in scripts

### Configuration Files

- Use 2-space indentation for YAML files
- Use 4-space indentation for shell scripts
- Follow existing naming conventions: kebab-case for config files, snake_case for variables
- Comment configuration sections clearly with `# =====` style headers
- Group related configurations together (e.g., git aliases, kubernetes aliases)

### Aliases and Functions

- Prefix tool replacements clearly: `alias ls='eza --icons'`
- Use single letters for frequently used commands: `alias g='git'`, `alias k='kubecolor'`
- Keep muscle memory typos as aliases: `alias kubeclt='kubecolor'`
- Group aliases by functionality with clear section headers

### Error Handling

- Use conditional checks for OS-specific configurations: `if [[ "$OSTYPE" == "darwin"* ]]`
- Validate tool availability before creating aliases
- Provide fallbacks for missing dependencies where appropriate

