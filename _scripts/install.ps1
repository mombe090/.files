# =============================================================================
# Windows Dotfiles Installer
# =============================================================================
# Simple installer for Windows work environment.
# Installs: packages, PowerShell modules.
#
# Usage:
#   .\install.ps1                              # Interactive menu
#   .\install.ps1 -Type pro                    # Professional packages only
#   .\install.ps1 -Type perso                  # Personal packages only
#   .\install.ps1 -Type pro -PackageManager choco    # Only Chocolatey packages
#   .\install.ps1 -Type pro -PackageManager winget   # Only winget packages
# =============================================================================

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('pro', 'perso', 'all')]
    [string]$Type = '',

    [Parameter(Mandatory = $false)]
    [ValidateSet('auto', 'choco', 'winget', 'both')]
    [string]$PackageManager = 'both',

    [switch]$SkipPackages,
    [switch]$SkipModules,
    [switch]$CheckUpdate
)

# Determine script root
$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }

# Import libraries
$libPath = Join-Path $ScriptRoot "_scripts\windows\lib"
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
        & "$ScriptRoot\_scripts\windows\managers\Install-WinGet.ps1"
        
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
    
    # Determine which package managers to use
    $managersToUse = @()
    
    switch ($PackageManager) {
        'choco' {
            if ($hasChoco) {
                $managersToUse += 'choco'
            } else {
                Write-Warn "Chocolatey requested but not available"
            }
        }
        'winget' {
            if ($hasWinget) {
                $managersToUse += 'winget'
            } else {
                Write-Warn "winget requested but not available"
            }
        }
        'both' {
            # Default: run choco first, then winget
            if ($hasChoco) { $managersToUse += 'choco' }
            if ($hasWinget) { $managersToUse += 'winget' }
        }
        'auto' {
            # Auto: use whatever is available, prefer choco
            if ($hasChoco) { 
                $managersToUse += 'choco' 
            } elseif ($hasWinget) { 
                $managersToUse += 'winget' 
            }
        }
    }
    
    if ($managersToUse.Count -eq 0) {
        Write-ErrorMsg "No package managers available for installation"
        exit 1
    }
    
    Write-Info "Using package managers: $($managersToUse -join ', ')"
    
    # Determine installation order to prevent duplicates
    # Personal and All installations should always install Pro packages first
    $installOrder = @()
    
    if ($Type -eq 'perso' -or $Type -eq 'all') {
        # Always install pro packages first to establish baseline
        $installOrder += 'pro'
    }
    
    if ($Type -eq 'perso') {
        # Then install personal packages (non-duplicates only)
        $installOrder += 'perso'
    }
    elseif ($Type -eq 'pro') {
        # Just pro packages
        $installOrder += 'pro'
    }
    # Note: 'all' is handled by adding 'pro' above, perso will be added next
    
    if ($Type -eq 'all') {
        # Add perso after pro for 'all' type
        $installOrder += 'perso'
    }
    
    # Install packages using selected managers in proper order
    foreach ($installType in $installOrder) {
        Write-Header "Installing $installType packages"
        
        foreach ($pm in $managersToUse) {
            Write-Info "Installing $installType packages via $pm..."
            
            # Pass CheckUpdate flag if specified
            if ($CheckUpdate) {
                & "$ScriptRoot\_scripts\windows\installers\Install-Packages.ps1" -Type $installType -PackageManager $pm -CheckUpdate
            }
            else {
                & "$ScriptRoot\_scripts\windows\installers\Install-Packages.ps1" -Type $installType -PackageManager $pm
            }
            
            if ($LASTEXITCODE -ne 0) {
                Write-Warn "Some $pm packages failed to install"
            }
        }
    }
}

# Step 3: Install JavaScript packages (via Bun)
if (-not $SkipPackages) {
    Write-Header "Step 3: JavaScript Packages (Bun)"
    
    # Check if Bun is installed (should be from pro packages)
    $hasBun = Test-Command "bun"
    
    if ($hasBun) {
        Write-Success "Bun detected, installing JavaScript packages..."
        
        # Install JS packages following same order as system packages
        foreach ($installType in $installOrder) {
            # Check if JS package config exists for this type
            $jsConfigPath = "$ScriptRoot\_scripts\configs\windows\packages\$installType\js.pkg.yml"
            
            if (Test-Path $jsConfigPath) {
                Write-Info "Installing $installType JavaScript packages..."
                
                # Pass CheckUpdate flag if specified
                if ($CheckUpdate) {
                    & "$ScriptRoot\_scripts\windows\installers\Install-JsPackages.ps1" -Type $installType -CheckUpdate
                }
                else {
                    & "$ScriptRoot\_scripts\windows\installers\Install-JsPackages.ps1" -Type $installType
                }
                
                if ($LASTEXITCODE -ne 0) {
                    Write-Warn "Some JavaScript packages failed to install"
                }
            }
            else {
                Write-Info "No JavaScript packages configured for $installType (file not found: $jsConfigPath)"
            }
        }
    }
    else {
        Write-Warn "Bun not found, skipping JavaScript packages"
        Write-Info "To install JavaScript packages, first install Bun with professional packages"
    }
}

# Step 4: Install PowerShell modules
if (-not $SkipModules) {
    Write-Header "Step 4: PowerShell Modules"
    
    & "$ScriptRoot\_scripts\windows\installers\Setup-Windows.ps1"
    
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
Write-Success "Done!"

exit 0
