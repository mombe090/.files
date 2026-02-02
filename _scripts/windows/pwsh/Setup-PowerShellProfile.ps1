#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Setup PowerShell profile symlink to XDG config location
.DESCRIPTION
    Creates a symlink from $PROFILE to ~/.config/powershell/profile.ps1
    This allows cross-platform configuration while respecting Windows conventions.
.EXAMPLE
    .\Setup-PowerShellProfile.ps1
.EXAMPLE
    .\Setup-PowerShellProfile.ps1 -Force
#>

param(
    [switch]$Force
)

# Import color functions
$libPath = Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "lib\pwsh"
. (Join-Path $libPath "colors.ps1")

# =============================================================================
# Configuration
# =============================================================================

$configProfilePath = Join-Path $env:USERPROFILE ".config\powershell\profile.ps1"
$profileDir = Split-Path $PROFILE -Parent

# =============================================================================
# Main Script
# =============================================================================

Write-Header "PowerShell Profile Setup"

# Check if config profile exists
if (-not (Test-Path $configProfilePath)) {
    Write-ErrorMsg "Config profile not found: $configProfilePath"
    Write-Info "Please run: .\stow.ps1 powershell"
    exit 1
}

Write-Success "Found config profile: $configProfilePath"

# Ensure profile directory exists
if (-not (Test-Path $profileDir)) {
    Write-Info "Creating profile directory: $profileDir"
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    Write-Success "Profile directory created"
}

# Check if profile already exists
if (Test-Path $PROFILE) {
    $item = Get-Item $PROFILE
    
    if ($item.LinkType -eq "SymbolicLink") {
        $currentTarget = $item.Target
        
        if ($currentTarget -eq $configProfilePath) {
            Write-Success "Profile symlink already correct"
            Write-Info "Target: $currentTarget"
            exit 0
        }
        else {
            Write-Warn "Profile symlink exists but points to different target"
            Write-Info "Current: $currentTarget"
            Write-Info "Expected: $configProfilePath"
            
            if (-not $Force) {
                Write-ErrorMsg "Use -Force to recreate symlink"
                exit 1
            }
            
            Write-Warn "Removing existing symlink..."
            Remove-Item $PROFILE -Force
        }
    }
    else {
        Write-Warn "Profile exists but is not a symlink"
        Write-Info "Location: $PROFILE"
        
        if (-not $Force) {
            Write-ErrorMsg "Use -Force to backup and replace with symlink"
            exit 1
        }
        
        # Backup existing profile
        $backupPath = "$PROFILE.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Write-Warn "Backing up existing profile to: $backupPath"
        Move-Item $PROFILE $backupPath -Force
        Write-Success "Backup created"
    }
}

# Create symlink
try {
    Write-Info "Creating symlink..."
    Write-Info "From: $PROFILE"
    Write-Info "To:   $configProfilePath"
    
    New-Item -ItemType SymbolicLink -Path $PROFILE -Target $configProfilePath -Force | Out-Null
    
    Write-Success "Profile symlink created successfully!"
    Write-Host ""
    Write-Info "Reload your PowerShell session to use the new profile"
    Write-Info "Or run: . `$PROFILE"
}
catch {
    Write-ErrorMsg "Failed to create symlink: $_"
    exit 1
}

# Verify symlink
Write-Host ""
Write-Header "Verification"
$item = Get-Item $PROFILE
Write-Info "Profile: $PROFILE"
Write-Info "Type: $($item.LinkType)"
Write-Info "Target: $($item.Target)"

if ($item.LinkType -eq "SymbolicLink" -and $item.Target -eq $configProfilePath) {
    Write-Success "✓ Profile symlink verified successfully"
}
else {
    Write-ErrorMsg "✗ Profile symlink verification failed"
    exit 1
}
