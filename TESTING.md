# Windows Dotfiles Testing Guide

This guide provides step-by-step instructions for testing the Windows dotfiles installation.

## Prerequisites

- All packages installed via `install.ps1`
- Dotfiles stowed using `stow.ps1`
- Windows machine with direct access (not SSH)

## Testing Checklist

### 1. Install Nerd Fonts ⏳

**Why**: WezTerm and Starship require Nerd Fonts for proper icon rendering.

**Steps**:
```powershell
# Open PowerShell as Administrator
cd C:\Users\yayam\.files\_scripts\windows\pwsh
.\Install-ModernFonts.ps1
```

**Expected Output**:
- ✅ Downloads CascadiaMono and JetBrainsMono Nerd Fonts from GitHub
- ✅ Extracts .ttf files
- ✅ Copies fonts to `C:\Windows\Fonts`
- ✅ Success message for each font installed

**Verification**:
```powershell
# Check if fonts are installed
Get-ChildItem "C:\Windows\Fonts" | Where-Object { $_.Name -like "*CaskaydiaMono*" -or $_.Name -like "*JetBrainsMono*" }
```

---

### 2. Verify PowerShell Profile with Starship ⏳

**Why**: Ensure PowerShell profile loads correctly with Starship prompt.

**Steps**:
```powershell
# Close all PowerShell sessions
# Open a new PowerShell 7 session (pwsh)
pwsh
```

**Expected Output**:
- ✅ Starship prompt appears (with icons and colors)
- ✅ Git status shows in prompt when in a git repository
- ✅ No errors during profile load

**Verification Tests**:
```powershell
# Test 1: Verify profile is loaded
$PROFILE
Test-Path $PROFILE  # Should return True

# Test 2: Verify Starship is initialized
Get-Command starship  # Should show starship executable

# Test 3: Test Git aliases
cd C:\Users\yayam\.files
gst  # Should run 'git status'
glog  # Should show git log

# Test 4: Test Kubernetes aliases
k version --client  # Should run 'kubectl version --client'

# Test 5: Test enhanced cd command
cx C:\Users\yayam  # Should cd and list directory
```

**Common Issues**:
- **Starship not found**: Ensure Starship is installed via Chocolatey
- **Profile not loaded**: Check `$PROFILE` path matches stowed location
- **Icons not showing**: Install Nerd Fonts (step 1)

---

### 3. Verify Nushell with Starship ⏳

**Why**: Ensure Nushell configuration loads correctly with Starship prompt.

**Steps**:
```powershell
# From PowerShell, launch Nushell
nu
```

**Expected Output**:
- ✅ Starship prompt appears (with icons and colors)
- ✅ Git status shows in prompt when in a git repository
- ✅ No errors during startup

**Verification Tests**:
```nushell
# Test 1: Verify config is loaded
$env.config.show_banner  # Should return false

# Test 2: Verify Starship is initialized
which starship  # Should show starship path

# Test 3: Test Git aliases
cd C:\Users\yayam\.files
gst  # Should run 'git status'
glog  # Should show git log

# Test 4: Test Kubernetes aliases
k version --client  # Should run 'kubectl version --client'

# Test 5: Test enhanced cd command
cx C:\Users\yayam  # Should cd and list directory

# Test 6: Check color theme
$env.config.color_config  # Should show Catppuccin-inspired colors

# Exit Nushell
exit
```

**Common Issues**:
- **Config not found**: Verify `~\.config\nushell\config.nu` exists and is symlinked
- **Starship not found**: Ensure Starship is in PATH
- **Icons not showing**: Install Nerd Fonts (step 1)

---

### 4. Test WezTerm Configuration ⏳

**Why**: Ensure WezTerm uses correct rendering backend, font, and theme.

**Steps**:
1. Launch WezTerm from Start Menu or Windows Terminal
2. Observe the terminal appearance

**Expected Output**:
- ✅ WebGpu rendering (no OpenGL errors)
- ✅ CaskaydiaMono Nerd Font renders correctly
- ✅ Catppuccin Mocha theme applied
- ✅ Icons and glyphs display properly
- ✅ No errors in WezTerm logs

**Verification Tests**:
```powershell
# Test 1: Check WezTerm version
wezterm --version

# Test 2: Verify config is loaded
# In WezTerm, press Ctrl+Shift+L to open debug overlay
# Should show config path: C:\Users\yayam\.config\wezterm\wezterm.lua

# Test 3: Test split panes
# Press Alt+Shift+| to split horizontally
# Press Alt+Shift+- to split vertically
# Press Alt+h/j/k/l to navigate between panes

# Test 4: Check font rendering
# Open WezTerm and type: echo ""
# Icons should render correctly (not as boxes)

# Test 5: Check theme
# Background should be dark (Catppuccin Mocha)
# Text should be readable with good contrast
```

**Common Issues**:
- **OpenGL errors**: Config should use WebGpu backend (already configured)
- **Font not found**: Install CaskaydiaMono Nerd Font (step 1)
- **Config not loaded**: Verify `~\.config\wezterm\wezterm.lua` exists and is symlinked
- **Icons not showing**: Install Nerd Fonts (step 1)

---

## Summary

After completing all tests, you should have:

✅ **Fonts**: CaskaydiaMono and JetBrainsMono Nerd Fonts installed  
✅ **PowerShell**: Profile loaded with Starship prompt and aliases  
✅ **Nushell**: Config loaded with Starship prompt and aliases  
✅ **WezTerm**: Running with WebGpu, Nerd Font, and Catppuccin theme  

## Troubleshooting

### General Issues

**Problem**: Symlinks not created  
**Solution**: Ensure Developer Mode is enabled OR run `stow.ps1` as Administrator

**Problem**: UTF-8 encoding issues  
**Solution**: Ensure all config files have UTF-8 BOM encoding for Windows PowerShell

**Problem**: PATH not updated  
**Solution**: Restart terminal session or run `refreshenv` (Chocolatey)

### Reporting Issues

If you encounter issues:

1. Check error messages in terminal
2. Verify file paths and symlinks exist
3. Check tool versions: `starship --version`, `pwsh --version`, `nu --version`
4. Review WezTerm debug logs: `wezterm ls-fonts` or debug overlay (Ctrl+Shift+L)

---

## Next Steps After Testing

Once all tests pass:

1. **Optional Tools**: Install optional integrations
   - [ ] Zoxide (smart cd): `choco install zoxide`
   - [ ] Carapace (completions): Install from GitHub releases
   - [ ] Direnv (directory environments): `choco install direnv`
   - [ ] Atuin (shell history): Install from GitHub releases

2. **Customize**: Modify configurations to your preferences
   - Edit `~\.config\wezterm\wezterm.lua` for WezTerm settings
   - Edit `~\.config\nushell\config.nu` for Nushell settings
   - Edit `~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` for PowerShell settings
   - Edit `~\.config\starship.toml` for prompt customization

3. **Backup**: Create a backup of your working configuration
   ```powershell
   # Commit any local changes if needed
   cd C:\Users\yayam\.files
   git add .
   git commit -m "Windows dotfiles: tested and verified"
   git push origin feat/windows-dotfiles-installer
   ```

4. **Merge to Main**: Once satisfied, merge the feature branch
   ```powershell
   git checkout main
   git merge feat/windows-dotfiles-installer
   git push origin main
   ```
