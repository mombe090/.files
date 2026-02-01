# =============================================================================
# JavaScript Package Installer (Bun)
# =============================================================================
# Install JavaScript packages from YAML configuration using Bun.
#
# Usage:
#   .\install-js-packages.ps1 -Type pro                    # Install professional packages
#   .\install-js-packages.ps1 -Type perso                  # Install personal packages
#   .\install-js-packages.ps1 -Type all                    # Install all packages
#   .\install-js-packages.ps1 -Type pro -Category tools    # Install only tools category
#   .\install-js-packages.ps1 -Force                       # Force reinstall/upgrade
# =============================================================================

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('pro', 'perso', 'all')]
    [string]$Type = 'pro',

    [Parameter(Mandatory = $false)]
    [string]$Category = '',

    [Parameter(Mandatory = $false)]
    [switch]$Force,

    [Parameter(Mandatory = $false)]
    [switch]$CheckUpdate,

    [Parameter(Mandatory = $false)]
    [string]$ConfigDir = "$PSScriptRoot\..\..\configs\packages"
)

# Import libraries
$libPath = "$PSScriptRoot\..\..\lib\pwsh"
. "$libPath\colors.ps1"
. "$libPath\common.ps1"
. "$libPath\detect.ps1"
. "$libPath\package-managers.ps1"

Write-Header "JavaScript Package Installer (Bun)"

# Display system info
$sysInfo = Get-SystemInfo
Write-Info "System: $($sysInfo.OS.ProductName) ($($sysInfo.Architecture))"
Write-Info "PowerShell: $($sysInfo.PowerShell.Version)"
Write-Info "Admin: $($sysInfo.IsAdmin)"

# Check if Bun is installed
Write-Step "Checking for Bun..."

if (-not (Test-BunInstalled)) {
    Write-ErrorMsg "Bun is not installed!"
    Write-Info ""
    Write-Info "Bun is required to install JavaScript packages globally."
    Write-Info "Please install Bun first by running:"
    Write-Info "  .\install.ps1 -Type pro"
    Write-Info ""
    Write-Info "Or install Bun manually:"
    Write-Info "  choco install bun -y"
    exit 1
}

# Get Bun version
$bunVersion = bun --version 2>&1
Write-Success "Bun is installed: v$bunVersion"

# Ensure Bun global bin directory is in PATH
Write-Step "Checking Bun global bin path..."

# Bun installs global packages to: %USERPROFILE%\.bun\bin on Windows
$bunGlobalBin = Join-Path $env:USERPROFILE ".bun\bin"

if (Test-Path $bunGlobalBin) {
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    
    if ($currentPath -notlike "*$bunGlobalBin*") {
        Write-Info "Adding Bun global bin to user PATH..."
        
        try {
            $newPath = "$currentPath;$bunGlobalBin"
            [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
            
            # Also update current session PATH
            $env:Path = "$env:Path;$bunGlobalBin"
            
            Write-Success "Bun global bin added to PATH: $bunGlobalBin"
            Write-Warn "Note: New terminal sessions will have this path automatically."
        }
        catch {
            Write-Warn "Could not add Bun global bin to PATH: $_"
            Write-Info "You may need to manually add: $bunGlobalBin"
        }
    }
    else {
        Write-Success "Bun global bin already in PATH: $bunGlobalBin"
    }
}
else {
    Write-Info "Bun global bin directory will be created on first global package install"
    Write-Info "Expected location: $bunGlobalBin"
}

# Build config file list
# Note: Order matters! Pro packages are always processed first to prevent duplicates
$configFiles = @()

# Always process professional packages first (when perso or all is requested)
if ($Type -eq 'perso' -or $Type -eq 'all') {
    # For perso/all: Install pro packages first to establish baseline
    $configPath = "$ConfigDir\pro\js.pkg.yml"
    if (Test-Path $configPath) {
        $configFiles += $configPath
    }
}
elseif ($Type -eq 'pro') {
    # For pro-only: Just install pro packages
    $configPath = "$ConfigDir\pro\js.pkg.yml"
    if (Test-Path $configPath) {
        $configFiles += $configPath
    }
}

# Then add personal packages if requested
if ($Type -eq 'perso' -or $Type -eq 'all') {
    $configPath = "$ConfigDir\perso\js.pkg.yml"
    if (Test-Path $configPath) {
        $configFiles += $configPath
    }
}

if ($configFiles.Count -eq 0) {
    Write-ErrorMsg "No config files found for type: $Type"
    Write-Info "Expected config file(s):"
    if ($Type -eq 'pro' -or $Type -eq 'all') {
        Write-Info "  $ConfigDir\pro\js.pkg.yml"
    }
    if ($Type -eq 'perso' -or $Type -eq 'all') {
        Write-Info "  $ConfigDir\perso\js.pkg.yml"
    }
    exit 1
}

Write-Info "Will process $($configFiles.Count) config file(s)"

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
        
        # Package entry (handle both regular and scoped packages like @qetza/replacetokens)
        if ($line -match '^\s*-\s*id:\s*(.+)$') {
            # Save previous package if exists
            if ($currentPackage) {
                $packages += $currentPackage
            }
            
            # Extract package ID, handling quotes for scoped packages
            $packageId = $matches[1].Trim()
            $packageId = $packageId -replace '^["'']|["'']$', ''  # Remove surrounding quotes
            
            $currentPackage = [PSCustomObject]@{
                Id = $packageId
                Name = $packageId
                Category = $currentCategory
            }
        }
        # Package name (optional)
        elseif ($line -match '^\s*name:\s*(.+)$') {
            $packageName = $matches[1].Trim()
            if ($currentPackage) {
                $currentPackage.Name = $packageName
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
        Write-Step "[$($package.Category)] $($package.Name)"
        
        # Check if already installed (unless Force is specified)
        if (-not $Force) {
            $isInstalled = Test-BunPackageInstalled -PackageName $package.Id
            
            if ($isInstalled) {
                # Only check for updates if CheckUpdate flag is set
                if ($CheckUpdate) {
                    Write-Info "  Already installed, upgrading to latest version..."
                    
                    # Install/upgrade with Bun (bun add --global will upgrade if newer version available)
                    if (Install-BunPackage -PackageName $package.Id) {
                        Write-Success "  Upgraded to latest version"
                        $totalInstalled++
                    }
                    else {
                        Write-Warn "  Upgrade failed"
                        $totalFailed++
                    }
                }
                else {
                    # Skip update check - just skip already installed packages
                    Write-Success "  Already installed (skipping update check, use -CheckUpdate to upgrade)"
                    $totalSkipped++
                }
                continue
            }
        }
        
        # Install/Reinstall package
        Write-Info "  Installing with Bun..."
        
        if (Install-BunPackage -PackageName $package.Id) {
            if ($Force) {
                Write-Success "  Upgraded/Reinstalled successfully"
            } else {
                Write-Success "  Installed successfully"
            }
            $totalInstalled++
        }
        else {
            Write-ErrorMsg "  Installation failed"
            $totalFailed++
        }
    }
}

# Summary
Write-Header "Installation Summary"
Write-Success "Installed/Upgraded: $totalInstalled"

if ($totalSkipped -gt 0) {
    Write-Warn "Skipped (already installed): $totalSkipped"
}

if ($totalFailed -gt 0) {
    Write-ErrorMsg "Failed: $totalFailed"
    exit 1
}

Write-Success "All JavaScript packages processed successfully!"
exit 0
