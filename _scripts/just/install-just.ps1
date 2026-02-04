# =============================================================================
# Install just on Windows
# =============================================================================
# PowerShell script to install just command runner on Windows
#
# Usage:
#   pwsh -File install-just.ps1
# =============================================================================

#Requires -Version 7.0

param(
    [Parameter(Mandatory = $false)]
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# Import helper libraries
$libPath = Join-Path $PSScriptRoot "..\lib\pwsh"
. "$libPath\colors.ps1"
. "$libPath\common.ps1"

# Check if just is already installed
if ((Get-Command just -ErrorAction SilentlyContinue) -and -not $Force) {
    $version = (just --version 2>&1) -join ""
    Write-Success "just is already installed: $version"
    exit 0
}

Write-Header "Installing just command runner"

# Try different installation methods
function Install-ViaWinget {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Info "Attempting installation via winget..."
        try {
            winget install --id Casey.Just --silent --accept-package-agreements --accept-source-agreements
            return $true
        }
        catch {
            Write-Warning "winget installation failed: $_"
            return $false
        }
    }
    return $false
}

function Install-ViaChocolatey {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Info "Attempting installation via Chocolatey..."
        try {
            choco install just -y
            return $true
        }
        catch {
            Write-Warning "Chocolatey installation failed: $_"
            return $false
        }
    }
    return $false
}

function Install-ViaScoop {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Info "Attempting installation via Scoop..."
        try {
            scoop install just
            return $true
        }
        catch {
            Write-Warning "Scoop installation failed: $_"
            return $false
        }
    }
    return $false
}

function Install-ViaCargo {
    if (Get-Command cargo -ErrorAction SilentlyContinue) {
        Write-Info "Attempting installation via cargo..."
        try {
            cargo install just
            return $true
        }
        catch {
            Write-Warning "cargo installation failed: $_"
            return $false
        }
    }
    return $false
}

# Try installation methods in order
Write-Host ""
$installed = $false

if (Install-ViaWinget) {
    $installed = $true
}
elseif (Install-ViaChocolatey) {
    $installed = $true
}
elseif (Install-ViaScoop) {
    $installed = $true
}
elseif (Install-ViaCargo) {
    $installed = $true
}

Write-Host ""

# Verify installation
if (Get-Command just -ErrorAction SilentlyContinue) {
    $version = (just --version 2>&1) -join ""
    Write-Success "just installed successfully: $version"
    Write-Host ""
    Write-Info "Try: just --list"
}
else {
    Write-Error "Installation failed. Please install manually:"
    Write-Host ""
    Write-Host "  Option 1 - winget:"
    Write-Host "    winget install Casey.Just"
    Write-Host ""
    Write-Host "  Option 2 - Chocolatey:"
    Write-Host "    choco install just"
    Write-Host ""
    Write-Host "  Option 3 - Scoop:"
    Write-Host "    scoop install just"
    Write-Host ""
    Write-Host "  Option 4 - GitHub Releases:"
    Write-Host "    https://github.com/casey/just/releases"
    Write-Host ""
    exit 1
}
