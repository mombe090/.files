# =============================================================================
# System Detection Functions for Windows
# =============================================================================
# This module provides system detection and information gathering functions.
#
# Functions:
#   - Get-WindowsVersion: Get Windows version information
#   - Test-IsAdmin: Check if running with admin privileges
#   - Get-Architecture: Get system architecture (x64, x86, ARM64)
#   - Get-PowerShellVersion: Get PowerShell version
#   - Test-IsWindowsTerminal: Check if running in Windows Terminal
#   - Get-SystemInfo: Get comprehensive system information
# =============================================================================

<#
.SYNOPSIS
    Get Windows version information.

.DESCRIPTION
    Returns detailed Windows version and build information.

.EXAMPLE
    Get-WindowsVersion

.OUTPUTS
    PSCustomObject with version details
#>
function Get-WindowsVersion {
    $os = Get-CimInstance Win32_OperatingSystem
    $version = [System.Environment]::OSVersion.Version

    return [PSCustomObject]@{
        ProductName  = $os.Caption
        Version      = $version.ToString()
        Build        = $os.BuildNumber
        Major        = $version.Major
        Minor        = $version.Minor
        IsWindows10  = $version.Major -eq 10 -and $os.BuildNumber -lt 22000
        IsWindows11  = $version.Major -eq 10 -and $os.BuildNumber -ge 22000
        IsServer     = $os.ProductType -ne 1
    }
}

<#
.SYNOPSIS
    Check if running with administrator privileges.

.DESCRIPTION
    Tests whether the current PowerShell session has admin rights.

.EXAMPLE
    Test-IsAdmin

.OUTPUTS
    Boolean - $true if admin, $false otherwise
#>
function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

<#
.SYNOPSIS
    Get system architecture.

.DESCRIPTION
    Returns the processor architecture (x64, x86, ARM64).

.EXAMPLE
    Get-Architecture

.OUTPUTS
    String - Architecture name (x64, x86, ARM64)
#>
function Get-Architecture {
    $arch = $env:PROCESSOR_ARCHITECTURE

    switch ($arch) {
        "AMD64" { return "x64" }
        "x86" { return "x86" }
        "ARM64" { return "ARM64" }
        default { return $arch }
    }
}

<#
.SYNOPSIS
    Get PowerShell version information.

.DESCRIPTION
    Returns PowerShell version details.

.EXAMPLE
    Get-PowerShellVersion

.OUTPUTS
    PSCustomObject with PowerShell version details
#>
function Get-PowerShellVersion {
    return [PSCustomObject]@{
        Version      = $PSVersionTable.PSVersion.ToString()
        Major        = $PSVersionTable.PSVersion.Major
        Minor        = $PSVersionTable.PSVersion.Minor
        Edition      = $PSVersionTable.PSEdition
        IsCore       = $PSVersionTable.PSEdition -eq "Core"
        IsDesktop    = $PSVersionTable.PSEdition -eq "Desktop"
    }
}

<#
.SYNOPSIS
    Check if running in Windows Terminal.

.DESCRIPTION
    Tests whether the current session is running in Windows Terminal.

.EXAMPLE
    Test-IsWindowsTerminal

.OUTPUTS
    Boolean - $true if Windows Terminal, $false otherwise
#>
function Test-IsWindowsTerminal {
    return $null -ne $env:WT_SESSION
}

<#
.SYNOPSIS
    Get comprehensive system information.

.DESCRIPTION
    Collects and returns detailed system information.

.EXAMPLE
    Get-SystemInfo

.OUTPUTS
    PSCustomObject with comprehensive system details
#>
function Get-SystemInfo {
    $os = Get-CimInstance Win32_OperatingSystem
    $cs = Get-CimInstance Win32_ComputerSystem
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1

    return [PSCustomObject]@{
        ComputerName     = $cs.Name
        UserName         = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        OS               = Get-WindowsVersion
        Architecture     = Get-Architecture
        PowerShell       = Get-PowerShellVersion
        IsAdmin          = Test-IsAdmin
        IsWindowsTerminal = Test-IsWindowsTerminal
        TotalMemoryGB    = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)
        FreeMemoryGB     = [math]::Round($os.FreePhysicalMemory / 1MB / 1024, 2)
        ProcessorName    = $cpu.Name
        ProcessorCores   = $cpu.NumberOfCores
        ProcessorThreads = $cpu.NumberOfLogicalProcessors
    }
}

<#
.SYNOPSIS
    Require administrator privileges.

.DESCRIPTION
    Checks if running as admin and exits with error message if not.

.PARAMETER Message
    Custom error message to display if not admin.

.EXAMPLE
    Assert-IsAdmin
    Assert-IsAdmin -Message "This operation requires administrator privileges"
#>
function Assert-IsAdmin {
    param(
        [string]$Message = "This script requires administrator privileges. Please run PowerShell as Administrator."
    )

    if (-not (Test-IsAdmin)) {
        Write-Host "[ERROR] $Message" -ForegroundColor Red
        exit 1
    }
}

<#
.SYNOPSIS
    Get user's home directory.

.DESCRIPTION
    Returns the current user's home directory path.

.EXAMPLE
    Get-HomeDirectory

.OUTPUTS
    String - Path to user's home directory
#>
function Get-HomeDirectory {
    return $env:USERPROFILE
}

<#
.SYNOPSIS
    Get local application data directory.

.DESCRIPTION
    Returns the path to local application data folder.

.EXAMPLE
    Get-LocalAppData

.OUTPUTS
    String - Path to LocalAppData folder
#>
function Get-LocalAppData {
    return $env:LOCALAPPDATA
}

<#
.SYNOPSIS
    Get roaming application data directory.

.DESCRIPTION
    Returns the path to roaming application data folder.

.EXAMPLE
    Get-AppData

.OUTPUTS
    String - Path to AppData\Roaming folder
#>
function Get-AppData {
    return $env:APPDATA
}

