#Requires -Version 7.0

<#
.SYNOPSIS
    Automated test script for stow.ps1 LOCALAPPDATA support
.DESCRIPTION
    Tests that .local/ prefixed files are correctly routed to $env:LOCALAPPDATA
    and that paths don't incorrectly include .config in LOCALAPPDATA paths.
.EXAMPLE
    .\Test-StowLocalAppData.ps1
#>

$ErrorActionPreference = 'Stop'

# Import helper functions
. "$PSScriptRoot\..\lib\colors.ps1"

Write-Header "Testing stow.ps1 LOCALAPPDATA Support"
Write-Host ""

# Test 1: Environment check
Write-Header "Test 1: Environment Check"
Write-Info "PowerShell version: $($PSVersionTable.PSVersion)"
Write-Info "LOCALAPPDATA: $env:LOCALAPPDATA"
Write-Info "Current directory: $PWD"
Write-Host ""

# Navigate to repo root if needed
$repoRoot = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent
if ($PWD.Path -ne $repoRoot) {
    Write-Info "Changing to repo root: $repoRoot"
    Set-Location $repoRoot
}

# Test 2: Dry run
Write-Header "Test 2: Dry Run with Verbose"
Write-Info "Running: .\stow.ps1 -Stow nvim -DryRun -Verbose"
Write-Host ""
.\stow.ps1 -Stow nvim -DryRun -Verbose
Write-Host ""

# Test 3: Actual stow
Write-Header "Test 3: Stowing nvim Package"
Write-Info "Running: .\stow.ps1 -Stow nvim -Verbose"
Write-Host ""
.\stow.ps1 -Stow nvim -Verbose
Write-Host ""

# Test 4: Verify symlinks
Write-Header "Test 4: Verifying Symlinks"
$initLua = Get-Item $env:LOCALAPPDATA\nvim\init.lua -ErrorAction SilentlyContinue
if ($initLua -and $initLua.LinkType -eq 'SymbolicLink') {
    Write-Success "init.lua is a valid symlink"
    Write-Info "  Path: $($initLua.FullName)"
    Write-Info "  Target: $($initLua.Target)"
    Write-Host ""
    
    # Check path correctness
    if ($initLua.FullName -notmatch '\.config') {
        Write-Success "Path is correct (no .config in LOCALAPPDATA path)"
    } else {
        Write-ErrorMsg "Path contains .config (BUG DETECTED!)"
        Write-ErrorMsg "  Actual path: $($initLua.FullName)"
        Write-ErrorMsg "  Expected: $env:LOCALAPPDATA\nvim\init.lua"
        Write-ErrorMsg "  Got: Path with .config in it"
        exit 1
    }
} else {
    Write-ErrorMsg "init.lua not found or not a symlink"
    exit 1
}
Write-Host ""

# Test 5: List all symlinks
Write-Header "Test 5: All Symlinks in nvim Directory"
$symlinks = Get-ChildItem $env:LOCALAPPDATA\nvim -Recurse -Force -ErrorAction SilentlyContinue | 
    Where-Object { $_.LinkType -eq 'SymbolicLink' }

if ($symlinks) {
    Write-Success "Found $($symlinks.Count) symlink(s)"
    
    # Check each symlink for .config in path
    $badPaths = $symlinks | Where-Object { $_.FullName -match '\.config' }
    if ($badPaths) {
        Write-ErrorMsg "Found $($badPaths.Count) symlink(s) with .config in path (BUG!):"
        foreach ($bad in $badPaths) {
            Write-ErrorMsg "  $($bad.FullName)"
        }
        exit 1
    } else {
        Write-Success "All symlinks have correct paths (no .config in LOCALAPPDATA)"
    }
    
    # Show first 5 symlinks as sample
    Write-Host ""
    Write-Info "Sample symlinks (first 5):"
    $symlinks | Select-Object -First 5 | ForEach-Object {
        $relativePath = $_.FullName.Substring($env:LOCALAPPDATA.Length)
        Write-Info "  $relativePath -> $($_.Target)"
    }
} else {
    Write-Warn "No symlinks found in $env:LOCALAPPDATA\nvim"
}
Write-Host ""

# Test 6: Unstow
Write-Header "Test 6: Unstowing nvim Package"
Write-Info "Running: .\stow.ps1 -Unstow nvim -Verbose"
Write-Host ""
.\stow.ps1 -Unstow nvim -Verbose
Write-Host ""

# Test 7: Verify cleanup
Write-Header "Test 7: Verifying Cleanup"
if (Test-Path $env:LOCALAPPDATA\nvim) {
    $remaining = Get-ChildItem $env:LOCALAPPDATA\nvim -Force -ErrorAction SilentlyContinue
    if ($null -eq $remaining -or $remaining.Count -eq 0) {
        Write-Success "nvim directory is empty (will be cleaned up by Windows)"
    } else {
        Write-Warn "$($remaining.Count) file(s)/folder(s) remain:"
        $remaining | ForEach-Object {
            Write-Info "  $($_.Name)"
        }
    }
} else {
    Write-Success "nvim directory removed completely"
}

Write-Host ""
Write-Header "Testing Complete!"
Write-Success "All tests passed successfully"
Write-Host ""
Write-Info "The .local/ prefix precedence fix is working correctly!"
