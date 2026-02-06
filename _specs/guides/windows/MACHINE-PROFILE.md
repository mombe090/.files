# Machine-Specific PowerShell Profile

## Overview

The PowerShell profile supports loading a machine-specific `profile.ps1` file from your user profile directory (`$env:USERPROFILE`). This allows you to have customizations that are specific to a particular machine without affecting your version-controlled dotfiles.

## How It Works

The main PowerShell profile (`Documents\PowerShell\Microsoft.PowerShell_profile.ps1`) automatically checks for and loads `profile.ps1` from your user profile directory:

```
C:\Users\<username>\profile.ps1
```

If this file exists, it will be loaded **after** all standard profile configurations.

## Setup

### 1. Copy the Template

```powershell
# Copy the template to your user profile directory
Copy-Item "$env:USERPROFILE\.files\_scripts\windows\profile.ps1.template" "$env:USERPROFILE\profile.ps1"
```

### 2. Edit for Your Machine

```powershell
# Edit the file
code $env:USERPROFILE\profile.ps1
```

### 3. Restart PowerShell

The machine-specific profile will be loaded automatically on next startup.

## What to Put in Machine-Specific Profile

### ✅ **Good Use Cases**

1. **Secrets and API Keys**
   ```powershell
   $env:OPENAI_API_KEY = "sk-..."  # pragma: allowlist secret
   $env:GITHUB_TOKEN = "ghp_..."  # pragma: allowlist secret
   $env:AWS_ACCESS_KEY_ID = "..."  # pragma: allowlist secret
   ```

2. **Machine-Specific Paths**
   ```powershell
   $env:PROJECT_DIR = "D:\Projects"
   $env:WORKSPACE = "E:\Work"
   function proj { Set-Location "D:\Projects" }
   ```

3. **Network Drives (Windows)**
   ```powershell
   function netdrive { Set-Location "\\server\share\myfiles" }
   ```

4. **Company-Specific Configurations**
   ```powershell
   function vpn-connect { Start-Process "C:\Program Files\VPN\vpn.exe" -ArgumentList "connect" }
   ```

5. **Development Environment Setup**
   ```powershell
   function dev-start {
       docker-compose -f D:\Projects\myapp\docker-compose.yml up -d
       Start-Process "http://localhost:3000"
   }
   ```

6. **Machine-Specific PATH Additions**
   ```powershell
   $env:Path = "D:\CustomTools\bin;$env:Path"
   ```

### ❌ **Bad Use Cases** (Use main profile instead)

1. **General git aliases** - Already in main profile
2. **Starship configuration** - Should be in `.config\starship.toml`
3. **Editor settings** - Should be in version-controlled dotfiles
4. **Cross-machine functions** - Should be in main profile

## Verification

Check if your machine-specific profile is loaded:

```powershell
# Add this to your profile.ps1
Write-Host "Machine-specific profile loaded!" -ForegroundColor Green
```

After restarting PowerShell, you should see the message.

## Examples

### Example 1: Developer Workstation

```powershell
# D:\Projects shortcuts
function proj { Set-Location "D:\Projects" }
function api { Set-Location "D:\Projects\myapi" }
function web { Set-Location "D:\Projects\mywebapp" }

# Start development environment
function dev-start {
    Write-Host "Starting development environment..." -ForegroundColor Cyan
    docker-compose -f D:\Projects\myapi\docker-compose.yml up -d
    code D:\Projects\myapi
}

# Company VPN
function vpn { Start-Process "C:\Program Files\Cisco\VPN\vpn.exe" }
```

### Example 2: Home Machine with Media Server

```powershell
# Network shares
function media { Set-Location "\\homeserver\media" }
function backup { Set-Location "\\homeserver\backups" }

# Plex shortcuts
function plex-restart { Restart-Service "PlexMediaServer" }
function plex-logs { Get-Content "C:\Program Files (x86)\Plex\Plex Media Server\Logs\Plex Media Server.log" -Tail 50 -Wait }
```

### Example 3: Work Laptop with Corporate Tools

```powershell
# Corporate environment variables
$env:CORP_PROXY = "http://proxy.company.com:8080"
$env:CORP_NPM_REGISTRY = "https://npm.company.com"

# Corporate tools
function teams { Start-Process "C:\Program Files\Microsoft\Teams\Teams.exe" }
function vpn-connect { Start-Process "C:\Program Files\VPN Client\vpncli.exe" -ArgumentList "connect corporate" }

# Project shortcuts
function proj-a { Set-Location "C:\Workspace\project-a"; code . }
function proj-b { Set-Location "C:\Workspace\project-b"; code . }
```

## Security Considerations

### ⚠️ **Important**

1. **Never commit `profile.ps1` to git** - It contains machine-specific and potentially sensitive information
2. **Add to .gitignore** - If you're tracking your home directory with git:
   ```gitignore
   # Machine-specific profile
   profile.ps1
   ```

3. **Use `.env` files for secrets** - For projects, prefer `.env` files over hardcoding in profile:
   ```powershell
   # In profile.ps1
   if (Test-Path "D:\Projects\.env") {
       Get-Content "D:\Projects\.env" | ForEach-Object {
           if ($_ -match '^([^=]+)=(.+)$') {
               Set-Item -Path "env:$($matches[1])" -Value $matches[2]
           }
       }
   }
   ```

## Troubleshooting

### Profile not loading

**Check file location**:
```powershell
Test-Path "$env:USERPROFILE\profile.ps1"
# Should return: True
```

**Check file path**:
```powershell
$env:USERPROFILE
# Should show: C:\Users\<username>
```

### Syntax errors

**Test the profile manually**:
```powershell
. "$env:USERPROFILE\profile.ps1"
# Any errors will be shown
```

### Variables not available

**Check if profile loaded**:
```powershell
# Add debug output to profile.ps1
Write-Host "Loading machine profile from: $PSCommandPath" -ForegroundColor Magenta
```

## File Locations

| File | Location | Purpose |
|------|----------|---------|
| **Main Profile** | `Documents\PowerShell\Microsoft.PowerShell_profile.ps1` | Version-controlled, cross-machine settings |
| **Machine Profile** | `$env:USERPROFILE\profile.ps1` | Machine-specific, not version-controlled |
| **Template** | `_scripts\windows\profile.ps1.template` | Template to copy from |

## Best Practices

1. ✅ **Keep it simple** - Only add machine-specific configurations
2. ✅ **Comment everything** - Explain why each customization is needed
3. ✅ **Test before committing** - Make sure changes work before relying on them
4. ✅ **Use functions** - Wrap complex logic in functions for reusability
5. ✅ **Document secrets** - Leave comments about where to get API keys, etc.
6. ❌ **Don't duplicate** - Don't repeat what's already in the main profile
7. ❌ **Don't hardcode** - Use environment variables for paths when possible

## See Also

- [PowerShell Profile Documentation](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles)
- [Environment Variables (ENVIRONMENT-VARIABLES.md)](ENVIRONMENT-VARIABLES.md)
- [Main PowerShell Profile](../../powershell/Documents/PowerShell/Microsoft.PowerShell_profile.ps1)
