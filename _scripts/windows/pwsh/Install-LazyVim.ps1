#Requires -Version 5.1
<#
.SYNOPSIS
    Install LazyVim (Neovim distribution) on Windows.

.DESCRIPTION
    This script installs LazyVim by:
    1. Backing up existing Neovim configuration
    2. Cloning the LazyVim starter template
    3. Removing .git folder for customization
    4. Installing required dependencies if needed

.PARAMETER SkipBackup
    Skip backing up existing Neovim configuration

.PARAMETER Force
    Force installation even if LazyVim is already installed

.EXAMPLE
    .\Install-LazyVim.ps1
    Install LazyVim with backup of existing configuration

.EXAMPLE
    .\Install-LazyVim.ps1 -SkipBackup
    Install LazyVim without backing up existing configuration

.EXAMPLE
    .\Install-LazyVim.ps1 -Force
    Force reinstall LazyVim even if already installed

.NOTES
    Author: mombe090
    Requires: Git, Neovim
    Optional: ripgrep, fd, lazygit for full functionality
#>

[CmdletBinding()]
param(
    [switch]$SkipBackup,
    [switch]$Force
)

# Import helper functions
$scriptRoot = Split-Path -Parent $PSScriptRoot
$libPath = Join-Path $scriptRoot "lib" "pwsh"
. (Join-Path $libPath "colors.ps1")
. (Join-Path $libPath "common.ps1")

# Configuration
$nvimConfigPath = Join-Path $env:LOCALAPPDATA "nvim"
$nvimDataPath = Join-Path $env:LOCALAPPDATA "nvim-data"
$nvimBackupPath = Join-Path $env:LOCALAPPDATA "nvim.bak"
$nvimDataBackupPath = Join-Path $env:LOCALAPPDATA "nvim-data.bak"
$lazyVimRepo = "https://github.com/LazyVim/starter"

# Check if Neovim is installed
function Test-NeovimInstalled {
    $nvim = Get-Command nvim -ErrorAction SilentlyContinue
    return $null -ne $nvim
}

# Check if Git is installed
function Test-GitInstalled {
    $git = Get-Command git -ErrorAction SilentlyContinue
    return $null -ne $git
}

# Backup existing Neovim configuration
function Backup-NeovimConfig {
    Write-Header "Backing up existing Neovim configuration"

    if (Test-Path $nvimConfigPath) {
        if (Test-Path $nvimBackupPath) {
            Write-Warning "Backup already exists at: $nvimBackupPath"
            Write-Info "Removing old backup..."
            Remove-Item $nvimBackupPath -Recurse -Force
        }
        
        Write-Info "Backing up config: $nvimConfigPath -> $nvimBackupPath"
        Move-Item $nvimConfigPath $nvimBackupPath -Force
        Write-Success "Config backed up successfully"
    } else {
        Write-Info "No existing Neovim config found at: $nvimConfigPath"
    }

    if (Test-Path $nvimDataPath) {
        if (Test-Path $nvimDataBackupPath) {
            Write-Warning "Data backup already exists at: $nvimDataBackupPath"
            Write-Info "Removing old data backup..."
            Remove-Item $nvimDataBackupPath -Recurse -Force
        }
        
        Write-Info "Backing up data: $nvimDataPath -> $nvimDataBackupPath"
        Move-Item $nvimDataPath $nvimDataBackupPath -Force
        Write-Success "Data backed up successfully"
    } else {
        Write-Info "No existing Neovim data found at: $nvimDataPath"
    }
}

# Clone LazyVim starter
function Install-LazyVimStarter {
    Write-Header "Installing LazyVim starter template"

    Write-Info "Cloning LazyVim starter from GitHub..."
    Write-Info "Repository: $lazyVimRepo"
    Write-Info "Destination: $nvimConfigPath"

    try {
        $gitOutput = git clone $lazyVimRepo $nvimConfigPath 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Git clone failed: $gitOutput"
        }
        Write-Success "LazyVim starter cloned successfully"
    } catch {
        Write-Error "Failed to clone LazyVim starter: $_"
        return $false
    }

    # Remove .git folder to allow customization
    $gitFolder = Join-Path $nvimConfigPath ".git"
    if (Test-Path $gitFolder) {
        Write-Info "Removing .git folder to allow customization..."
        Remove-Item $gitFolder -Recurse -Force
        Write-Success ".git folder removed"
    }

    return $true
}

# Check dependencies
function Test-Dependencies {
    Write-Header "Checking dependencies"

    $dependencies = @{
        "nvim" = "Neovim"
        "git" = "Git"
        "rg" = "ripgrep (optional but recommended)"
        "fd" = "fd (optional but recommended)"
        "lazygit" = "lazygit (optional but recommended)"
    }

    $missingRequired = @()
    $missingOptional = @()

    foreach ($cmd in $dependencies.Keys) {
        $installed = Get-Command $cmd -ErrorAction SilentlyContinue
        if ($null -eq $installed) {
            $desc = $dependencies[$cmd]
            if ($desc -like "*optional*") {
                Write-Warning "Missing optional: $desc"
                $missingOptional += $cmd
            } else {
                Write-Error "Missing required: $desc"
                $missingRequired += $cmd
            }
        } else {
            Write-Success "Found: $($dependencies[$cmd])"
        }
    }

    if ($missingRequired.Count -gt 0) {
        Write-Error ""
        Write-Error "Missing required dependencies: $($missingRequired -join ', ')"
        Write-Info "Install them using:"
        Write-Info "  choco install neovim git"
        return $false
    }

    if ($missingOptional.Count -gt 0) {
        Write-Warning ""
        Write-Warning "Missing optional dependencies: $($missingOptional -join ', ')"
        Write-Info "For the best experience, install them using:"
        Write-Info "  choco install ripgrep fd lazygit"
        Write-Info ""
    }

    return $true
}

# Main installation process
function Install-LazyVim {
    Write-Header "LazyVim Installation Script"
    Write-Info "Installing LazyVim Neovim distribution..."
    Write-Info ""

    # Check dependencies
    if (-not (Test-Dependencies)) {
        Write-Error "Please install required dependencies first"
        exit 1
    }

    # Check if LazyVim is already installed
    $lazyVimLua = Join-Path $nvimConfigPath "lua" "config" "lazy.lua"
    if ((Test-Path $nvimConfigPath) -and (Test-Path $lazyVimLua) -and -not $Force) {
        Write-Warning "LazyVim appears to be already installed at: $nvimConfigPath"
        Write-Info "Use -Force to reinstall"
        
        $response = Read-Host "Do you want to reinstall? (y/N)"
        if ($response -notmatch "^[Yy]") {
            Write-Info "Installation cancelled"
            exit 0
        }
        $Force = $true
    }

    # Backup existing configuration
    if (-not $SkipBackup) {
        Backup-NeovimConfig
    } else {
        Write-Info "Skipping backup (as requested)"
        if (Test-Path $nvimConfigPath) {
            Write-Warning "Removing existing config without backup..."
            Remove-Item $nvimConfigPath -Recurse -Force
        }
    }

    # Install LazyVim starter
    if (-not (Install-LazyVimStarter)) {
        Write-Error "LazyVim installation failed"
        exit 1
    }

    # Success message
    Write-Success ""
    Write-Success "╔════════════════════════════════════════════════════════════════════╗"
    Write-Success "║           LazyVim installed successfully! 🎉                       ║"
    Write-Success "╚════════════════════════════════════════════════════════════════════╝"
    Write-Info ""
    Write-Info "Next steps:"
    Write-Info "  1. Start Neovim: nvim"
    Write-Info "  2. LazyVim will automatically install plugins on first launch"
    Write-Info "  3. Run health check: :LazyHealth"
    Write-Info "  4. Customize your config in: $nvimConfigPath"
    Write-Info ""
    Write-Info "Configuration location:"
    Write-Info "  Config: $nvimConfigPath"
    if (-not $SkipBackup -and (Test-Path $nvimBackupPath)) {
        Write-Info "  Backup: $nvimBackupPath"
    }
    Write-Info ""
    Write-Info "Recommended plugins to explore:"
    Write-Info "  - Press <leader>l to open Lazy plugin manager"
    Write-Info "  - Press <leader>e to open file explorer"
    Write-Info "  - Press <leader>ff to find files"
    Write-Info "  - Press <leader>sg to search in files (grep)"
    Write-Info ""
    Write-Info "Documentation: https://www.lazyvim.org/"
    Write-Info ""
}

# Run installation
Install-LazyVim
