# =============================================================================
# Colored Logging Functions for PowerShell (Catppuccin Mocha Theme)
# =============================================================================
# This module provides colored console output using Catppuccin Mocha colors.
#
# Functions:
#   - Write-Info: Informational messages (Sky Blue)
#   - Write-Step: Step/progress messages (Lavender)
#   - Write-Success: Success messages (Green)
#   - Write-Warn: Warning messages (Yellow/Peach)
#   - Write-ErrorMsg: Error messages (Red)
#   - Write-Header: Section headers (Mauve)
#   - Write-DebugMsg: Debug messages (Overlay0)
#
# Catppuccin Mocha Colors:
#   https://github.com/catppuccin/catppuccin
# =============================================================================

# Check if terminal supports RGB colors
$SupportsRGB = $host.UI.SupportsVirtualTerminal -and ($PSVersionTable.PSVersion.Major -ge 6)

# Catppuccin Mocha Color Palette
$Script:CatppuccinMocha = @{
    Rosewater = if ($SupportsRGB) { "`e[38;2;245;224;220m" } else { "White" }
    Flamingo  = if ($SupportsRGB) { "`e[38;2;242;205;205m" } else { "White" }
    Pink      = if ($SupportsRGB) { "`e[38;2;245;194;231m" } else { "Magenta" }
    Mauve     = if ($SupportsRGB) { "`e[38;2;203;166;247m" } else { "Magenta" }
    Red       = if ($SupportsRGB) { "`e[38;2;243;139;168m" } else { "Red" }
    Maroon    = if ($SupportsRGB) { "`e[38;2;235;160;172m" } else { "Red" }
    Peach     = if ($SupportsRGB) { "`e[38;2;250;179;135m" } else { "Yellow" }
    Yellow    = if ($SupportsRGB) { "`e[38;2;249;226;175m" } else { "Yellow" }
    Green     = if ($SupportsRGB) { "`e[38;2;166;227;161m" } else { "Green" }
    Teal      = if ($SupportsRGB) { "`e[38;2;148;226;213m" } else { "Cyan" }
    Sky       = if ($SupportsRGB) { "`e[38;2;137;220;235m" } else { "Cyan" }
    Sapphire  = if ($SupportsRGB) { "`e[38;2;116;199;236m" } else { "Blue" }
    Blue      = if ($SupportsRGB) { "`e[38;2;137;180;250m" } else { "Blue" }
    Lavender  = if ($SupportsRGB) { "`e[38;2;180;190;254m" } else { "Blue" }
    Text      = if ($SupportsRGB) { "`e[38;2;205;214;244m" } else { "White" }
    Subtext1  = if ($SupportsRGB) { "`e[38;2;186;194;222m" } else { "Gray" }
    Subtext0  = if ($SupportsRGB) { "`e[38;2;166;173;200m" } else { "Gray" }
    Overlay2  = if ($SupportsRGB) { "`e[38;2;147;153;178m" } else { "Gray" }
    Overlay1  = if ($SupportsRGB) { "`e[38;2;127;132;156m" } else { "Gray" }
    Overlay0  = if ($SupportsRGB) { "`e[38;2;108;112;134m" } else { "DarkGray" }
    Surface2  = if ($SupportsRGB) { "`e[38;2;88;91;112m" } else { "DarkGray" }
    Surface1  = if ($SupportsRGB) { "`e[38;2;69;71;90m" } else { "DarkGray" }
    Surface0  = if ($SupportsRGB) { "`e[38;2;49;50;68m" } else { "Black" }
    Base      = if ($SupportsRGB) { "`e[38;2;30;30;46m" } else { "Black" }
    Mantle    = if ($SupportsRGB) { "`e[38;2;24;24;37m" } else { "Black" }
    Crust     = if ($SupportsRGB) { "`e[38;2;17;17;27m" } else { "Black" }
    Reset     = if ($SupportsRGB) { "`e[0m" } else { "" }
}

# Helper function to write colored text with RGB support
function Write-ColoredText {
    param(
        [string]$Text,
        [string]$Color
    )

    if ($SupportsRGB) {
        Write-Host "$Color$Text$($Script:CatppuccinMocha.Reset)" -NoNewline
    } else {
        Write-Host $Text -ForegroundColor $Color -NoNewline
    }
    Write-Host ""  # Newline
}

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

    Write-ColoredText "[INFO] $Message" -Color $Script:CatppuccinMocha.Sky
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

    Write-ColoredText "  → $Message" -Color $Script:CatppuccinMocha.Lavender
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

    Write-ColoredText "[✓] $Message" -Color $Script:CatppuccinMocha.Green
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

    Write-ColoredText "[!] $Message" -Color $Script:CatppuccinMocha.Peach
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

    Write-ColoredText "[✗] $Message" -Color $Script:CatppuccinMocha.Red
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
    Write-ColoredText $border -Color $Script:CatppuccinMocha.Mauve
    Write-ColoredText "  $Message" -Color $Script:CatppuccinMocha.Mauve
    Write-ColoredText $border -Color $Script:CatppuccinMocha.Mauve
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
        Write-ColoredText "[DEBUG] $Message" -Color $Script:CatppuccinMocha.Overlay0
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

    if ($SupportsRGB) {
        Write-Host "$($Script:CatppuccinMocha.Text)$Message$($Script:CatppuccinMocha.Reset)" -NoNewline
    } else {
        Write-Host $Message -ForegroundColor White -NoNewline
    }
}

