# Testing Guide: stow.ps1 LOCALAPPDATA Support

This guide helps you verify that the `.local/` prefix precedence fix works correctly on Windows.

## Prerequisites

1. **Windows machine** with PowerShell 7+
2. **Git for Windows** installed
3. **Developer Mode enabled** OR **Admin privileges**
4. **Clean test environment** (no existing nvim config in LOCALAPPDATA)

## Quick Test Commands

### 1. Verify Environment

```powershell
# Check PowerShell version (should be 7+)
$PSVersionTable.PSVersion

# Check LOCALAPPDATA path
$env:LOCALAPPDATA
# Expected: C:\Users\<username>\AppData\Local

# Check if nvim config already exists
Test-Path $env:LOCALAPPDATA\nvim
# Expected: False (for clean test)

# If True, backup existing config
if (Test-Path $env:LOCALAPPDATA\nvim) {
    Move-Item $env:LOCALAPPDATA\nvim $env:LOCALAPPDATA\nvim.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')
}
```

### 2. Test Dry Run (Most Important!)

```powershell
cd C:\Users\<username>\.files

# Run dry run with verbose output
.\stow.ps1 -Stow nvim -DryRun -Verbose
```

**What to look for in output:**

✅ **CORRECT** output should show:
```
Using LOCALAPPDATA for: nvim\init.lua -> C:\Users\<username>\AppData\Local\nvim\init.lua
Using LOCALAPPDATA for: nvim\lua\config\autocmds.lua -> C:\Users\<username>\AppData\Local\nvim\lua\config\autocmds.lua
```

❌ **WRONG** output would show (this was the bug):
```
Using .config for: nvim\init.lua -> C:\Users\<username>\AppData\Local\.config\nvim\init.lua
```

### 3. Test Actual Stowing

```powershell
# Stow nvim package with verbose output
.\stow.ps1 -Stow nvim -Verbose
```

**Expected output:**
```
===== PowerShell Stow - Dotfiles Manager =====

===== Stowing package: nvim =====
Source: C:\Users\<username>\.files\nvim
Target: C:\Users\<username>\.config

--- Linking: nvim\init.lua
✓ Created symlink: C:\Users\<username>\AppData\Local\nvim\init.lua -> ...

✓ Stowed 42 file(s) from package: nvim
```

### 4. Verify Symlinks

```powershell
# Check if init.lua exists and is a symlink
$nvimInit = Get-Item $env:LOCALAPPDATA\nvim\init.lua -ErrorAction SilentlyContinue

if ($nvimInit) {
    Write-Host "File exists: $($nvimInit.FullName)" -ForegroundColor Green
    Write-Host "Link type: $($nvimInit.LinkType)" -ForegroundColor Cyan
    Write-Host "Target: $($nvimInit.Target)" -ForegroundColor Yellow
} else {
    Write-Host "ERROR: File not found!" -ForegroundColor Red
}
```

**Expected output:**
```
File exists: C:\Users\<username>\AppData\Local\nvim\init.lua
Link type: SymbolicLink
Target: C:\Users\<username>\.files\nvim\.local\nvim\init.lua
```

### 5. List All Created Symlinks

```powershell
# List all symlinks in LOCALAPPDATA\nvim
Get-ChildItem $env:LOCALAPPDATA\nvim -Recurse -Force | 
    Where-Object { $_.LinkType -eq 'SymbolicLink' } | 
    Select-Object FullName, Target | 
    Format-Table -AutoSize
```

### 6. Test Unstowing

```powershell
# Unstow nvim package
.\stow.ps1 -Unstow nvim -Verbose
```

**Expected output:**
```
===== Unstowing package: nvim =====
Source: C:\Users\<username>\.files\nvim
Target: C:\Users\<username>\.config

--- Unlinking: nvim\init.lua
✓ Removed symlink: C:\Users\<username>\AppData\Local\nvim\init.lua

✓ Unstowed 42 file(s) from package: nvim
```

### 7. Verify Cleanup

```powershell
# Check that nvim directory is empty or removed
Get-ChildItem $env:LOCALAPPDATA\nvim -ErrorAction SilentlyContinue

# Should show nothing or "cannot find path"
```

## Common Issues and Solutions

### Issue: "Access Denied" errors

**Solution**: Run PowerShell as Administrator or enable Developer Mode

```powershell
# Check Developer Mode status
Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock | 
    Select-Object AllowDevelopmentWithoutDevLicense

# Enable Developer Mode (requires admin)
Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock `
    -Name AllowDevelopmentWithoutDevLicense -Value 1
```

### Issue: Symlinks created in wrong location

**Symptoms**: Files appear in `LOCALAPPDATA\.config\nvim\` instead of `LOCALAPPDATA\nvim\`

**Solution**: This indicates the bug still exists. Check:

1. Are you on the latest commit of `feat/windows-dotfiles-installer`?
   ```powershell
   git log -1 --oneline
   # Should show: "fix: ensure .local/ prefix takes precedence over .config/ in stow.ps1"
   ```

2. Pull latest changes:
   ```powershell
   git fetch origin
   git pull origin feat/windows-dotfiles-installer
   ```

3. Clean up and retry:
   ```powershell
   .\stow.ps1 -Unstow nvim
   Remove-Item $env:LOCALAPPDATA\.config\nvim -Recurse -Force -ErrorAction SilentlyContinue
   .\stow.ps1 -Stow nvim -Verbose
   ```

### Issue: "Package not found: nvim"

**Solution**: Make sure you're in the correct directory

```powershell
# Navigate to dotfiles repository
cd $env:USERPROFILE\.files

# Verify nvim package exists
Test-Path .\nvim\.local\nvim
# Should return: True
```

## Test Checklist

Use this checklist to ensure complete testing:

- [ ] Environment verified (PS7+, LOCALAPPDATA correct)
- [ ] Dry run executed with `-Verbose`
- [ ] Dry run output shows correct LOCALAPPDATA paths (no `.config` in path)
- [ ] Actual stow operation completed successfully
- [ ] Symlinks verified with `Get-Item` showing correct LinkType and Target
- [ ] All symlinks point to `.local/nvim/` in source, not `.config/nvim/`
- [ ] Target paths are `LOCALAPPDATA\nvim\*`, not `LOCALAPPDATA\.config\nvim\*`
- [ ] Unstow operation removes all symlinks
- [ ] No leftover directories or files after unstow
- [ ] Restow operation works: `.\stow.ps1 -Restow nvim -Verbose`

## Automated Test Script

Save this as `Test-StowLocalAppData.ps1` for quick testing:

```powershell
#Requires -Version 7.0

$ErrorActionPreference = 'Stop'

Write-Host "===== Testing stow.ps1 LOCALAPPDATA Support =====" -ForegroundColor Cyan
Write-Host ""

# Test 1: Environment check
Write-Host "Test 1: Environment check" -ForegroundColor Yellow
Write-Host "PowerShell version: $($PSVersionTable.PSVersion)"
Write-Host "LOCALAPPDATA: $env:LOCALAPPDATA"
Write-Host ""

# Test 2: Dry run
Write-Host "Test 2: Dry run with verbose" -ForegroundColor Yellow
.\stow.ps1 -Stow nvim -DryRun -Verbose
Write-Host ""

# Test 3: Actual stow
Write-Host "Test 3: Stowing nvim package" -ForegroundColor Yellow
.\stow.ps1 -Stow nvim -Verbose
Write-Host ""

# Test 4: Verify symlinks
Write-Host "Test 4: Verifying symlinks" -ForegroundColor Yellow
$initLua = Get-Item $env:LOCALAPPDATA\nvim\init.lua -ErrorAction SilentlyContinue
if ($initLua -and $initLua.LinkType -eq 'SymbolicLink') {
    Write-Host "✓ init.lua is a valid symlink" -ForegroundColor Green
    Write-Host "  Target: $($initLua.Target)" -ForegroundColor Gray
    
    # Check path correctness
    if ($initLua.FullName -notmatch '\.config') {
        Write-Host "✓ Path is correct (no .config in LOCALAPPDATA path)" -ForegroundColor Green
    } else {
        Write-Host "✗ ERROR: Path contains .config (BUG!)" -ForegroundColor Red
        Write-Host "  Path: $($initLua.FullName)" -ForegroundColor Red
    }
} else {
    Write-Host "✗ init.lua not found or not a symlink" -ForegroundColor Red
}
Write-Host ""

# Test 5: List all symlinks
Write-Host "Test 5: All symlinks in nvim directory" -ForegroundColor Yellow
$symlinks = Get-ChildItem $env:LOCALAPPDATA\nvim -Recurse -Force | 
    Where-Object { $_.LinkType -eq 'SymbolicLink' }
Write-Host "Found $($symlinks.Count) symlinks" -ForegroundColor Cyan
Write-Host ""

# Test 6: Unstow
Write-Host "Test 6: Unstowing nvim package" -ForegroundColor Yellow
.\stow.ps1 -Unstow nvim -Verbose
Write-Host ""

# Test 7: Verify cleanup
Write-Host "Test 7: Verifying cleanup" -ForegroundColor Yellow
if (Test-Path $env:LOCALAPPDATA\nvim) {
    $remaining = Get-ChildItem $env:LOCALAPPDATA\nvim -Force
    if ($remaining.Count -eq 0) {
        Write-Host "✓ Directory empty (will be cleaned up by Windows)" -ForegroundColor Green
    } else {
        Write-Host "✗ WARNING: $($remaining.Count) files/folders remain" -ForegroundColor Yellow
    }
} else {
    Write-Host "✓ nvim directory removed" -ForegroundColor Green
}

Write-Host ""
Write-Host "===== Testing complete! =====" -ForegroundColor Cyan
```

## Running the Automated Test

```powershell
cd C:\Users\<username>\.files\_scripts\windows
.\Test-StowLocalAppData.ps1
```

## What to Report

If you find issues, please report:

1. **PowerShell version**: `$PSVersionTable.PSVersion`
2. **Windows version**: `(Get-WmiObject Win32_OperatingSystem).Caption`
3. **Git commit**: `git log -1 --oneline`
4. **Dry run output**: Copy/paste the verbose output
5. **Actual symlink paths**: From `Get-Item` command
6. **Error messages**: Full error text if any

## Success Criteria

✅ All tests pass when:

- Dry run shows paths like `LOCALAPPDATA\nvim\*`
- Actual symlinks created in `LOCALAPPDATA\nvim\*`
- No `.config` appears in LOCALAPPDATA paths
- Symlinks point to `.local\nvim\*` in source repo
- Unstow cleanly removes all symlinks
- No errors during stow/unstow operations
