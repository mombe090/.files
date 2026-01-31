# =============================================================================
# Windows Dotfiles Installer
# =============================================================================
# Simple installer for Windows work environment.
# Installs: packages, PowerShell modules.
#
# Usage:
#   .\install.ps1                    # Interactive menu
#   .\install.ps1 -Type pro          # Professional packages only
#   .\install.ps1 -Type perso        # Personal packages only
# =============================================================================

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('pro', 'perso', 'all')]
    [string]$Type = '',

    [switch]$SkipPackages,
    [switch]$SkipModules
)

# Determine script root
$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }

# Import libraries
$libPath = Join-Path $ScriptRoot "lib\pwsh"
. "$libPath\colors.ps1"
. "$libPath\common.ps1"
. "$libPath\detect.ps1"
. "$libPath\package-managers.ps1"

# Clear screen
Clear-Host

# Banner
Write-Host ""
Write-Host "  ╔═══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║                                                   ║" -ForegroundColor Cyan
Write-Host "  ║        Windows Dotfiles Installer (Work)         ║" -ForegroundColor Cyan
Write-Host "  ║                                                   ║" -ForegroundColor Cyan
Write-Host "  ╚═══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# System info
$sysInfo = Get-SystemInfo
Write-Info "System: $($sysInfo.OS.ProductName)"
Write-Info "PowerShell: $($sysInfo.PowerShell.Version)"
Write-Info "Admin: $($sysInfo.IsAdmin)"
Write-Host ""

# Interactive menu if no type specified
if (-not $Type) {
    Write-Header "What to install?"
    Write-Host ""
    Write-Host "  1. Professional  - Work-safe packages (git, vscode, etc.)" -ForegroundColor White
    Write-Host "  2. Personal      - Personal packages (games, media, etc.)" -ForegroundColor White
    Write-Host "  3. Both          - Everything" -ForegroundColor White
    Write-Host ""
    Write-Host "  Q. Quit" -ForegroundColor Gray
    Write-Host ""
    
    $choice = Read-Host "Select [1-3, Q]"
    
    switch ($choice) {
        "1" { $Type = "pro" }
        "2" { $Type = "perso" }
        "3" { $Type = "all" }
        "Q" {
            Write-Info "Cancelled"
            exit 0
        }
        default {
            Write-ErrorMsg "Invalid choice"
            exit 1
        }
    }
}

Write-Header "Installing: $Type packages"

# Step 1: Ensure package managers
if (-not $SkipPackages) {
    Write-Header "Step 1: Package Managers"
    
    # Check for winget
    $hasWinget = Test-Command "winget"
    if (-not $hasWinget) {
        Write-Info "Installing winget..."
        & "$ScriptRoot\installers\pwsh\winget.ps1"
        
        if ($LASTEXITCODE -eq 0) {
            $hasWinget = $true
            Write-Success "winget installed"
        }
        else {
            Write-Warn "Failed to install winget"
        }
    }
    else {
        Write-Success "winget: already installed"
    }
    
    # Check for Chocolatey
    $hasChoco = Test-Command "choco"
    if (-not $hasChoco) {
        Write-Info "Installing Chocolatey..."
        
        # Try to install via winget first
        if ($hasWinget) {
            Write-Info "Attempting to install Chocolatey via winget..."
            winget install --id Chocolatey.Chocolatey --silent --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
            
            # Refresh environment to pick up choco
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            
            $hasChoco = Test-Command "choco"
        }
        
        # Fallback to PowerShell install script
        if (-not $hasChoco) {
            Write-Info "Installing Chocolatey via PowerShell script..."
            if (Install-Chocolatey) {
                $hasChoco = $true
                Write-Success "Chocolatey installed"
            }
            else {
                Write-Warn "Failed to install Chocolatey"
            }
        }
        else {
            Write-Success "Chocolatey installed via winget"
        }
    }
    else {
        Write-Success "Chocolatey: already installed"
    }
    
    # Verify at least one package manager is available
    if (-not $hasWinget -and -not $hasChoco) {
        Write-ErrorMsg "No package manager available. Installation cannot continue."
        exit 1
    }
    
    $installedManagers = @()
    if ($hasChoco) { $installedManagers += "choco" }
    if ($hasWinget) { $installedManagers += "winget" }
    
    Write-Success "Available package managers: $($installedManagers -join ', ')"
}

# Step 2: Install packages
if (-not $SkipPackages) {
    Write-Header "Step 2: Installing Packages"
    
    & "$ScriptRoot\windows\pwsh\install-packages.ps1" -Type $Type
    
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "Some packages failed to install"
    }
}

# Step 3: Install PowerShell modules
if (-not $SkipModules) {
    Write-Header "Step 3: PowerShell Modules"
    
    & "$ScriptRoot\windows\pwsh\setup-windows.ps1"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "Some modules failed to install"
    }
}

# Done
Write-Header "Installation Complete!"
Write-Success "Windows environment configured"
Write-Host ""
Write-Info "Next steps:"
Write-Host "  • Restart your terminal" -ForegroundColor White
Write-Host "  • Set Windows Terminal default to PowerShell 7" -ForegroundColor White
Write-Host "  • Install fonts manually via package manager if needed" -ForegroundColor White
Write-Host "    winget install: Cascadia.Fonts, JetBrains.JetBrainsMono" -ForegroundColor Gray
Write-Host ""
Write-Success "Done! 🎉"

exit 0
