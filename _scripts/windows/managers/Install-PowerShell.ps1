# =============================================================================
# PowerShell 7 Installer
# =============================================================================
# Installs PowerShell 7 (PowerShell Core) on Windows.
#
# Usage:
#   .\powershell.ps1
# =============================================================================

# Import libraries
$libPath = "$PSScriptRoot\..\lib"
. "$libPath\colors.ps1"
. "$libPath\common.ps1"
. "$libPath\detect.ps1"
. "$libPath\package-managers.ps1"

Write-Header "PowerShell 7 Installer"

# Check PowerShell version
$psVersion = Get-PowerShellVersion

Write-Info "Current PowerShell Edition: $($psVersion.Edition)"
Write-Info "Current Version: $($psVersion.Version)"

if ($psVersion.IsCore -and $psVersion.Major -ge 7) {
    Write-Success "PowerShell 7+ is already installed"
    exit 0
}

if ($psVersion.IsDesktop) {
    Write-Info "You are running Windows PowerShell (Desktop Edition)"
    Write-Info "Installing PowerShell 7 (Core)..."
}

# Detect package manager
$pm = Get-PackageManager

if (-not $pm) {
    Write-ErrorMsg "No package manager available"
    Write-Info "Please install winget or chocolatey first"
    exit 1
}

Write-Info "Using package manager: $pm"

# Install PowerShell 7
$packageName = if ($pm -eq 'winget') { 'Microsoft.PowerShell' } else { 'powershell-core' }

Write-Step "Installing PowerShell 7..."

if (Install-Package -PackageName $packageName -PackageManager $pm) {
    Write-Success "PowerShell 7 installed successfully!"
    Write-Host ""
    Write-Info "To use PowerShell 7, run: pwsh"
    Write-Info "Or set it as default in Windows Terminal"
    exit 0
}
else {
    Write-ErrorMsg "Failed to install PowerShell 7"
    Write-Host ""
    Write-Info "Manual installation:"
    Write-Info "Visit: https://aka.ms/powershell-release?tag=stable"
    exit 1
}
