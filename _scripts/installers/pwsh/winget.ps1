# =============================================================================
# WinGet Installer
# =============================================================================
# Ensures Windows Package Manager (winget) is installed and up to date.
#
# Usage:
#   .\winget.ps1
# =============================================================================

# Import libraries
$libPath = "$PSScriptRoot\..\..\lib\pwsh"
. "$libPath\colors.ps1"
. "$libPath\common.ps1"
. "$libPath\detect.ps1"

Write-Header "WinGet Installer"

# Check if winget is already installed
if (Test-Command "winget") {
    Write-Success "winget is already installed"
    
    # Show version
    $version = winget --version
    Write-Info "Version: $version"
    
    Write-Info "To update winget, run: winget upgrade Microsoft.AppInstaller"
    exit 0
}

Write-Info "winget not found. Installing via Microsoft.WinGet.Client module..."

try {
    # Set progress preference for silent operation
    $progressPreference = 'silentlyContinue'
    
    # Install NuGet provider
    Write-Step "Installing NuGet package provider..."
    Install-PackageProvider -Name NuGet -Force -ErrorAction Stop | Out-Null
    Write-Success "NuGet provider installed"
    
    # Install Microsoft.WinGet.Client module
    Write-Step "Installing Microsoft.WinGet.Client module from PSGallery..."
    Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery -ErrorAction Stop | Out-Null
    Write-Success "Microsoft.WinGet.Client module installed"
    
    # Bootstrap winget using Repair-WinGetPackageManager
    Write-Step "Bootstrapping WinGet using Repair-WinGetPackageManager..."
    Repair-WinGetPackageManager -AllUsers -ErrorAction Stop
    Write-Success "WinGet bootstrapped successfully"
    
    # Verify installation
    if (Test-Command "winget") {
        $version = winget --version
        Write-Success "winget installed successfully!"
        Write-Info "Version: $version"
        exit 0
    }
    else {
        Write-ErrorMsg "winget command not found after installation"
        Write-Info "You may need to restart your terminal or computer"
        exit 1
    }
}
catch {
    Write-ErrorMsg "Failed to install winget: $_"
    Write-Info ""
    Write-Info "Manual installation options:"
    Write-Info "1. Install from Microsoft Store: https://aka.ms/getwinget"
    Write-Info "2. Download App Installer from: https://github.com/microsoft/winget-cli/releases"
    Write-Info "3. Use Windows Settings > Apps > Optional Features > Add 'App Installer'"
    exit 1
}
