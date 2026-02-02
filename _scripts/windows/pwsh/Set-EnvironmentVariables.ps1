#Requires -Version 7.0

<#
.SYNOPSIS
    Sets up environment variables for Windows dotfiles support
.DESCRIPTION
    Configures XDG Base Directory specification environment variables for Windows.
    This enables cross-platform configuration file compatibility.
    
    Can set variables for current session only or persist them to User environment.
.PARAMETER Persist
    If specified, saves environment variables to Windows User environment (registry).
    Otherwise, only sets variables for the current PowerShell session.
.PARAMETER Scope
    Scope for persisted variables: User or Machine. Default: User
    Machine scope requires Administrator privileges.
.EXAMPLE
    .\Set-EnvironmentVariables.ps1
    Sets variables for current session only
.EXAMPLE
    .\Set-EnvironmentVariables.ps1 -Persist
    Sets variables and saves to User environment (persists across sessions)
.EXAMPLE
    .\Set-EnvironmentVariables.ps1 -Persist -Scope Machine
    Sets variables system-wide (requires admin)
#>

param(
    [switch]$Persist,
    [ValidateSet('User', 'Machine')]
    [string]$Scope = 'User'
)

# Import helper functions
$libPath = Join-Path $PSScriptRoot ".." ".." "lib" "pwsh"
. "$libPath\colors.ps1"

Write-Header "Environment Variables Setup"

# Define environment variables to set
$envVars = @(
    @{
        Name = 'XDG_CONFIG_HOME'
        Value = Join-Path $env:USERPROFILE '.config'
        Description = 'XDG config directory (cross-platform compatibility)'
    },
    @{
        Name = 'XDG_DATA_HOME'
        Value = Join-Path $env:USERPROFILE '.local' 'share'
        Description = 'XDG data directory'
    },
    @{
        Name = 'XDG_CACHE_HOME'
        Value = Join-Path $env:USERPROFILE '.cache'
        Description = 'XDG cache directory'
    },
    @{
        Name = 'XDG_STATE_HOME'
        Value = Join-Path $env:USERPROFILE '.local' 'state'
        Description = 'XDG state directory'
    }
)

# Set variables for current session
Write-Header "Setting Environment Variables"
Write-Host ""

foreach ($var in $envVars) {
    Write-Step "Setting: $($var.Name)"
    Write-Info "  Value: $($var.Value)"
    Write-Info "  Purpose: $($var.Description)"
    
    # Set for current session
    Set-Item -Path "env:$($var.Name)" -Value $var.Value -Force
    
    Write-Success "Set for current session"
    Write-Host ""
}

# Persist to registry if requested
if ($Persist) {
    Write-Header "Persisting Environment Variables"
    Write-Host ""
    
    if ($Scope -eq 'Machine' -and -not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-ErrorMsg "Machine scope requires Administrator privileges"
        Write-Info "Run PowerShell as Administrator or use -Scope User"
        exit 1
    }
    
    Write-Info "Saving to: $Scope environment"
    Write-Host ""
    
    foreach ($var in $envVars) {
        Write-Step "Persisting: $($var.Name)"
        
        try {
            [System.Environment]::SetEnvironmentVariable($var.Name, $var.Value, $Scope)
            Write-Success "Saved to $Scope environment"
        }
        catch {
            Write-ErrorMsg "Failed to persist $($var.Name): $_"
        }
        Write-Host ""
    }
    
    Write-Success "Environment variables persisted!"
    Write-Host ""
    Write-Warn "Note: You may need to restart applications for changes to take effect"
}
else {
    Write-Info "Variables set for current session only"
    Write-Info "To persist across sessions, add to PowerShell profile or run with -Persist"
}

Write-Host ""
Write-Header "Current Environment Variables"
Write-Host ""

# Display current values
foreach ($var in $envVars) {
    $currentValue = [System.Environment]::GetEnvironmentVariable($var.Name)
    if ($currentValue) {
        Write-Success "$($var.Name) = $currentValue"
    }
    else {
        Write-Warn "$($var.Name) not set"
    }
}

Write-Host ""
Write-Header "Setup Complete!"
Write-Host ""

if (-not $Persist) {
    Write-Info "To make these permanent, you can:"
    Write-Info "  1. Run: .\Set-EnvironmentVariables.ps1 -Persist"
    Write-Info "  2. Or add to your PowerShell profile"
    Write-Host ""
}

Write-Info "These variables enable cross-platform config compatibility:"
Write-Info "  • XDG_CONFIG_HOME - Configuration files (~/.config)"
Write-Info "  • XDG_DATA_HOME   - Application data (~/.local/share)"
Write-Info "  • XDG_CACHE_HOME  - Cache files (~/.cache)"
Write-Info "  • XDG_STATE_HOME  - State files (~/.local/state)"
