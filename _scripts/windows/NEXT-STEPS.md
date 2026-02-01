# Next Steps - Windows Dotfiles Testing

## Current Status ✅

All development work is **COMPLETE** and pushed to GitHub on branch `feat/windows-dotfiles-installer`.

### What's Ready:
- ✅ Package installation system (Chocolatey, winget, Bun)
- ✅ GNU Stow-like dotfiles manager (`stow.ps1`)
- ✅ WezTerm configuration (WebGpu rendering, Catppuccin theme)
- ✅ Nushell configuration (Starship, aliases, vi mode)
- ✅ PowerShell profile (Starship, aliases, PATH setup)
- ✅ Font installer (CascadiaMono, JetBrainsMono)
- ✅ All configurations committed and pushed
- ✅ Documentation complete (TESTING.md, QUICK-START.md, README.md)

---

## Testing Required (On Windows Machine)

### Prerequisites
- Windows 11 machine: `192.168.10.154`
- User: `yayam`
- Branch: `feat/windows-dotfiles-installer`
- All packages should be installed via `install.ps1`
- All dotfiles should be stowed via `stow.ps1`

### Testing Checklist

#### 1. Install Nerd Fonts ⏳ NEEDS TESTING
```powershell
# Open PowerShell as Administrator
cd C:\Users\yayam\.files\_scripts\windows\pwsh
.\Install-ModernFonts.ps1
```

**Expected**: CascadiaMono and JetBrainsMono Nerd Fonts installed to `C:\Windows\Fonts`

**Verification**:
```powershell
Get-ChildItem "C:\Windows\Fonts" | Where-Object { $_.Name -like "*CaskaydiaMono*" }
```

---

#### 2. Test PowerShell with Starship ⏳ NEEDS TESTING
```powershell
# Close all PowerShell sessions
# Open new PowerShell 7 session
pwsh
```

**Expected**:
- Starship prompt appears with icons
- Git status in prompt when in git repo
- No errors

**Test Commands**:
```powershell
# Verify profile loaded
Test-Path $PROFILE  # Should be True

# Test Git aliases
cd C:\Users\yayam\.files
gst      # Should run 'git status'
glog     # Should show git log

# Test Kubernetes aliases
k version --client

# Test enhanced cd
cx C:\Users\yayam  # Should cd + ls
```

---

#### 3. Test Nushell with Starship ⏳ NEEDS TESTING
```powershell
# From PowerShell, launch Nushell
nu
```

**Expected**:
- Starship prompt appears with icons
- No startup errors

**Test Commands**:
```nushell
# Test Git aliases
cd C:\Users\yayam\.files
gst      # Should run 'git status'
glog     # Should show git log

# Test Kubernetes aliases
k version --client

# Test enhanced cd
cx C:\Users\yayam  # Should cd + ls

# Exit Nushell
exit
```

---

#### 4. Test WezTerm ⏳ NEEDS TESTING

**Steps**:
1. Launch WezTerm from Start Menu
2. Observe appearance

**Expected**:
- No OpenGL errors (using WebGpu)
- CaskaydiaMono Nerd Font renders correctly
- Catppuccin Mocha theme (dark background)
- Icons display properly (not boxes)

**Test Commands**:
```powershell
# Check version
wezterm --version

# Test split panes
# Alt+Shift+| (horizontal split)
# Alt+Shift+- (vertical split)
# Alt+h/j/k/l (navigate panes)

# Test font rendering
echo "  "  # Icons should render
```

---

## After Testing

### If All Tests Pass ✅

1. **Update this document** with test results:
   ```powershell
   # Mark items as ✅ PASSED or ❌ FAILED in this file
   ```

2. **Optional: Install additional tools**:
   ```powershell
   # Zoxide (smart cd)
   choco install zoxide

   # Update Nushell env.nu to enable zoxide
   # Uncomment: use ~/.cache/starship/init.nu
   ```

3. **Create final commit**:
   ```powershell
   cd C:\Users\yayam\.files
   git add .
   git commit -m "test: verify Windows dotfiles installation - all tests passed"
   git push origin feat/windows-dotfiles-installer
   ```

4. **Merge to main** (when satisfied):
   ```powershell
   git checkout main
   git merge feat/windows-dotfiles-installer
   git push origin main
   ```

### If Tests Fail ❌

1. **Document the issue** in this file:
   - What failed?
   - Error message?
   - Steps to reproduce?

2. **Check logs and paths**:
   ```powershell
   # Verify symlinks exist
   Get-Item ~\.config\wezterm\wezterm.lua
   Get-Item ~\.config\nushell\config.nu
   Get-Item ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

   # Check Starship installation
   Get-Command starship

   # Check font installation
   Get-ChildItem C:\Windows\Fonts | Select-String -Pattern "CaskaydiaMono|JetBrainsMono"
   ```

3. **Report to developer** with:
   - Test that failed
   - Error messages
   - Relevant logs
   - Screenshots (if applicable)

---

## Test Results (Fill in after testing)

### Test 1: Install Nerd Fonts
- **Status**: ⏳ PENDING
- **Notes**: 
- **Screenshot**: 

### Test 2: PowerShell with Starship
- **Status**: ⏳ PENDING
- **Notes**: 
- **Screenshot**: 

### Test 3: Nushell with Starship
- **Status**: ⏳ PENDING
- **Notes**: 
- **Screenshot**: 

### Test 4: WezTerm
- **Status**: ⏳ PENDING
- **Notes**: 
- **Screenshot**: 

---

## Resources

- **Quick Start**: [QUICK-START.md](QUICK-START.md)
- **Testing Guide**: [../../TESTING.md](../../TESTING.md)
- **Main README**: [../../README.md](../../README.md)

---

## Contact

If you encounter issues or need clarification:
1. Check the documentation above
2. Review error messages carefully
3. Consult TESTING.md for troubleshooting
4. Document any issues in this file for follow-up
