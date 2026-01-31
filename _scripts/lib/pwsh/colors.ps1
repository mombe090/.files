# =============================================================================
# Colored Logging Functions for PowerShell
# =============================================================================
# This module provides colored console output for better readability.
#
# Functions:
#   - Write-Info: Informational messages (Cyan)
#   - Write-Step: Step/progress messages (Blue)
#   - Write-Success: Success messages (Green)
#   - Write-Warn: Warning messages (Yellow)
#   - Write-Error: Error messages (Red)
#   - Write-Header: Section headers (Magenta)
#   - Write-Debug: Debug messages (Gray)
# =============================================================================

<#
.SYNOPSIS
    Write an informational message.

.DESCRIPTION
    Outputs a cyan-colored informational message.

.PARAMETER Message
    The message to display.

.EXAMPLE
    Write-Info "Starting installation process..."
#>
function Write-Info {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

<#
.SYNOPSIS
    Write a step/progress message.

.DESCRIPTION
    Outputs a blue-colored step message with arrow indicator.

.PARAMETER Message
    The message to display.

.EXAMPLE
    Write-Step "Installing package: git"
#>
function Write-Step {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host "  → $Message" -ForegroundColor Blue
}

<#
.SYNOPSIS
    Write a success message.

.DESCRIPTION
    Outputs a green-colored success message with checkmark.

.PARAMETER Message
    The message to display.

.EXAMPLE
    Write-Success "Installation completed successfully!"
#>
function Write-Success {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host "[✓] $Message" -ForegroundColor Green
}

<#
.SYNOPSIS
    Write a warning message.

.DESCRIPTION
    Outputs a yellow-colored warning message.

.PARAMETER Message
    The message to display.

.EXAMPLE
    Write-Warn "Package already installed, skipping..."
#>
function Write-Warn {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host "[!] $Message" -ForegroundColor Yellow
}

<#
.SYNOPSIS
    Write an error message.

.DESCRIPTION
    Outputs a red-colored error message.

.PARAMETER Message
    The message to display.

.EXAMPLE
    Write-Error "Failed to install package"
#>
function Write-ErrorMsg {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host "[✗] $Message" -ForegroundColor Red
}

<#
.SYNOPSIS
    Write a section header.

.DESCRIPTION
    Outputs a magenta-colored section header with decorative borders.

.PARAMETER Message
    The header text to display.

.EXAMPLE
    Write-Header "Installing Development Tools"
#>
function Write-Header {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    $border = "=" * ($Message.Length + 4)
    Write-Host ""
    Write-Host $border -ForegroundColor Magenta
    Write-Host "  $Message" -ForegroundColor Magenta
    Write-Host $border -ForegroundColor Magenta
    Write-Host ""
}

<#
.SYNOPSIS
    Write a debug message.

.DESCRIPTION
    Outputs a gray-colored debug message (only if $DebugPreference allows).

.PARAMETER Message
    The debug message to display.

.EXAMPLE
    Write-DebugMsg "Variable value: $var"
#>
function Write-DebugMsg {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if ($DebugPreference -ne 'SilentlyContinue') {
        Write-Host "[DEBUG] $Message" -ForegroundColor Gray
    }
}

<#
.SYNOPSIS
    Write a prompt message and wait for user input.

.DESCRIPTION
    Displays a white-colored prompt and waits for user confirmation.

.PARAMETER Message
    The prompt message to display.

.EXAMPLE
    Write-Prompt "Press any key to continue..."
#>
function Write-Prompt {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host $Message -ForegroundColor White -NoNewline
}

# Export functions
Export-ModuleMember -Function @(
    'Write-Info',
    'Write-Step',
    'Write-Success',
    'Write-Warn',
    'Write-ErrorMsg',
    'Write-Header',
    'Write-DebugMsg',
    'Write-Prompt'
)
