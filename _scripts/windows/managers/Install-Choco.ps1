# =============================================================================
# Chocolatey Installer
# =============================================================================
# Installs Chocolatey package manager.
#
# Usage:
#   .\choco.ps1
#
# Note: Requires administrator privileges
# =============================================================================

# Import libraries
$libPath = "$PSScriptRoot\..\lib"
. "$libPath\colors.ps1"
. "$libPath\common.ps1"
. "$libPath\detect.ps1"

Write-Header "Chocolatey Installer"

# Check if chocolatey is already installed
if (Test-Command "choco") {
    Write-Success "Chocolatey is already installed"

    # Show version
    $version = choco --version
    Write-Info "Version: $version"

    Write-Info "To update Chocolatey, run: choco upgrade chocolatey"
    exit 0
}

# Require administrator privileges
if (-not (Test-IsAdmin)) {
    Write-ErrorMsg "This script requires administrator privileges"
    Write-Info "Please run PowerShell as Administrator and try again"
    exit 1
}

Write-Info "Chocolatey not found. Installing..."

try {
    # Set execution policy
    Write-Step "Setting execution policy..."
    Set-ExecutionPolicy Bypass -Scope Process -Force

    # Set TLS protocol
    Write-Step "Configuring TLS protocol..."
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

    # Download and run install script
    Write-Step "Downloading Chocolatey install script..."
    $installScript = (New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')

    Write-Step "Installing Chocolatey..."
    Invoke-Expression $installScript

    # Refresh environment variables
    Write-Step "Refreshing environment variables..."
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    # Verify installation
    if (Test-Command "choco") {
        $version = choco --version
        Write-Success "Chocolatey installed successfully!"
        Write-Info "Version: $version"

        # Configure chocolatey
        Write-Step "Configuring Chocolatey..."
        choco feature enable -n allowGlobalConfirmation
        Write-Info "Enabled global confirmation (no prompts)"

        exit 0
    }
    else {
        Write-ErrorMsg "Chocolatey installation completed but command not found"
        Write-Info "You may need to restart your terminal"
        exit 1
    }
}
catch {
    Write-ErrorMsg "Failed to install Chocolatey: $_"
    Write-Host ""
    Write-Info "Manual installation:"
    Write-Info "Visit: https://chocolatey.org/install"
    exit 1
}
