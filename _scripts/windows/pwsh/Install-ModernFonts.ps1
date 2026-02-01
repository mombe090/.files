#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Install modern Nerd Fonts from GitHub releases
.DESCRIPTION
    Downloads and installs CaskaydiaMono and JetBrainsMono Nerd Fonts from GitHub
.PARAMETER FontNames
    Array of font names to install (default: CascadiaMono, JetBrainsMono)
.EXAMPLE
    .\Install-ModernFonts.ps1
.EXAMPLE
    .\Install-ModernFonts.ps1 -FontNames @('CascadiaMono', 'JetBrainsMono', 'FiraCode')
#>

param(
    [string[]]$FontNames = @('CascadiaMono', 'JetBrainsMono')
)

# Import color functions
$scriptRoot = Split-Path -Parent $PSScriptRoot
$libPath = Join-Path $scriptRoot "lib\pwsh"
. (Join-Path $libPath "colors.ps1")

# =============================================================================
# Configuration
# =============================================================================

$NerdFontsRepo = "ryanoasis/nerd-fonts"
$TempDir = Join-Path $env:TEMP "NerdFonts"
$FontsFolder = [System.Environment]::GetFolderPath('Fonts')

# =============================================================================
# Helper Functions
# =============================================================================

function Get-LatestNerdFontsRelease {
    Write-Info "Fetching latest Nerd Fonts release information..."
    
    try {
        $apiUrl = "https://api.github.com/repos/$NerdFontsRepo/releases/latest"
        $response = Invoke-RestMethod -Uri $apiUrl -Headers @{
            'User-Agent' = 'PowerShell-NerdFonts-Installer'
        }
        
        Write-Success "Latest version: $($response.tag_name)"
        return $response
    }
    catch {
        Write-ErrorMsg "Failed to fetch release information: $_"
        return $null
    }
}

function Get-FontDownloadUrl {
    param(
        [string]$FontName,
        [object]$Release
    )
    
    $assetName = "$FontName.zip"
    $asset = $Release.assets | Where-Object { $_.name -eq $assetName }
    
    if ($asset) {
        return $asset.browser_download_url
    }
    
    return $null
}

function Test-FontInstalled {
    param(
        [string]$FontName
    )
    
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    $fonts = Get-ItemProperty -Path $registryPath -ErrorAction SilentlyContinue
    
    if ($fonts) {
        $installedFont = $fonts.PSObject.Properties | Where-Object { 
            $_.Name -like "*$FontName*" 
        }
        return $null -ne $installedFont
    }
    
    return $false
}

function Install-Font {
    param(
        [string]$FontPath
    )
    
    try {
        # Create Shell.Application COM object
        $shell = New-Object -ComObject Shell.Application
        $fonts = $shell.Namespace(0x14) # CSIDL_FONTS
        
        # Install font
        $fonts.CopyHere($FontPath, 0x10) # FOF_SILENT
        
        return $true
    }
    catch {
        Write-ErrorMsg "Failed to install font: $_"
        return $false
    }
}

function Install-NerdFont {
    param(
        [string]$FontName,
        [object]$Release
    )
    
    Write-Header "Installing $FontName Nerd Font"
    
    # Check if already installed
    if (Test-FontInstalled -FontName $FontName) {
        Write-Success "Font already installed: $FontName"
        return $true
    }
    
    # Get download URL
    $downloadUrl = Get-FontDownloadUrl -FontName $FontName -Release $Release
    
    if (-not $downloadUrl) {
        Write-ErrorMsg "Font not found in release: $FontName"
        return $false
    }
    
    Write-Info "Downloading: $FontName"
    Write-Info "URL: $downloadUrl"
    
    # Create temp directory
    $fontTempDir = Join-Path $TempDir $FontName
    if (Test-Path $fontTempDir) {
        Remove-Item $fontTempDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $fontTempDir -Force | Out-Null
    
    # Download zip file
    $zipPath = Join-Path $fontTempDir "$FontName.zip"
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing
        Write-Success "Downloaded successfully"
    }
    catch {
        Write-ErrorMsg "Failed to download: $_"
        return $false
    }
    
    # Extract zip file
    Write-Step "Extracting fonts..."
    try {
        Expand-Archive -Path $zipPath -DestinationPath $fontTempDir -Force
        Write-Success "Extracted successfully"
    }
    catch {
        Write-ErrorMsg "Failed to extract: $_"
        return $false
    }
    
    # Install font files
    Write-Step "Installing font files..."
    $fontFiles = Get-ChildItem -Path $fontTempDir -Filter "*.ttf" -Recurse
    
    if ($fontFiles.Count -eq 0) {
        Write-ErrorMsg "No font files found in archive"
        return $false
    }
    
    $installedCount = 0
    foreach ($fontFile in $fontFiles) {
        # Skip fonts with "Windows Compatible" in the name - we want the regular versions
        if ($fontFile.Name -match "Windows Compatible") {
            continue
        }
        
        Write-Verbose "Installing: $($fontFile.Name)"
        if (Install-Font -FontPath $fontFile.FullName) {
            $installedCount++
        }
    }
    
    Write-Success "Installed $installedCount font file(s) for $FontName"
    
    # Cleanup
    Remove-Item $fontTempDir -Recurse -Force -ErrorAction SilentlyContinue
    
    return $true
}

# =============================================================================
# Main Script
# =============================================================================

Write-Header "Nerd Fonts Installer"

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-ErrorMsg "This script requires administrator privileges to install fonts."
    Write-Info "Please run PowerShell as Administrator and try again."
    exit 1
}

# Create temp directory
if (-not (Test-Path $TempDir)) {
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
}

# Get latest release
$release = Get-LatestNerdFontsRelease

if (-not $release) {
    Write-ErrorMsg "Failed to get release information. Exiting."
    exit 1
}

Write-Info "Fonts folder: $FontsFolder"
Write-Info "Temp folder: $TempDir"
Write-Info ""

# Install each font
$successCount = 0
$totalCount = $FontNames.Count

foreach ($fontName in $FontNames) {
    if (Install-NerdFont -FontName $fontName -Release $release) {
        $successCount++
    }
    Write-Info ""
}

# Cleanup temp directory
if (Test-Path $TempDir) {
    Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
}

# Summary
Write-Header "Installation Summary"
Write-Info "Successfully installed: $successCount / $totalCount fonts"

if ($successCount -eq $totalCount) {
    Write-Success "All fonts installed successfully!"
    Write-Info "You may need to restart applications to see the new fonts."
} else {
    Write-Warn "Some fonts failed to install. Check the output above for details."
}
