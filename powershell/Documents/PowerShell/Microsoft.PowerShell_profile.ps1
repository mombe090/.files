# PowerShell Profile
# Location: $PROFILE (Documents\PowerShell\Microsoft.PowerShell_profile.ps1)

# =============================================================================
# Starship Prompt
# =============================================================================

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
    
    # Set Starship config location
    $env:STARSHIP_CONFIG = "$env:USERPROFILE\.config\starship.toml"
}

# =============================================================================
# Environment Variables
# =============================================================================

# XDG Base Directory specification (cross-platform compatibility)
$env:XDG_CONFIG_HOME = "$env:USERPROFILE\.config"
$env:XDG_DATA_HOME = "$env:USERPROFILE\.local\share"
$env:XDG_CACHE_HOME = "$env:USERPROFILE\.cache"
$env:XDG_STATE_HOME = "$env:USERPROFILE\.local\state"

# Editor
$env:EDITOR = "nvim"
$env:VISUAL = "nvim"

# =============================================================================
# PSReadLine Configuration
# =============================================================================

# Import PSReadLine if available
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    
    # Vi mode
    Set-PSReadLineOption -EditMode Vi
    
    # History search
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    
    # Tab completion
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    
    # Colors
    Set-PSReadLineOption -Colors @{
        Command   = 'Cyan'
        Parameter = 'Green'
        String    = 'Yellow'
        Comment   = 'DarkGray'
    }
}

# =============================================================================
# Aliases
# =============================================================================

# File operations
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name l -Value Get-ChildItem
Set-Alias -Name c -Value Clear-Host

# Editor
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias -Name v -Value nvim
}

# Git aliases (Oh My Zsh style)
$gitAliasesPath = Join-Path (Split-Path $PROFILE -Parent) "git-aliases.ps1"
if (Test-Path $gitAliasesPath) {
    . $gitAliasesPath
}

# Kubernetes aliases (if kubectl is installed)
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    Set-Alias -Name k -Value kubectl
    
    function kg { param($resource) kubectl get $resource }
    function kd { param($resource, $name) kubectl describe $resource $name }
    function kl { param($pod) kubectl logs -f $pod }
    function kgpo { kubectl get pods }
    function kgd { kubectl get deployments }
    function ke { param($pod) kubectl exec -it $pod -- sh }
}

# =============================================================================
# Utilities
# =============================================================================

# Enhanced cd with ls
function cx {
    param([string]$Path)
    Set-Location $Path
    Get-ChildItem
}

# Update PATH
function Add-ToPath {
    param([string]$Path)
    if (Test-Path $Path) {
        $env:Path = "$Path;$env:Path"
    }
}

# Add common paths
Add-ToPath "$env:USERPROFILE\.local\bin"
Add-ToPath "$env:USERPROFILE\.bun\bin"
Add-ToPath "$env:USERPROFILE\.cargo\bin"

# =============================================================================
# Welcome Message
# =============================================================================

# Clear host and show minimal info
Clear-Host
Write-Host "PowerShell $($PSVersionTable.PSVersion) with Starship" -ForegroundColor Cyan

# =============================================================================
# Load Machine-Specific Profile (if exists)
# =============================================================================

# Load profile.ps1 from user profile directory for machine-specific customizations
$machineProfilePath = Join-Path $env:USERPROFILE "profile.ps1"
if (Test-Path $machineProfilePath) {
    Write-Host "Loading machine-specific profile..." -ForegroundColor Yellow
    . $machineProfilePath
    Write-Host "Machine-specific profile loaded" -ForegroundColor Green
}
