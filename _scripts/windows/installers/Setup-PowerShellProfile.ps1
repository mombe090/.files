#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Setup PowerShell profile to load from XDG config location
.DESCRIPTION
    Creates a wrapper profile at $PROFILE that sources ~/.config/powershell/profile.ps1
    This allows cross-platform configuration while respecting Windows conventions.
    No admin privileges required (uses wrapper file instead of symlink).
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

$wrapperContent = @'
# PowerShell Profile Wrapper
# This file sources the actual profile from XDG config location
# Location: Documents\PowerShell\Microsoft.PowerShell_profile.ps1

$xdgProfile = Join-Path $env:USERPROFILE ".config\powershell\profile.ps1"

if (Test-Path $xdgProfile) {
    . $xdgProfile
}
else {
    Write-Warning "XDG PowerShell profile not found: $xdgProfile"
    Write-Host "Run: just win_stow powershell" -ForegroundColor Yellow
}
'@

# =============================================================================
# Main Script
# =============================================================================

Write-Header "PowerShell Profile Setup"

# Check if config profile exists
if (-not (Test-Path $configProfilePath)) {
    Write-ErrorMsg "Config profile not found: $configProfilePath"
    Write-Info "Please run: just win_stow powershell"
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
    # Check if it's already our wrapper
    $existingContent = Get-Content $PROFILE -Raw
    
    if ($existingContent -match "XDG PowerShell profile not found") {
        Write-Success "Profile wrapper already exists"
        Write-Info "Location: $PROFILE"
        exit 0
    }
    
    Write-Warn "Profile already exists"
    Write-Info "Location: $PROFILE"
    
    if (-not $Force) {
        Write-ErrorMsg "Use -Force to backup and replace with wrapper"
        exit 1
    }
    
    # Backup existing profile
    $backupPath = "$PROFILE.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Warn "Backing up existing profile to: $backupPath"
    Copy-Item $PROFILE $backupPath -Force
    Write-Success "Backup created"
}

# Create wrapper profile
try {
    Write-Info "Creating wrapper profile..."
    Write-Info "At: $PROFILE"
    Write-Info "Sources: $configProfilePath"
    
    $wrapperContent | Out-File -FilePath $PROFILE -Encoding UTF8 -Force
    
    Write-Success "Profile wrapper created successfully!"
    Write-Host ""
    Write-Info "Reload your PowerShell session to use the new profile"
    Write-Info "Or run: . `$PROFILE"
}
catch {
    Write-ErrorMsg "Failed to create wrapper: $_"
    exit 1
}

# Verify wrapper
Write-Host ""
Write-Header "Verification"
Write-Info "Profile: $PROFILE"
Write-Info "Type: Wrapper file"
Write-Info "Sources: $configProfilePath"

# Test loading the profile
try {
    . $PROFILE
    Write-Success "✓ Profile wrapper verified successfully"
    Write-Success "✓ XDG profile loaded successfully"
}
catch {
    Write-ErrorMsg "✗ Profile wrapper verification failed: $_"
    exit 1
}
