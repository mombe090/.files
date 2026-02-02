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

## PowerShell Scripts

### Target Version

- **IMPORTANT**: All PowerShell scripts target **PowerShell 7+** (not Windows PowerShell 5.1)
- Use `#Requires -Version 7.0` at the top of scripts when using PS7-specific features
- PowerShell 7 is cross-platform (Windows, Linux, macOS)

### Code Style

- Use 4-space indentation
- Use PascalCase for function names: `Get-SystemInfo`, `Install-Package`
- Use camelCase for variables: `$packageName`, `$targetDir`
- Use approved verbs for functions: `Get-`, `Set-`, `New-`, `Remove-`, `Install-`, `Test-`
- Add proper comment-based help (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`)

### Helper Functions - CRITICAL RULES

**NEVER use empty strings with Write-Info, Write-Success, Write-Warning, or Write-Error:**

```powershell
# ❌ WRONG - Will cause parameter binding error
Write-Info ""
Write-Success ""
Write-Warning ""

# ✅ CORRECT - Use Write-Host for blank lines
Write-Host ""
```

**Why**: Our custom helper functions in `_scripts/lib/pwsh/colors.ps1` require non-empty message parameters. PowerShell 7 strictly enforces this.

**Helper Functions Available**:
- `Write-Header $message` - Section headers with color
- `Write-Info $message` - Informational messages
- `Write-Success $message` - Success messages
- `Write-Warning $message` - Warning messages (alias: `Write-Warn`)
- `Write-Error $message` - Error messages (alias: `Write-ErrorMsg`)
- `Write-Step $message` - Step indicators

**For blank lines**: Always use `Write-Host ""`

### File Encoding

- Use UTF-8 with BOM for scripts that need to run in Windows PowerShell 5.1
- Use UTF-8 without BOM for PowerShell 7+ only scripts
- Ensure YAML config files use UTF-8 without BOM

### Error Handling

```powershell
# Set strict error handling
$ErrorActionPreference = 'Stop'

# Use try/catch for error handling
try {
    # Code that might fail
}
catch {
    Write-Error "Failed: $_"
    exit 1
}
```

### Path Handling

```powershell
# Use Join-Path instead of string concatenation
$configPath = Join-Path $env:LOCALAPPDATA "nvim"

# Use Test-Path before accessing files
if (Test-Path $configPath) {
    # Safe to use
}

# Use Split-Path for path manipulation
$parentDir = Split-Path $filePath -Parent
$fileName = Split-Path $filePath -Leaf
```

### Cross-Platform Considerations

```powershell
# Detect Windows vs Linux/macOS
if ($IsWindows -or $env:OS -eq "Windows_NT") {
    # Windows-specific code
}
elseif ($IsLinux) {
    # Linux-specific code
}
elseif ($IsMacOS) {
    # macOS-specific code
}
```

