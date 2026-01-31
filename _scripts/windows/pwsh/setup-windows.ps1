# =============================================================================
# Windows User Setup Script
# =============================================================================
# Simple user-level configuration: PowerShell modules only.
# No registry changes, no admin required.
#
# Usage:
#   .\setup-windows.ps1
# =============================================================================

# Import libraries
$libPath = "$PSScriptRoot\..\..\lib\pwsh"
. "$libPath\colors.ps1"
. "$libPath\common.ps1"
. "$libPath\detect.ps1"

Write-Header "PowerShell User Setup"

# Display system info
$sysInfo = Get-SystemInfo
Write-Info "System: $($sysInfo.OS.ProductName)"
Write-Info "PowerShell: $($sysInfo.PowerShell.Version)"

# Install PowerShell modules (user scope only)
Write-Header "Installing PowerShell Modules"

$modules = @(
    @{ Name = 'PSReadLine'; Description = 'Better command-line editing' },
    @{ Name = 'Terminal-Icons'; Description = 'File icons in terminal' },
    @{ Name = 'posh-git'; Description = 'Git status in prompt' }
)

foreach ($module in $modules) {
    Write-Step "Checking: $($module.Name)"
    
    if (Get-Module -ListAvailable -Name $module.Name) {
        Write-Success "Already installed"
    }
    else {
        Write-Info "Installing: $($module.Description)"
        try {
            Install-Module -Name $module.Name -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
            Write-Success "Installed: $($module.Name)"
        }
        catch {
            Write-ErrorMsg "Failed to install $($module.Name): $_"
        }
    }
}

# Summary
Write-Header "Setup Complete!"
Write-Success "PowerShell modules installed"
Write-Host ""
Write-Info "Modules installed:"
Write-Info "  • PSReadLine - Better command-line editing with IntelliSense"
Write-Info "  • Terminal-Icons - Colorful file/folder icons"
Write-Info "  • posh-git - Git status in your PowerShell prompt"
Write-Host ""
Write-Info "Restart your terminal to use the new modules"

exit 0
