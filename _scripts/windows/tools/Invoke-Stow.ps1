# =============================================================================
# PowerShell Stow - Dotfiles Symlink Manager
# =============================================================================
# A PowerShell implementation of GNU Stow for managing dotfiles on Windows.
#
# Usage:
#   cd ~/.files
#   pwsh _scripts/windows/pwsh/stow.ps1 -Stow wezterm               # Create symlinks
#   pwsh _scripts/windows/pwsh/stow.ps1 -Unstow wezterm             # Remove symlinks
#   pwsh _scripts/windows/pwsh/stow.ps1 -Restow wezterm             # Remove and recreate
#   pwsh _scripts/windows/pwsh/stow.ps1 -Stow wezterm -Target $env:USERPROFILE
#   pwsh _scripts/windows/pwsh/stow.ps1 -ListPackages               # List packages
#
#   Or via just:
#   just win_stow wezterm
#
# Package Structure (XDG-style):
#   wezterm/.config/wezterm/wezterm.lua   -> ~/.config/wezterm/wezterm.lua
#   git/.gitconfig                        -> ~/.gitconfig
#
# Package Structure (LOCALAPPDATA-style for Windows apps):
#   nvim/.local/nvim/init.lua             -> $env:LOCALAPPDATA/nvim/init.lua
#
# Packages using LOCALAPPDATA (detected by .local/ prefix):
#   - nvim: Neovim configuration
#   - Add more as needed
# =============================================================================

param(
    [Parameter(Position = 0, Mandatory = $false)]
    [string]$Stow,

    [Parameter(Mandatory = $false)]
    [string]$Unstow,

    [Parameter(Mandatory = $false)]
    [string]$Restow,

    [Parameter(Mandatory = $false)]
    [string]$Target,

    [Parameter(Mandatory = $false)]
    [string]$PackageDir,

    [Parameter(Mandatory = $false)]
    [switch]$DryRun,

    [Parameter(Mandatory = $false)]
    [switch]$ListPackages,

    [Parameter(Mandatory = $false)]
    [switch]$Force
)

# Use PowerShell's built-in Verbose preference
# Access via $VerbosePreference or use Write-Verbose

# Determine script root and dotfiles root
# Script is at: .files/_scripts/windows/pwsh/stow.ps1
# Dotfiles root (.files/) is 3 levels up
$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
$DotfilesRoot = Resolve-Path (Join-Path $ScriptRoot "..\..\..")

if (-not $PackageDir) {
    # Packages are at: .files/wezterm/, .files/nvim/, etc.
    $PackageDir = $DotfilesRoot
}

# Default target is ~/.config (like XDG on Linux)
if (-not $Target) {
    $Target = Join-Path $env:USERPROFILE ".config"
    # Ensure .config directory exists
    if (-not (Test-Path $Target)) {
        New-Item -ItemType Directory -Path $Target -Force | Out-Null
        Write-Info "Created .config directory: $Target"
    }
}

# Import libraries at: .files/_scripts/lib/pwsh/
$libPath = Join-Path $DotfilesRoot "_scripts\lib\pwsh"
. "$libPath\colors.ps1"
. "$libPath\common.ps1"

# =============================================================================
# Helper Functions
# =============================================================================

function Get-RelativePath {
    param(
        [string]$From,
        [string]$To
    )
    
    $fromUri = New-Object System.Uri($From)
    $toUri = New-Object System.Uri($To)
    $relativeUri = $fromUri.MakeRelativeUri($toUri)
    return [System.Uri]::UnescapeDataString($relativeUri.ToString()).Replace('/', '\')
}

function New-SymbolicLink {
    param(
        [string]$Link,
        [string]$Target,
        [switch]$IsDirectory
    )

    if ($DryRun) {
        if ($IsDirectory) {
            Write-Info "[DRY RUN] Would create directory symlink: $Link -> $Target"
        }
        else {
            Write-Info "[DRY RUN] Would create file symlink: $Link -> $Target"
        }
        return $true
    }

    try {
        # Ensure parent directory exists
        $parentDir = Split-Path $Link -Parent
        if (-not (Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }

        # Check if link already exists
        if (Test-Path $Link) {
            if ((Get-Item $Link).LinkType -eq "SymbolicLink") {
                $existingTarget = (Get-Item $Link).Target
                if ($existingTarget -eq $Target) {
                    Write-Verbose "Link already exists and points to correct target: $Link"
                    return $true
                }
                else {
                    if ($Force) {
                        Remove-Item $Link -Force
                        Write-Warn "  Removed existing symlink with different target: $Link"
                    }
                    else {
                        Write-Warn "  Link exists but points to different target: $Link"
                        Write-Warn "  Current: $existingTarget"
                        Write-Warn "  Expected: $Target"
                        Write-Warn "  Use -Force to override"
                        return $false
                    }
                }
            }
            else {
                Write-ErrorMsg "  Path exists but is not a symlink: $Link"
                Write-Warn "  Use -Force to backup and override, or manually remove the file"
                return $false
            }
        }

        # Create the symlink
        if ($IsDirectory) {
            New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force | Out-Null
        }
        else {
            New-Item -ItemType SymbolicLink -Path $Link -Target $Target | Out-Null
        }

        Write-Success "  Created symlink: $Link -> $Target"
        return $true
    }
    catch {
        Write-ErrorMsg "  Failed to create symlink: $_"
        return $false
    }
}

function Remove-SymbolicLink {
    param(
        [string]$Link
    )

    if ($DryRun) {
        Write-Info "[DRY RUN] Would remove symlink: $Link"
        return $true
    }

    try {
        if (Test-Path $Link) {
            $item = Get-Item $Link
            if ($item.LinkType -eq "SymbolicLink") {
                Remove-Item $Link -Force
                Write-Success "  Removed symlink: $Link"
                return $true
            }
            else {
                Write-Warn "  Path exists but is not a symlink, skipping: $Link"
                return $false
            }
        }
        else {
            Write-Verbose "Symlink does not exist, skipping: $Link"
            return $true
        }
    }
    catch {
        Write-ErrorMsg "  Failed to remove symlink: $_"
        return $false
    }
}

function Get-AvailablePackages {
    param(
        [string]$PackageDir
    )

    $packages = @()
    Get-ChildItem -Path $PackageDir -Directory | ForEach-Object {
        $pkgName = $_.Name
        # Skip _scripts and other special directories
        if ($pkgName -notmatch '^[_\.]') {
            $packages += [PSCustomObject]@{
                Name = $pkgName
                Path = $_.FullName
            }
        }
    }
    return $packages
}

function Invoke-StowPackage {
    param(
        [string]$PackageName,
        [string]$PackageDir,
        [string]$TargetDir
    )

    $packagePath = Join-Path $PackageDir $PackageName
    
    if (-not (Test-Path $packagePath)) {
        Write-ErrorMsg "Package not found: $PackageName"
        Write-Info "Package directory: $packagePath"
        return $false
    }

    Write-Header "Stowing package: $PackageName"
    Write-Info "Source: $packagePath"
    Write-Info "Target: $TargetDir"

    $success = $true
    $linkCount = 0

    # Recursively process all files and directories
    Get-ChildItem -Path $packagePath -Recurse -Force | ForEach-Object {
        $relativePath = $_.FullName.Substring($packagePath.Length + 1)
        
        # Determine the actual target directory based on path prefix
        # Check .local/ FIRST (before .config/) to ensure proper precedence
        if ($relativePath -match '^\.local\\') {
            # Strip .local\ prefix and use $env:LOCALAPPDATA (Windows-style)
            # Example: nvim/.local/nvim/init.lua -> $env:LOCALAPPDATA/nvim/init.lua
            $relativePath = $relativePath.Substring(7) # Remove ".local\"
            $actualTargetDir = $env:LOCALAPPDATA
            Write-Verbose "Using LOCALAPPDATA for: $relativePath -> $actualTargetDir\$relativePath"
        }
        elseif ($TargetDir -match '\.config$' -and $relativePath -match '^\.config\\') {
            # Strip leading .config/ if target is already ~/.config (XDG-style)
            # This prevents .config/.config/app duplication
            $relativePath = $relativePath.Substring(8) # Remove ".config\"
            $actualTargetDir = $TargetDir
            Write-Verbose "Using .config for: $relativePath -> $actualTargetDir\$relativePath"
        }
        else {
            # No special prefix, use target as-is
            $actualTargetDir = $TargetDir
        }
        
        $targetPath = Join-Path $actualTargetDir $relativePath

        if ($_.PSIsContainer) {
            # Create directory symlink or ensure directory exists
            Write-Verbose "Processing directory: $relativePath"
        }
        else {
            # Create file symlink
            Write-Step "Linking: $relativePath"
            
            if (New-SymbolicLink -Link $targetPath -Target $_.FullName) {
                $linkCount++
            }
            else {
                $success = $false
            }
        }
    }

    if ($success) {
        Write-Success "Stowed $linkCount file(s) from package: $PackageName"
    }
    else {
        Write-Warn "Stowed package with some errors: $PackageName"
    }

    return $success
}

function Invoke-UnstowPackage {
    param(
        [string]$PackageName,
        [string]$PackageDir,
        [string]$TargetDir
    )

    $packagePath = Join-Path $PackageDir $PackageName
    
    if (-not (Test-Path $packagePath)) {
        Write-ErrorMsg "Package not found: $PackageName"
        return $false
    }

    Write-Header "Unstowing package: $PackageName"
    Write-Info "Source: $packagePath"
    Write-Info "Target: $TargetDir"

    $success = $true
    $unlinkCount = 0

    # Recursively process all files (in reverse to remove files before directories)
    $items = Get-ChildItem -Path $packagePath -Recurse -Force -File
    
    foreach ($item in $items) {
        $relativePath = $item.FullName.Substring($packagePath.Length + 1)
        
        # Determine the actual target directory based on path prefix
        # Check .local/ FIRST to ensure proper precedence over .config/
        # This prevents incorrect paths like LOCALAPPDATA\.config\app
        
        # Strip leading .local/ and use $env:LOCALAPPDATA instead (Windows-style)
        # Example: nvim/.local/nvim/init.lua -> $env:LOCALAPPDATA/nvim/init.lua
        if ($relativePath -match '^\.local\\') {
            $relativePath = $relativePath.Substring(7) # Remove ".local\"
            $actualTargetDir = $env:LOCALAPPDATA
            Write-Verbose "Using LOCALAPPDATA for unstow: $relativePath -> $actualTargetDir"
        }
        # Strip leading .config/ if target is already ~/.config (XDG-style)
        # This prevents .config/.config/app duplication
        elseif ($TargetDir -match '\.config$' -and $relativePath -match '^\.config\\') {
            $relativePath = $relativePath.Substring(8) # Remove ".config\"
            $actualTargetDir = $TargetDir
            Write-Verbose "Using target .config for unstow: $relativePath -> $actualTargetDir"
        }
        else {
            $actualTargetDir = $TargetDir
        }
        
        $targetPath = Join-Path $actualTargetDir $relativePath

        Write-Step "Unlinking: $relativePath"
        
        if (Remove-SymbolicLink -Link $targetPath) {
            $unlinkCount++
        }
        else {
            $success = $false
        }
    }

    if ($success) {
        Write-Success "Unstowed $unlinkCount file(s) from package: $PackageName"
    }
    else {
        Write-Warn "Unstowed package with some errors: $PackageName"
    }

    return $success
}

# =============================================================================
# Main Logic
# =============================================================================

Write-Header "PowerShell Stow - Dotfiles Manager"

# List packages if requested
if ($ListPackages) {
    Write-Header "Available Packages"
    $packages = Get-AvailablePackages -PackageDir $PackageDir
    
    if ($packages.Count -eq 0) {
        Write-Warn "No packages found in: $PackageDir"
        exit 0
    }

    foreach ($pkg in $packages) {
        Write-Info "  $($pkg.Name)"
        Write-Verbose "Package path: $($pkg.Path)"
    }
    
    Write-Success "Found $($packages.Count) package(s)"
    exit 0
}

# Validate that at least one action is specified
if (-not $Stow -and -not $Unstow -and -not $Restow) {
    Write-ErrorMsg "No action specified. Use -Stow, -Unstow, or -Restow"
    Write-Host ""
    Write-Info "Usage examples:"
    Write-Info "  just win_stow wezterm"
    Write-Info "  just win_unstow wezterm"
    Write-Info "  just win_restow wezterm"
    Write-Info "  Or directly: pwsh _scripts/windows/pwsh/stow.ps1 -Stow wezterm"
    exit 1
}

# Perform restow (unstow then stow)
if ($Restow) {
    Invoke-UnstowPackage -PackageName $Restow -PackageDir $PackageDir -TargetDir $Target
    Invoke-StowPackage -PackageName $Restow -PackageDir $PackageDir -TargetDir $Target
    exit 0
}

# Perform stow
if ($Stow) {
    $result = Invoke-StowPackage -PackageName $Stow -PackageDir $PackageDir -TargetDir $Target
    exit $(if ($result) { 0 } else { 1 })
}

# Perform unstow
if ($Unstow) {
    $result = Invoke-UnstowPackage -PackageName $Unstow -PackageDir $PackageDir -TargetDir $Target
    exit $(if ($result) { 0 } else { 1 })
}
