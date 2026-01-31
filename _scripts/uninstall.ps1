# =============================================================================
# Windows Dotfiles Uninstaller
# =============================================================================
# Uninstalls packages and PowerShell modules installed by install.ps1
#
# Usage:
#   .\uninstall.ps1                    # Interactive menu
#   .\uninstall.ps1 -Type pro          # Uninstall professional packages
#   .\uninstall.ps1 -Type perso        # Uninstall personal packages
#   .\uninstall.ps1 -UninstallModules  # Only uninstall PowerShell modules
# =============================================================================

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('pro', 'perso', 'all')]
    [string]$Type = '',

    [switch]$UninstallPackages,
    [switch]$UninstallModules,
    [switch]$Force
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
Write-Host "  ╔═══════════════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "  ║                                                   ║" -ForegroundColor Red
Write-Host "  ║       Windows Dotfiles Uninstaller (Work)        ║" -ForegroundColor Red
Write-Host "  ║                                                   ║" -ForegroundColor Red
Write-Host "  ╚═══════════════════════════════════════════════════╝" -ForegroundColor Red
Write-Host ""

# System info
$sysInfo = Get-SystemInfo
Write-Info "System: $($sysInfo.OS.ProductName)"
Write-Info "PowerShell: $($sysInfo.PowerShell.Version)"
Write-Info "Admin: $($sysInfo.IsAdmin)"
Write-Host ""

# Warning
Write-Warn "⚠️  WARNING: This will uninstall packages and modules!"
Write-Host ""

# Interactive menu if no options specified
if (-not $Type -and -not $UninstallModules) {
    Write-Header "What to uninstall?"
    Write-Host ""
    Write-Host "  1. Professional Packages  - Work packages" -ForegroundColor White
    Write-Host "  2. Personal Packages      - Personal packages" -ForegroundColor White
    Write-Host "  3. All Packages           - Everything" -ForegroundColor White
    Write-Host "  4. PowerShell Modules     - Only modules" -ForegroundColor White
    Write-Host ""
    Write-Host "  Q. Cancel" -ForegroundColor Gray
    Write-Host ""
    
    $choice = Read-Host "Select [1-4, Q]"
    
    switch ($choice) {
        "1" { $Type = "pro"; $UninstallPackages = $true }
        "2" { $Type = "perso"; $UninstallPackages = $true }
        "3" { $Type = "all"; $UninstallPackages = $true }
        "4" { $UninstallModules = $true }
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

# Auto-enable UninstallPackages if Type is specified
if ($Type -and -not $UninstallModules) {
    $UninstallPackages = $true
}

# Confirmation
if (-not $Force) {
    Write-Host ""
    Write-Warn "Are you sure you want to continue? (y/N)"
    $confirm = Read-Host
    if ($confirm -ne 'y' -and $confirm -ne 'Y') {
        Write-Info "Cancelled"
        exit 0
    }
}

# Uninstall packages
if ($UninstallPackages -and $Type) {
    Write-Header "Uninstalling Packages: $Type"
    
    # Check for package manager
    $pm = Get-PackageManager
    if (-not $pm) {
        Write-ErrorMsg "No package manager found (winget or choco)"
        exit 1
    }
    
    Write-Info "Using package manager: $pm"
    
    # Load package config
    $configPath = Join-Path $ScriptRoot "configs\packages\$Type\$pm.pkg.yml"
    
    if (-not (Test-Path $configPath)) {
        Write-ErrorMsg "Config file not found: $configPath"
        exit 1
    }
    
    Write-Info "Loading config: $configPath"
    
    # Parse YAML (simple parsing for our structure)
    $content = Get-Content $configPath -Raw
    $packages = @()
    
    # Extract package IDs (very simple YAML parsing)
    $content -split "`n" | ForEach-Object {
        if ($_ -match '^\s*-\s*id:\s*(.+)$') {
            $packages += $matches[1].Trim()
        }
    }
    
    Write-Info "Found $($packages.Count) package(s) to uninstall"
    Write-Host ""
    
    $uninstalled = 0
    $failed = 0
    $skipped = 0
    
    foreach ($pkg in $packages) {
        Write-Step "Uninstalling: $pkg"
        
        try {
            if ($pm -eq 'winget') {
                $result = winget uninstall --id $pkg --silent --accept-source-agreements 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "  Uninstalled"
                    $uninstalled++
                }
                elseif ($result -match "No installed package found") {
                    Write-Info "  Not installed, skipping"
                    $skipped++
                }
                else {
                    Write-Warn "  Failed to uninstall"
                    $failed++
                }
            }
            elseif ($pm -eq 'choco') {
                choco uninstall $pkg -y --limit-output 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "  Uninstalled"
                    $uninstalled++
                }
                else {
                    Write-Warn "  Failed to uninstall"
                    $failed++
                }
            }
        }
        catch {
            Write-Warn "  Error: $_"
            $failed++
        }
    }
    
    Write-Host ""
    Write-Header "Package Uninstallation Summary"
    Write-Info "Uninstalled: $uninstalled"
    Write-Info "Skipped: $skipped"
    Write-Info "Failed: $failed"
}

# Uninstall PowerShell modules
if ($UninstallModules) {
    Write-Host ""
    Write-Header "Uninstalling PowerShell Modules"
    
    $modules = @('Terminal-Icons', 'posh-git')
    
    foreach ($moduleName in $modules) {
        Write-Step "Uninstalling: $moduleName"
        
        try {
            if (Get-Module -ListAvailable -Name $moduleName) {
                Uninstall-Module -Name $moduleName -Force -ErrorAction SilentlyContinue
                Write-Success "  Uninstalled"
            }
            else {
                Write-Info "  Not installed, skipping"
            }
        }
        catch {
            Write-Warn "  Error: $_"
        }
    }
    
    Write-Info "Note: PSReadLine is a system module and cannot be uninstalled"
}

# Done
Write-Host ""
Write-Header "Uninstallation Complete!"
Write-Success "Cleanup finished"
Write-Host ""

exit 0
