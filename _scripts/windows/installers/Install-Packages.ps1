# =============================================================================
# Windows Package Installer
# =============================================================================
# Install packages from YAML configuration using winget or chocolatey.
#
# Usage:
#   .\install-packages.ps1 -Type pro                    # Install professional packages
#   .\install-packages.ps1 -Type perso                  # Install personal packages
#   .\install-packages.ps1 -Type all                    # Install all packages
#   .\install-packages.ps1 -Type pro -Category tools    # Install only tools category
#   .\install-packages.ps1 -PackageManager choco        # Force chocolatey
# =============================================================================

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('pro', 'perso', 'all')]
    [string]$Type = 'pro',

    [Parameter(Mandatory = $false)]
    [string]$Category = '',

    [Parameter(Mandatory = $false)]
    [ValidateSet('auto', 'winget', 'choco')]
    [string]$PackageManager = 'auto',

    [Parameter(Mandatory = $false)]
    [string]$ConfigDir = "$PSScriptRoot\..\..\configs\windows\packages",

    [Parameter(Mandatory = $false)]
    [switch]$CheckUpdate
)

# Import libraries
$libPath = "$PSScriptRoot\..\lib"
. "$libPath\colors.ps1"
. "$libPath\common.ps1"
. "$libPath\detect.ps1"
. "$libPath\package-managers.ps1"

Write-Header "Windows Package Installer"

# Display system info
$sysInfo = Get-SystemInfo
Write-Info "System: $($sysInfo.OS.ProductName) ($($sysInfo.Architecture))"
Write-Info "PowerShell: $($sysInfo.PowerShell.Version)"
Write-Info "Admin: $($sysInfo.IsAdmin)"

# Check available package managers
Write-Step "Checking package managers..."

$hasWinget = Test-Command "winget"
$hasChoco = Test-Command "choco"

if (-not $hasWinget -and -not $hasChoco) {
    Write-ErrorMsg "No package manager found. Please run install.ps1 first."
    exit 1
}

$availableManagers = @()
if ($hasChoco) { $availableManagers += "choco" }
if ($hasWinget) { $availableManagers += "winget" }

Write-Success "Available package managers: $($availableManagers -join ', ')"

# Determine config files to use based on PackageManager parameter
$configFiles = @()

# Determine which package managers to process
$packageManagers = @()
switch ($PackageManager) {
    'choco' {
        if ($hasChoco) {
            $packageManagers += 'choco'
        } else {
            Write-ErrorMsg "Chocolatey requested but not available"
            exit 1
        }
    }
    'winget' {
        if ($hasWinget) {
            $packageManagers += 'winget'
        } else {
            Write-ErrorMsg "winget requested but not available"
            exit 1
        }
    }
    'auto' {
        # Auto: use both if available, prioritize choco
        if ($hasChoco) { $packageManagers += 'choco' }
        if ($hasWinget) { $packageManagers += 'winget' }
    }
}

# Build config file list for each package manager
# Note: Order matters! Pro packages are always processed first to prevent duplicates
foreach ($pkgMgr in $packageManagers) {
    # Always process professional packages first (when perso or all is requested)
    if ($Type -eq 'perso' -or $Type -eq 'all') {
        # For perso/all: Install pro packages first to establish baseline
        $configPath = "$ConfigDir\pro\$pkgMgr.pkg.yml"
        if (Test-Path $configPath) {
            $configFiles += [PSCustomObject]@{
                Path = $configPath
                PackageManager = $pkgMgr
                Type = 'pro'
            }
        }
    }
    elseif ($Type -eq 'pro') {
        # For pro-only: Just install pro packages
        $configPath = "$ConfigDir\pro\$pkgMgr.pkg.yml"
        if (Test-Path $configPath) {
            $configFiles += [PSCustomObject]@{
                Path = $configPath
                PackageManager = $pkgMgr
                Type = 'pro'
            }
        }
    }

    # Then add personal packages if requested
    if ($Type -eq 'perso' -or $Type -eq 'all') {
        $configPath = "$ConfigDir\perso\$pkgMgr.pkg.yml"
        if (Test-Path $configPath) {
            $configFiles += [PSCustomObject]@{
                Path = $configPath
                PackageManager = $pkgMgr
                Type = 'perso'
            }
        }
    }
}

if ($configFiles.Count -eq 0) {
    Write-ErrorMsg "No config files found"
    exit 1
}

Write-Info "Will process $($configFiles.Count) config file(s) using: $($packageManagers -join ', ')"

# Parse and install packages
$totalInstalled = 0
$totalFailed = 0
$totalSkipped = 0

foreach ($configFile in $configFiles) {
    $pm = $configFile.PackageManager
    $pkgType = $configFile.Type
    Write-Header "Processing: $(Split-Path $configFile.Path -Leaf) [$pkgType/$pm]"

    # Read config
    $configContent = Get-Content -Path $configFile.Path -Raw
    $lines = $configContent -split "`n"

    $packages = @()
    $currentCategory = ""
    $currentPackage = $null

    foreach ($line in $lines) {
        $line = $line.Trim()

        # Skip comments and empty lines
        if ($line -match '^\s*#' -or $line -eq '') {
            continue
        }

        # Category header
        if ($line -match '^(\w+):$') {
            $currentCategory = $matches[1]
            continue
        }

        # Package entry
        if ($line -match '^\s*-\s*id:\s*(.+)$') {
            # Save previous package if exists
            if ($currentPackage) {
                $packages += $currentPackage
            }

            $packageId = $matches[1].Trim()
            $currentPackage = [PSCustomObject]@{
                Id = $packageId
                Category = $currentCategory
                Uninstallable = $false
            }
        }
        # Uninstallable flag
        elseif ($line -match '^\s*uninstallable:\s*(.+)$') {
            $uninstallableValue = $matches[1].Trim()
            if ($currentPackage) {
                $currentPackage.Uninstallable = ($uninstallableValue -eq 'true')
            }
        }
    }

    # Add last package
    if ($currentPackage) {
        $packages += $currentPackage
    }

    Write-Info "Found $($packages.Count) package(s)"

    # Filter by category if specified
    if ($Category) {
        $packages = $packages | Where-Object { $_.Category -eq $Category }
        Write-Info "Filtered to $($packages.Count) package(s) in category '$Category'"
    }

    # Install packages
    foreach ($package in $packages) {
        Write-Step "[$($package.Category)] $($package.Id)"

        # Check if already installed
        $isInstalled = Test-PackageInstalled -PackageName $package.Id -PackageManager $pm

        if ($isInstalled) {
            # Only check for updates if CheckUpdate flag is set
            if ($CheckUpdate) {
                Write-Info "  Already installed, checking for updates..."

                # Check if update is available
                $updateAvailable = Test-PackageUpdateAvailable -PackageName $package.Id -PackageManager $pm

                if ($updateAvailable) {
                    Write-Info "  Update available, upgrading..."

                    # Try to upgrade
                    $upgraded = $false
                    if ($pm -eq 'choco') {
                        choco upgrade $package.Id -y --limit-output 2>&1 | Out-Null
                        if ($LASTEXITCODE -eq 0) {
                            $upgraded = $true
                        }
                    }
                    elseif ($pm -eq 'winget') {
                        winget upgrade --id $package.Id --silent --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
                        if ($LASTEXITCODE -eq 0) {
                            $upgraded = $true
                        }
                    }

                    if ($upgraded) {
                        Write-Success "  Updated to latest version"
                        $totalInstalled++
                    }
                    else {
                        Write-Warn "  Upgrade failed"
                        $totalFailed++
                    }
                }
                else {
                    Write-Success "  Already at latest version"
                    $totalSkipped++
                }
            }
            else {
                # Skip update check - just skip already installed packages
                Write-Success "  Already installed (skipping update check)"
                $totalSkipped++
            }
        }
        else {
            # Install
            if (Install-Package -PackageName $package.Id -PackageManager $pm) {
                Write-Success "  Installed successfully"
                $totalInstalled++
            }
            else {
                Write-ErrorMsg "  Installation failed"
                $totalFailed++
            }
        }
    }
}

# Summary
Write-Header "Installation Summary"
Write-Success "Installed: $totalInstalled"
Write-Warn "Skipped: $totalSkipped"

if ($totalFailed -gt 0) {
    Write-ErrorMsg "Failed: $totalFailed"
    exit 1
}

Write-Success "All packages installed successfully!"
exit 0
