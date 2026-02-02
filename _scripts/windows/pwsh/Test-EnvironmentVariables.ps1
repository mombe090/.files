#Requires -Version 7.0

<#
.SYNOPSIS
    Tests XDG environment variables setup
.DESCRIPTION
    Verifies that XDG Base Directory environment variables are properly set
    and that the directory structure is created correctly.
.EXAMPLE
    .\Test-EnvironmentVariables.ps1
#>

# Import helper functions
$libPath = Join-Path $PSScriptRoot ".." ".." "lib" "pwsh"
. "$libPath\colors.ps1"

Write-Header "Testing XDG Environment Variables"
Write-Host ""

# Expected environment variables
$expectedVars = @(
    @{
        Name = 'XDG_CONFIG_HOME'
        ExpectedValue = Join-Path $env:USERPROFILE '.config'
        Description = 'Configuration files directory'
    },
    @{
        Name = 'XDG_DATA_HOME'
        ExpectedValue = Join-Path $env:USERPROFILE '.local' 'share'
        Description = 'Application data directory'
    },
    @{
        Name = 'XDG_CACHE_HOME'
        ExpectedValue = Join-Path $env:USERPROFILE '.cache'
        Description = 'Cache files directory'
    },
    @{
        Name = 'XDG_STATE_HOME'
        ExpectedValue = Join-Path $env:USERPROFILE '.local' 'state'
        Description = 'State files directory'
    }
)

$allTestsPassed = $true

# Test 1: Check if variables are set
Write-Header "Test 1: Environment Variables Set"
Write-Host ""

foreach ($var in $expectedVars) {
    Write-Step "Checking: $($var.Name)"
    
    $actualValue = [System.Environment]::GetEnvironmentVariable($var.Name)
    
    if ($actualValue) {
        if ($actualValue -eq $var.ExpectedValue) {
            Write-Success "✓ Set correctly: $actualValue"
        }
        else {
            Write-Warn "⚠ Set but unexpected value"
            Write-Info "  Expected: $($var.ExpectedValue)"
            Write-Info "  Actual:   $actualValue"
        }
    }
    else {
        Write-ErrorMsg "✗ Not set"
        Write-Info "  Expected: $($var.ExpectedValue)"
        $allTestsPassed = $false
    }
    
    Write-Host ""
}

# Test 2: Check if directories exist
Write-Header "Test 2: Directories Exist"
Write-Host ""

foreach ($var in $expectedVars) {
    Write-Step "Checking directory: $($var.Name)"
    
    $path = [System.Environment]::GetEnvironmentVariable($var.Name)
    
    if ($path -and (Test-Path $path)) {
        Write-Success "✓ Directory exists: $path"
    }
    elseif ($path) {
        Write-Warn "⚠ Directory does not exist: $path"
        Write-Info "  Run: New-Item -ItemType Directory -Force -Path '$path'"
    }
    else {
        Write-ErrorMsg "✗ Variable not set, cannot check directory"
        $allTestsPassed = $false
    }
    
    Write-Host ""
}

# Test 3: Check PowerShell profile sets variables
Write-Header "Test 3: PowerShell Profile Configuration"
Write-Host ""

$profilePath = $PROFILE
Write-Info "Profile location: $profilePath"
Write-Host ""

if (Test-Path $profilePath) {
    $profileContent = Get-Content $profilePath -Raw
    
    $varsToCheck = @('XDG_CONFIG_HOME', 'XDG_DATA_HOME', 'XDG_CACHE_HOME', 'XDG_STATE_HOME')
    $foundCount = 0
    
    foreach ($varName in $varsToCheck) {
        if ($profileContent -match "\`$env:$varName\s*=") {
            Write-Success "✓ Profile sets: $varName"
            $foundCount++
        }
        else {
            Write-Warn "⚠ Profile does not set: $varName"
        }
    }
    
    Write-Host ""
    
    if ($foundCount -eq $varsToCheck.Count) {
        Write-Success "All XDG variables configured in profile!"
    }
    else {
        Write-Warn "Some variables missing from profile"
        $allTestsPassed = $false
    }
}
else {
    Write-ErrorMsg "PowerShell profile not found: $profilePath"
    $allTestsPassed = $false
}

Write-Host ""

# Test 4: Check if variables are persisted (User scope)
Write-Header "Test 4: Persisted Variables (Optional)"
Write-Host ""

Write-Info "Checking if variables are persisted to User environment..."
Write-Host ""

$persistedCount = 0

foreach ($var in $expectedVars) {
    $persistedValue = [System.Environment]::GetEnvironmentVariable($var.Name, 'User')
    
    if ($persistedValue) {
        Write-Success "✓ Persisted (User): $($var.Name) = $persistedValue"
        $persistedCount++
    }
    else {
        Write-Info "  Not persisted: $($var.Name)"
    }
}

Write-Host ""

if ($persistedCount -gt 0) {
    Write-Success "$persistedCount variable(s) persisted to User environment"
    Write-Info "These will be available in all applications, not just PowerShell"
}
else {
    Write-Info "No variables persisted (this is OK)"
    Write-Info "Variables are set via PowerShell profile (session-based)"
    Write-Info "To persist: Run .\Set-EnvironmentVariables.ps1 -Persist"
}

Write-Host ""

# Summary
Write-Header "Test Summary"
Write-Host ""

if ($allTestsPassed) {
    Write-Success "✓ All tests passed!"
    Write-Host ""
    Write-Info "XDG environment variables are properly configured."
    Write-Info "Your Windows environment now follows XDG Base Directory spec."
}
else {
    Write-ErrorMsg "✗ Some tests failed"
    Write-Host ""
    Write-Info "Troubleshooting steps:"
    Write-Info "  1. Ensure PowerShell profile is stowed: .\stow.ps1 -Stow powershell -Target \$env:USERPROFILE"
    Write-Info "  2. Restart PowerShell to load profile"
    Write-Info "  3. Or run: .\Set-EnvironmentVariables.ps1"
    Write-Host ""
}

# Additional info
Write-Header "Additional Information"
Write-Host ""

Write-Info "Current session variables:"
Get-ChildItem env:XDG_* | ForEach-Object {
    Write-Info "  $($_.Name) = $($_.Value)"
}

Write-Host ""
Write-Info "For more information, see: _scripts/windows/ENVIRONMENT-VARIABLES.md"
