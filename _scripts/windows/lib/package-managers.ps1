# =============================================================================
# Package Manager Functions for Windows
# =============================================================================
# This module provides package manager abstraction for winget and chocolatey.
#
# Functions:
#   - Get-PackageManager: Detect available package manager
#   - Install-Package: Install a package using detected manager
#   - Test-PackageInstalled: Check if a package is installed
#   - Update-Package: Update a package
#   - Uninstall-Package: Uninstall a package
#   - Install-WinGet: Ensure winget is installed
#   - Install-Chocolatey: Ensure chocolatey is installed
#   - Get-PackageList: Get list of installed packages
# =============================================================================

. "$PSScriptRoot\colors.ps1"
. "$PSScriptRoot\common.ps1"
. "$PSScriptRoot\detect.ps1"

<#
.SYNOPSIS
    Detect available package manager.

.DESCRIPTION
    Checks for chocolatey (preferred) and winget, returns the best available option.

.PARAMETER Preferred
    Preferred package manager ('winget' or 'choco'). Default: 'auto' (prefers choco)

.EXAMPLE
    Get-PackageManager
    Get-PackageManager -Preferred 'winget'

.OUTPUTS
    String - 'winget', 'choco', or $null if none available
#>
function Get-PackageManager {
    param(
        [ValidateSet('winget', 'choco', 'auto')]
        [string]$Preferred = 'auto'
    )

    $hasWinget = Test-Command "winget"
    $hasChoco = Test-Command "choco"

    if ($Preferred -eq 'auto') {
        # Prefer choco if available
        if ($hasChoco) {
            return 'choco'
        }
        elseif ($hasWinget) {
            return 'winget'
        }
        else {
            return $null
        }
    }
    elseif ($Preferred -eq 'winget' -and $hasWinget) {
        return 'winget'
    }
    elseif ($Preferred -eq 'choco' -and $hasChoco) {
        return 'choco'
    }
    else {
        return $null
    }
}

<#
.SYNOPSIS
    Install a package using the detected package manager.

.DESCRIPTION
    Installs a package with the specified package manager or auto-detected one.

.PARAMETER PackageName
    The name/ID of the package to install.

.PARAMETER PackageManager
    Package manager to use ('winget', 'choco', or 'auto'). Default: 'auto'

.PARAMETER Silent
    Install silently without prompts. Default: $true

.PARAMETER AcceptLicense
    Accept license agreements automatically. Default: $true

.EXAMPLE
    Install-Package -PackageName "git"
    Install-Package -PackageName "Microsoft.PowerShell" -PackageManager "winget"

.OUTPUTS
    Boolean - $true if successful, $false otherwise
#>
function Install-Package {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName,

        [ValidateSet('winget', 'choco', 'auto')]
        [string]$PackageManager = 'auto',

        [bool]$Silent = $true,

        [bool]$AcceptLicense = $true
    )

    $pm = if ($PackageManager -eq 'auto') {
        Get-PackageManager
    }
    else {
        $PackageManager
    }

    if (-not $pm) {
        Write-ErrorMsg "No package manager available. Please install winget or chocolatey."
        return $false
    }

    Write-Step "Installing $PackageName using $pm..."

    try {
        switch ($pm) {
            'winget' {
                $args = @('install', '--id', $PackageName, '--exact')
                if ($Silent) {
                    $args += '--silent'
                }
                if ($AcceptLicense) {
                    $args += '--accept-package-agreements'
                    $args += '--accept-source-agreements'
                }

                $process = Start-Process -FilePath "winget" -ArgumentList $args -NoNewWindow -Wait -PassThru
                return $process.ExitCode -eq 0
            }

            'choco' {
                $args = @('install', $PackageName, '-y')
                if ($Silent) {
                    $args += '--limit-output'
                }

                # Run choco directly (requires admin privileges)
                & choco @args
                return $LASTEXITCODE -eq 0
            }
        }
    }
    catch {
        Write-ErrorMsg "Failed to install $PackageName : $_"
        return $false
    }

    return $false
}

<#
.SYNOPSIS
    Check if a package is installed.

.DESCRIPTION
    Tests whether a package is installed using the specified package manager.

.PARAMETER PackageName
    The name/ID of the package to check.

.PARAMETER PackageManager
    Package manager to use ('winget', 'choco', or 'auto'). Default: 'auto'

.EXAMPLE
    Test-PackageInstalled -PackageName "git"

.OUTPUTS
    Boolean - $true if installed, $false otherwise
#>
function Test-PackageInstalled {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName,

        [ValidateSet('winget', 'choco', 'auto')]
        [string]$PackageManager = 'auto'
    )

    $pm = if ($PackageManager -eq 'auto') {
        Get-PackageManager
    }
    else {
        $PackageManager
    }

    if (-not $pm) {
        return $false
    }

    try {
        switch ($pm) {
            'winget' {
                $result = winget list --id $PackageName --exact 2>&1 | Out-String
                return $result -match $PackageName
            }

            'choco' {
                # Use --limit-output for machine-readable format: package|version
                $result = choco list --local-only --limit-output --exact $PackageName 2>&1 | Out-String
                # If package is installed, choco returns: packagename|version
                # If not installed, returns empty
                return ($result.Trim() -ne '' -and $result -match $PackageName)
            }
        }
    }
    catch {
        return $false
    }

    return $false
}

<#
.SYNOPSIS
    Update a package.

.DESCRIPTION
    Updates a package using the specified package manager.

.PARAMETER PackageName
    The name/ID of the package to update.

.PARAMETER PackageManager
    Package manager to use ('winget', 'choco', or 'auto'). Default: 'auto'

.EXAMPLE
    Update-Package -PackageName "git"

.OUTPUTS
    Boolean - $true if successful, $false otherwise
#>
function Update-Package {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName,

        [ValidateSet('winget', 'choco', 'auto')]
        [string]$PackageManager = 'auto'
    )

    $pm = if ($PackageManager -eq 'auto') {
        Get-PackageManager
    }
    else {
        $PackageManager
    }

    if (-not $pm) {
        Write-ErrorMsg "No package manager available."
        return $false
    }

    Write-Step "Updating $PackageName using $pm..."

    try {
        switch ($pm) {
            'winget' {
                $process = Start-Process -FilePath "winget" -ArgumentList @('upgrade', '--id', $PackageName, '--exact', '--silent', '--accept-package-agreements', '--accept-source-agreements') -NoNewWindow -Wait -PassThru
                return $process.ExitCode -eq 0
            }

            'choco' {
                & choco upgrade $PackageName -y
                return $LASTEXITCODE -eq 0
            }
        }
    }
    catch {
        Write-ErrorMsg "Failed to update $PackageName : $_"
        return $false
    }

    return $false
}

<#
.SYNOPSIS
    Uninstall a package.

.DESCRIPTION
    Uninstalls a package using the specified package manager.

.PARAMETER PackageName
    The name/ID of the package to uninstall.

.PARAMETER PackageManager
    Package manager to use ('winget', 'choco', or 'auto'). Default: 'auto'

.EXAMPLE
    Uninstall-Package -PackageName "git"

.OUTPUTS
    Boolean - $true if successful, $false otherwise
#>
function Uninstall-Package {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName,

        [ValidateSet('winget', 'choco', 'auto')]
        [string]$PackageManager = 'auto'
    )

    $pm = if ($PackageManager -eq 'auto') {
        Get-PackageManager
    }
    else {
        $PackageManager
    }

    if (-not $pm) {
        Write-ErrorMsg "No package manager available."
        return $false
    }

    Write-Step "Uninstalling $PackageName using $pm..."

    try {
        switch ($pm) {
            'winget' {
                $process = Start-Process -FilePath "winget" -ArgumentList @('uninstall', '--id', $PackageName, '--exact', '--silent') -NoNewWindow -Wait -PassThru
                return $process.ExitCode -eq 0
            }

            'choco' {
                & choco uninstall $PackageName -y
                return $LASTEXITCODE -eq 0
            }
        }
    }
    catch {
        Write-ErrorMsg "Failed to uninstall $PackageName : $_"
        return $false
    }

    return $false
}

<#
.SYNOPSIS
    Ensure winget is installed.

.DESCRIPTION
    Checks if winget is installed and attempts to install it if missing.

.EXAMPLE
    Install-WinGet

.OUTPUTS
    Boolean - $true if winget is available, $false otherwise
#>
function Install-WinGet {
    if (Test-Command "winget") {
        Write-Success "winget is already installed"
        return $true
    }

    Write-Info "winget not found. Installing via App Installer..."

    try {
        # Install via Microsoft Store (App Installer)
        $progressPreference = 'silentlyContinue'
        Write-Info "Installing WinGet PowerShell module from PSGallery..."
        Install-PackageProvider -Name NuGet -Force | Out-Null
        Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null

        Write-Info "Using Repair-WinGetPackageManager cmdlet to bootstrap WinGet..."
        Repair-WinGetPackageManager -AllUsers

        Write-Success "winget installed successfully"
        return $true
    }
    catch {
        Write-ErrorMsg "Failed to install winget: $_"
        Write-Info "Please install manually from: https://aka.ms/getwinget"
        return $false
    }
}

<#
.SYNOPSIS
    Ensure chocolatey is installed.

.DESCRIPTION
    Checks if chocolatey is installed and attempts to install it if missing.

.EXAMPLE
    Install-Chocolatey

.OUTPUTS
    Boolean - $true if chocolatey is available, $false otherwise
#>
function Install-Chocolatey {
    if (Test-Command "choco") {
        Write-Success "Chocolatey is already installed"
        return $true
    }

    Write-Info "Chocolatey not found. Installing..."

    # Require admin for chocolatey
    if (-not (Test-IsAdmin)) {
        Write-ErrorMsg "Installing Chocolatey requires administrator privileges."
        return $false
    }

    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

        # Refresh environment
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

        if (Test-Command "choco") {
            Write-Success "Chocolatey installed successfully"
            return $true
        }
        else {
            Write-ErrorMsg "Chocolatey installation completed but command not found"
            return $false
        }
    }
    catch {
        Write-ErrorMsg "Failed to install Chocolatey: $_"
        return $false
    }
}

<#
.SYNOPSIS
    Check if a package has updates available.

.DESCRIPTION
    Checks if a newer version of the package is available.

.PARAMETER PackageName
    The name/ID of the package to check.

.PARAMETER PackageManager
    Package manager to use ('winget', 'choco', or 'auto'). Default: 'auto'

.EXAMPLE
    Test-PackageUpdateAvailable -PackageName "git"

.OUTPUTS
    Boolean - $true if update available, $false otherwise
#>
function Test-PackageUpdateAvailable {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName,

        [ValidateSet('winget', 'choco', 'auto')]
        [string]$PackageManager = 'auto'
    )

    $pm = if ($PackageManager -eq 'auto') {
        Get-PackageManager
    }
    else {
        $PackageManager
    }

    if (-not $pm) {
        return $false
    }

    try {
        switch ($pm) {
            'winget' {
                $result = winget upgrade --id $PackageName --exact 2>&1 | Out-String
                # If "No applicable update found" or package is not in the list, no update available
                if ($result -match "No applicable update found" -or $result -match "No installed package found") {
                    return $false
                }
                # If package appears in upgrade list, update is available
                return $result -match $PackageName
            }

            'choco' {
                # Use --limit-output for machine-readable format
                # Choco outdated returns: packagename|currentversion|availableversion|pinned
                # Returns empty if package is up-to-date
                $result = choco outdated --limit-output --exact $PackageName 2>&1 | Out-String
                # If result contains package name, update is available
                $hasUpdate = ($result.Trim() -ne '' -and $result -match $PackageName)
                return $hasUpdate
            }
        }
    }
    catch {
        return $false
    }

    return $false
}

<#
.SYNOPSIS
    Get list of installed packages.

.DESCRIPTION
    Returns a list of installed packages from the specified package manager.

.PARAMETER PackageManager
    Package manager to use ('winget', 'choco', or 'auto'). Default: 'auto'

.EXAMPLE
    Get-PackageList
    Get-PackageList -PackageManager 'winget'

.OUTPUTS
    Array of package names
#>
function Get-PackageList {
    param(
        [ValidateSet('winget', 'choco', 'auto')]
        [string]$PackageManager = 'auto'
    )

    $pm = if ($PackageManager -eq 'auto') {
        Get-PackageManager
    }
    else {
        $PackageManager
    }

    if (-not $pm) {
        Write-ErrorMsg "No package manager available."
        return @()
    }

    try {
        switch ($pm) {
            'winget' {
                $output = winget list | Select-Object -Skip 2
                return $output
            }

            'choco' {
                $output = choco list --local-only
                return $output
            }
        }
    }
    catch {
        Write-ErrorMsg "Failed to get package list: $_"
        return @()
    }

    return @()
}

# =============================================================================
# Bun Package Manager Functions
# =============================================================================

<#
.SYNOPSIS
    Check if Bun is installed.

.DESCRIPTION
    Checks if the Bun executable is available in the system PATH.

.EXAMPLE
    Test-BunInstalled

.OUTPUTS
    Boolean - $true if Bun is installed, $false otherwise
#>
function Test-BunInstalled {
    return Test-Command "bun"
}

<#
.SYNOPSIS
    Install a global Bun package.

.DESCRIPTION
    Installs a JavaScript package globally using Bun.
    Supports both regular packages (e.g., 'typescript') and scoped packages (e.g., '@qetza/replacetokens').

.PARAMETER PackageName
    The npm package name (e.g., 'typescript' or '@qetza/replacetokens')

.EXAMPLE
    Install-BunPackage -PackageName "typescript"
    Install-BunPackage -PackageName "@qetza/replacetokens"

.OUTPUTS
    Boolean - $true if successful, $false otherwise
#>
function Install-BunPackage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName
    )

    try {
        # Install package globally
        # Use --silent to reduce output noise
        $output = bun add --global $PackageName 2>&1
        
        # Check exit code
        if ($LASTEXITCODE -eq 0) {
            return $true
        }
        else {
            Write-Debug "Bun install failed with exit code $LASTEXITCODE"
            Write-Debug "Output: $output"
            return $false
        }
    }
    catch {
        Write-Debug "Exception during Bun package installation: $_"
        return $false
    }
}

<#
.SYNOPSIS
    Check if a Bun global package is installed.

.DESCRIPTION
    Checks if a JavaScript package is installed globally via Bun.

.PARAMETER PackageName
    The npm package name to check

.EXAMPLE
    Test-BunPackageInstalled -PackageName "typescript"

.OUTPUTS
    Boolean - $true if installed, $false otherwise
#>
function Test-BunPackageInstalled {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName
    )

    try {
        # List global packages
        $output = bun pm ls --global 2>&1 | Out-String
        
        # Check if package name appears in the output
        # Handle scoped packages like @qetza/replacetokens
        $escapedName = [regex]::Escape($PackageName)
        return $output -match $escapedName
    }
    catch {
        Write-Debug "Exception checking Bun package: $_"
        return $false
    }
}

<#
.SYNOPSIS
    Get list of globally installed Bun packages.

.DESCRIPTION
    Returns a list of all JavaScript packages installed globally via Bun.

.EXAMPLE
    Get-BunPackageList

.OUTPUTS
    String array - List of installed packages
#>
function Get-BunPackageList {
    try {
        $output = bun pm ls --global 2>&1
        return $output
    }
    catch {
        Write-ErrorMsg "Failed to get Bun package list: $_"
        return @()
    }
}

<#
.SYNOPSIS
    Uninstall a global Bun package.

.DESCRIPTION
    Removes a globally installed JavaScript package using Bun.

.PARAMETER PackageName
    The npm package name to uninstall

.EXAMPLE
    Uninstall-BunPackage -PackageName "typescript"

.OUTPUTS
    Boolean - $true if successful, $false otherwise
#>
function Uninstall-BunPackage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName
    )

    try {
        # Remove package globally
        $output = bun remove --global $PackageName 2>&1
        
        # Check exit code
        if ($LASTEXITCODE -eq 0) {
            return $true
        }
        else {
            Write-Debug "Bun uninstall failed with exit code $LASTEXITCODE"
            Write-Debug "Output: $output"
            return $false
        }
    }
    catch {
        Write-Debug "Exception during Bun package uninstallation: $_"
        return $false
    }
}

