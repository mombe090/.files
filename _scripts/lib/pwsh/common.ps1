# =============================================================================
# Common PowerShell Utilities
# =============================================================================
# This module provides common utility functions for PowerShell scripts.
#
# Functions:
#   - Test-Command: Check if a command exists
#   - Invoke-WithRetry: Run a command with retry logic
#   - New-Backup: Create a backup of a file or directory
#   - New-SafeSymlink: Create a symlink with safety checks
#   - Get-LatestVersion: Get the latest version of a tool
#   - Test-PathSafe: Test if a path exists safely
#   - New-DirectorySafe: Create a directory if it doesn't exist
# =============================================================================

<#
.SYNOPSIS
    Check if a command exists in the current session.

.DESCRIPTION
    Tests whether a command (cmdlet, function, alias, or executable) is available.

.PARAMETER Command
    The name of the command to check.

.EXAMPLE
    Test-Command "git"
    Test-Command "winget"

.OUTPUTS
    Boolean - $true if command exists, $false otherwise
#>
function Test-Command {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    try {
        if (Get-Command $Command -ErrorAction Stop) {
            return $true
        }
    }
    catch {
        return $false
    }
    return $false
}

<#
.SYNOPSIS
    Run a script block with retry logic.

.DESCRIPTION
    Executes a script block and retries on failure with exponential backoff.

.PARAMETER ScriptBlock
    The script block to execute.

.PARAMETER MaxRetries
    Maximum number of retry attempts (default: 3).

.PARAMETER DelaySeconds
    Initial delay in seconds between retries (default: 2).

.EXAMPLE
    Invoke-WithRetry -ScriptBlock { winget install git } -MaxRetries 3

.OUTPUTS
    The result of the script block execution
#>
function Invoke-WithRetry {
    param(
        [Parameter(Mandatory = $true)]
        [ScriptBlock]$ScriptBlock,

        [int]$MaxRetries = 3,

        [int]$DelaySeconds = 2
    )

    $attempt = 0
    $delay = $DelaySeconds

    while ($attempt -lt $MaxRetries) {
        try {
            $attempt++
            $result = & $ScriptBlock
            return $result
        }
        catch {
            if ($attempt -ge $MaxRetries) {
                throw "Command failed after $MaxRetries attempts: $_"
            }

            Write-Warning "Attempt $attempt failed. Retrying in $delay seconds..."
            Start-Sleep -Seconds $delay

            # Exponential backoff
            $delay = $delay * 2
        }
    }
}

<#
.SYNOPSIS
    Create a backup of a file or directory.

.DESCRIPTION
    Creates a backup copy with timestamp suffix (.bak.YYYYMMDD_HHMMSS).

.PARAMETER Path
    The path to backup.

.PARAMETER BackupDir
    Optional custom backup directory (default: same directory as source).

.EXAMPLE
    New-Backup -Path "C:\config\app.config"
    New-Backup -Path "C:\data" -BackupDir "C:\backups"

.OUTPUTS
    String - Path to the backup file/directory
#>
function New-Backup {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [string]$BackupDir = ""
    )

    if (-not (Test-Path $Path)) {
        throw "Path does not exist: $Path"
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $item = Get-Item $Path
    $backupName = "$($item.Name).bak.$timestamp"

    if ($BackupDir) {
        if (-not (Test-Path $BackupDir)) {
            New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
        }
        $backupPath = Join-Path $BackupDir $backupName
    }
    else {
        $backupPath = Join-Path $item.DirectoryName $backupName
    }

    Copy-Item -Path $Path -Destination $backupPath -Recurse -Force
    return $backupPath
}

<#
.SYNOPSIS
    Create a symbolic link with safety checks.

.DESCRIPTION
    Creates a symlink after verifying source exists and handling existing targets.

.PARAMETER Source
    The source file or directory to link to.

.PARAMETER Target
    The target location for the symlink.

.PARAMETER Force
    If specified, removes existing target before creating symlink.

.EXAMPLE
    New-SafeSymlink -Source "C:\dotfiles\vimrc" -Target "$env:USERPROFILE\.vimrc"
    New-SafeSymlink -Source "C:\dotfiles\config" -Target "$env:APPDATA\config" -Force

.OUTPUTS
    Boolean - $true if successful, $false otherwise
#>
function New-SafeSymlink {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [string]$Target,

        [switch]$Force
    )

    # Verify source exists
    if (-not (Test-Path $Source)) {
        Write-Error "Source does not exist: $Source"
        return $false
    }

    # Handle existing target
    if (Test-Path $Target) {
        if ($Force) {
            Remove-Item -Path $Target -Recurse -Force
        }
        else {
            Write-Warning "Target already exists: $Target (use -Force to overwrite)"
            return $false
        }
    }

    # Create parent directory if needed
    $targetParent = Split-Path -Parent $Target
    if ($targetParent -and -not (Test-Path $targetParent)) {
        New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
    }

    # Determine item type
    $isDirectory = (Get-Item $Source) -is [System.IO.DirectoryInfo]

    try {
        if ($isDirectory) {
            New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force | Out-Null
        }
        else {
            New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force | Out-Null
        }
        return $true
    }
    catch {
        Write-Error "Failed to create symlink: $_"
        return $false
    }
}

<#
.SYNOPSIS
    Test if a path exists safely.

.DESCRIPTION
    Tests path existence without throwing errors.

.PARAMETER Path
    The path to test.

.EXAMPLE
    Test-PathSafe "C:\temp\file.txt"

.OUTPUTS
    Boolean - $true if path exists, $false otherwise
#>
function Test-PathSafe {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        return Test-Path $Path -ErrorAction Stop
    }
    catch {
        return $false
    }
}

<#
.SYNOPSIS
    Create a directory if it doesn't exist.

.DESCRIPTION
    Safely creates a directory and all parent directories if needed.

.PARAMETER Path
    The directory path to create.

.EXAMPLE
    New-DirectorySafe "C:\temp\deep\nested\folder"

.OUTPUTS
    DirectoryInfo - The created or existing directory
#>
function New-DirectorySafe {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        return New-Item -ItemType Directory -Path $Path -Force
    }
    return Get-Item $Path
}

