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
    [string]$ConfigDir = "$PSScriptRoot\..\..\configs\packages"
)

# Import libraries
$libPath = "$PSScriptRoot\..\..\lib\pwsh"
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

# Ensure package manager is available
Write-Step "Checking package managers..."
$pm = Get-PackageManager -Preferred $PackageManager

if (-not $pm) {
    Write-Info "No package manager found. Installing winget..."
    if (-not (Install-WinGet)) {
        Write-ErrorMsg "Failed to install package manager. Exiting."
        exit 1
    }
    $pm = 'winget'
}

Write-Success "Using package manager: $pm"

# Determine config files to use
$configFiles = @()

if ($Type -eq 'pro' -or $Type -eq 'all') {
    $configFiles += "$ConfigDir\pro\$pm.pkg.yml"
}

if ($Type -eq 'perso' -or $Type -eq 'all') {
    $configFiles += "$ConfigDir\perso\$pm.pkg.yml"
}

# Verify config files exist
foreach ($config in $configFiles) {
    if (-not (Test-Path $config)) {
        Write-ErrorMsg "Config file not found: $config"
        exit 1
    }
}

Write-Info "Config files: $($configFiles -join ', ')"

# Parse and install packages
$totalInstalled = 0
$totalFailed = 0
$totalSkipped = 0

foreach ($configFile in $configFiles) {
    Write-Header "Processing: $(Split-Path $configFile -Leaf)"
    
    # Read config
    $configContent = Get-Content -Path $configFile -Raw
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
            Write-Info "  Already installed, checking for updates..."
            
            # Try to upgrade
            $upgraded = $false
            if ($pm -eq 'choco') {
                choco upgrade $package.Id -y --limit-output 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    $upgraded = $true
                }
            }
            elseif ($pm -eq 'winget') {
                winget upgrade --id $package.Id --silent --accept-source-agreements 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    $upgraded = $true
                }
            }
            
            if ($upgraded) {
                Write-Success "  Updated to latest version"
                $totalInstalled++
            }
            else {
                Write-Info "  Already up-to-date"
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
