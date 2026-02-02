# Windows Dotfiles Quick Start

## One-Time Setup

### 1. Install Fonts (Run as Admin)
```powershell
cd C:\Users\yayam\.files\_scripts\windows\pwsh
Start-Process pwsh -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File .\Install-ModernFonts.ps1' -Verb RunAs
```

### 2. Install Professional Packages
```powershell
cd C:\Users\yayam\.files\_scripts
.\install.ps1 -Type pro
```

### 3. Install LazyVim (Optional)
```powershell
cd C:\Users\yayam\.files\_scripts\windows\pwsh
.\Install-LazyVim.ps1

# Or skip backup if you don't have existing config
.\Install-LazyVim.ps1 -SkipBackup
```

### 4. Stow Dotfiles
```powershell
cd C:\Users\yayam\.files

# Terminal and shell configs (to ~/.config)
.\stow.ps1 wezterm
.\stow.ps1 nu
.\stow.ps1 starship

# PowerShell profile (to home directory)
.\stow.ps1 powershell -Target C:\Users\yayam

# Optional: Neovim config (to $env:LOCALAPPDATA)
# Note: LazyVim installer already created config at $env:LOCALAPPDATA\nvim
# Only stow if you want to version control your custom config
# .\stow.ps1 nvim
```

## Verification

### Test PowerShell with Starship
```powershell
# Close and reopen PowerShell
pwsh

# Should see Starship prompt with icons
```

### Test Nushell with Starship
```powershell
nu

# Should see Starship prompt with icons
```

### Test WezTerm
```
1. Launch WezTerm from Start Menu
2. Should see Catppuccin Mocha theme
3. Should see CaskaydiaMono Nerd Font
4. No OpenGL errors (using WebGpu)
```

### Test Neovim/LazyVim (if installed)
```powershell
nvim

# On first launch, LazyVim will install plugins automatically
# Run health check: :LazyHealth
# Press <leader>l to open Lazy plugin manager
```

## Quick Commands

### Package Management
```powershell
# Install personal packages
.\install.ps1 -Type perso

# Update existing packages
.\install.ps1 -Type pro -CheckUpdate

# Install JS/Bun packages
cd _scripts\windows\pwsh
.\install-js-packages.ps1 -Type pro

# Install LazyVim
cd _scripts\windows\pwsh
.\Install-LazyVim.ps1
```

### Stow Management
```powershell
# List available packages
.\stow.ps1 -ListPackages

# Dry run before stowing
.\stow.ps1 wezterm -DryRun -Verbose

# Unstow a package
.\stow.ps1 -Unstow wezterm

# Restow (unstow + stow)
.\stow.ps1 wezterm -Restow
```

### Aliases Available

#### Git (PowerShell & Nushell)
- `gst` → `git status`
- `gp` → `git push`
- `gc` → `git commit`
- `glog` → `git log --oneline --graph`

#### Kubernetes (PowerShell & Nushell)
- `k` → `kubectl`
- `kg` → `kubectl get`
- `kd` → `kubectl describe`
- `kl` → `kubectl logs`

#### Enhanced Commands
- `cx <path>` → cd + ls combined

## Troubleshooting

### Icons not showing?
→ Install Nerd Fonts (step 1 above)

### Starship not loading?
→ Close and reopen terminal session

### Config not found?
→ Verify symlinks: `Get-Item ~\.config\wezterm\wezterm.lua`

### Need to refresh PATH?
→ Run `refreshenv` or restart terminal

## Full Documentation

See `TESTING.md` for comprehensive testing guide.
