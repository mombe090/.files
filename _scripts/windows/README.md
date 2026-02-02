# Windows Dotfiles

Complete Windows development environment setup with native PowerShell 7 and Nushell support.

## 🚀 Quick Start

```powershell
# 1. Clone repository
git clone https://github.com/mombe090/.files.git C:\Users\<username>\.files
cd C:\Users\<username>\.files

# 2. Install fonts (as Administrator)
cd _scripts\windows\pwsh
Start-Process pwsh -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File .\Install-ModernFonts.ps1' -Verb RunAs

# 3. Install packages
cd C:\Users\<username>\.files\_scripts
.\install.ps1 -Type pro

# 4. Stow dotfiles
cd C:\Users\<username>\.files
.\stow.ps1 wezterm
.\stow.ps1 nushell
.\stow.ps1 starship
.\stow.ps1 powershell -Target C:\Users\<username>

# 5. Restart terminal to see Starship prompt
```

For detailed instructions, see **[QUICK-START.md](QUICK-START.md)**.


## 🔒 Corporate Environment & Security

**This implementation is designed to be safe for corporate environments:**

### ✅ What's Safe:
- **No direct registry modifications** - All system changes handled by package managers
- **User-space operations only** - No system-wide modifications
- **Temporary execution policies** - Only affects current PowerShell session
- **No hardcoded secrets** - All credentials stored in gitignored machine profile
- **Optional admin requirements** - Clearly documented when admin is needed
- **Work-safe packages** - Professional packages appropriate for corporate use

### ⚠️ Corporate Considerations:

1. **Chocolatey Installation**
   - Requires administrator privileges
   - **Ensure Chocolatey is approved by your IT department before installing**
   - Alternative: Pre-install Chocolatey via corporate package management tools

2. **Font Installer (Optional)**
   - Requires administrator privileges to copy fonts to `C:\Windows\Fonts`
   - **This step is completely optional** - you can skip it or use package manager instead
   - Alternative: `choco install cascadiafonts` or `winget install Cascadia.Fonts`

3. **AutoHotkey Package**
   - Keyboard automation tool that may violate some corporate security policies
   - **Commented out by default in pro packages**
   - Only uncomment if explicitly approved by your IT department

4. **Execution Policy**
   - Chocolatey installer temporarily sets execution policy to `Bypass -Scope Process`
   - **This is temporary** and only affects the current PowerShell session
   - Does not persist after script execution completes
   - This is the official Chocolatey installation method

### 📋 Security Review

A comprehensive security review has been conducted. See **[SECURITY-REVIEW.md](SECURITY-REVIEW.md)** for details.

**Security Rating:** 🟢 **LOW RISK** for corporate environments


## 📚 Documentation

### Getting Started
- **[QUICK-START.md](QUICK-START.md)** - Quick reference guide for setup and common tasks
- **[NEXT-STEPS.md](NEXT-STEPS.md)** - Testing checklist and verification steps

### Core Features
- **[ENVIRONMENT-VARIABLES.md](ENVIRONMENT-VARIABLES.md)** - XDG environment variables (automatic setup)
- **[MACHINE-PROFILE.md](MACHINE-PROFILE.md)** - Machine-specific PowerShell customizations
- **[../GIT-ALIASES.md](../GIT-ALIASES.md)** - 260+ Oh My Zsh-style git aliases reference

### Advanced Topics
- **[LOCALAPPDATA-STOW.md](LOCALAPPDATA-STOW.md)** - How `.local/` and `.config/` paths are routed
- **[TESTING-STOW.md](TESTING-STOW.md)** - Comprehensive stow.ps1 testing guide

### Repository Documentation
- **[../../README.md](../../README.md)** - Main repository README
- **[../STOW_GUIDE.md](../STOW_GUIDE.md)** - General stow guide (cross-platform)
- **[../WINDOWS-COMPLETE.md](../WINDOWS-COMPLETE.md)** - Implementation details and design decisions

## ✨ What You Get

### Shell Environment
- 🪟 **PowerShell 7** with Starship prompt, vi mode, and 260+ git aliases
- 🐚 **Nushell** with Starship prompt, vi mode, and cross-platform aliases
- 🎨 **Starship** prompt with git status, command duration, and custom icons
- 🔧 **Automatic XDG variables** for cross-platform config compatibility

### Terminal & Fonts
- 🖥️ **WezTerm** terminal with WebGpu rendering and Catppuccin Mocha theme
- 🔤 **Nerd Fonts** (CascadiaMono, JetBrainsMono) for icon support
- 📋 Optimized font rendering and ligatures

### Development Tools
- 📦 **Package managers**: Chocolatey (primary), winget (fallback), Bun (JavaScript)
- 🔨 **Dev tools**: Git, VSCode, IntelliJ, Neovim, kubectl, Terraform, Docker
- 🛠️ **CLI utilities**: bat, fd, ripgrep, fzf, zoxide, lazygit
- 🎯 **Language runtimes**: Python, Node.js, .NET SDK, Java, Lua

### Git Integration
- 260+ Oh My Zsh-style git aliases in both PowerShell and Nushell
- Helper functions for smart branch detection (main/master/trunk, develop/dev/devel)
- Safe defaults (`gpf` uses `--force-with-lease` instead of `--force`)
- Coverage: add, branch, checkout, commit, diff, fetch, log, merge, push, pull, rebase, remote, reset, restore, stash, status, switch, tag, worktree, cherry-pick, reflog, bisect, submodule

### Optional Features
- 🎨 **LazyVim** - Neovim distribution with LSP, linting, formatting, and more
- 🔐 **Machine-specific profile** - Per-machine customizations (secrets, paths, etc.)
- ⚙️ **Modular configuration** - Easy to customize and extend

## 📦 Package Management

### Install Packages

```powershell
# Professional packages (work-safe)
.\install.ps1 -Type pro

# Personal packages (media, gaming, browsers)
.\install.ps1 -Type perso

# Everything
.\install.ps1 -Type all

# Update existing packages
.\install.ps1 -Type pro -CheckUpdate
```

### JavaScript Packages

```powershell
cd _scripts\windows\pwsh
.\install-js-packages.ps1 -Type pro
```

### Available Package Categories

**Professional (60+ packages):**
- Essentials: PowerShell 7, Git, Windows Terminal, VSCode, IntelliJ, 7-Zip
- Development: .NET SDK, Python, Node.js, Bun, MinGW, OpenJDK, Lua, Neovim
- Productivity: Obsidian, PowerToys, AutoHotkey, Adobe Reader
- Cloud: Azure CLI, kubectl, kubectx, kubens, Helm, Terraform
- Tools: Starship, bat, fd, ripgrep, fzf, zoxide, lazygit, win32yank

**Personal (60+ packages):**
- Media: VLC, MPV, Spotify, Audacity, OBS Studio
- Communication: Discord, Slack, Zoom
- Gaming: Steam, Epic Games Launcher, RetroArch, Dolphin Emulator
- Browsers: Firefox, Brave, Chromium

See package configurations in `_scripts/configs/packages/`.

## 🔧 Stow Management

### Stow Dotfiles

```powershell
# List available packages
.\stow.ps1 -ListPackages

# Stow a package (to ~/.config by default)
.\stow.ps1 wezterm

# Stow to specific target directory
.\stow.ps1 powershell -Target C:\Users\<username>

# Dry run before stowing
.\stow.ps1 wezterm -DryRun -Verbose

# Unstow a package
.\stow.ps1 -Unstow wezterm

# Restow (unstow + stow)
.\stow.ps1 wezterm -Restow
```

### How Stow Works

The `stow.ps1` script creates symlinks from your dotfiles repository to their proper locations:

- **`.config/`** files → `$env:USERPROFILE\.config\`
- **`.local/`** files → `$env:LOCALAPPDATA\` (e.g., `nvim/.local/nvim/` → `%LOCALAPPDATA%\nvim\`)
- **Other files** → Target directory (default: `$env:USERPROFILE`)

**Important:** `.local/` prefix has **higher precedence** than `.config/` to ensure correct LOCALAPPDATA routing.

See [LOCALAPPDATA-STOW.md](LOCALAPPDATA-STOW.md) for detailed path routing explanation.

## 🎯 Common Tasks

### Git Aliases (PowerShell & Nushell)

```powershell
# Status and info
gst              # git status
gss              # git status --short
gd               # git diff
gdc              # git diff --cached

# Add and commit
ga <files>       # git add
gaa              # git add --all
gcmsg <msg>      # git commit -m
gcam <msg>       # git commit -a -m (add all + commit)
gca              # git commit --amend

# Branch management
gb               # git branch
gba              # git branch -a (all branches)
gcb <name>       # git checkout -b (create + checkout)
gco <branch>     # git checkout
gsw <branch>     # git switch

# Push and pull
gp               # git push
gpo              # git push origin
gpf              # git push --force-with-lease (safe force)
gl               # git pull
ggl              # git pull origin <current-branch>

# Log and history
glog             # git log --oneline --graph --decorate
glola            # git log --graph --all
gcount           # git shortlog -sn (commit count by author)

# Stash
gsta             # git stash push
gstp             # git stash pop
gstl             # git stash list

# Rebase
grb              # git rebase
grbi             # git rebase -i
grbc             # git rebase --continue
grba             # git rebase --abort

# Reset and restore
grh              # git reset
grhh             # git reset --hard
gclean           # git clean -fd (remove untracked)
gpristine        # git reset --hard + clean (fresh state)
```

For complete list, see [GIT-ALIASES.md](../GIT-ALIASES.md).

### Kubernetes Aliases (PowerShell & Nushell)

```powershell
k                # kubectl
kg <resource>    # kubectl get
kd <res> <name>  # kubectl describe
kl <pod>         # kubectl logs -f
kgpo             # kubectl get pods
kgd              # kubectl get deployments
ke <pod>         # kubectl exec -it <pod> -- sh
```

### Enhanced Commands

```powershell
cx <path>        # cd + ls combined (change directory and list contents)
```

## 🛠️ Optional Components

### LazyVim (Neovim Distribution)

```powershell
cd _scripts\windows\pwsh
.\Install-LazyVim.ps1

# Or skip backup if no existing config
.\Install-LazyVim.ps1 -SkipBackup
```

After installation:
1. Launch Neovim: `nvim`
2. LazyVim will auto-install plugins on first launch
3. Run health check: `:LazyHealth`
4. Open Lazy plugin manager: `<leader>l`

### Machine-Specific Profile

For machine-specific customizations (secrets, API keys, paths, etc.):

```powershell
# Copy template
Copy-Item "_scripts\windows\profile.ps1.template" "$env:USERPROFILE\profile.ps1"

# Edit for this machine
code $env:USERPROFILE\profile.ps1
```

This file is automatically loaded by PowerShell profile if it exists and is ignored by git.

See [MACHINE-PROFILE.md](MACHINE-PROFILE.md) for examples and best practices.

## 🧪 Testing & Verification

### Test PowerShell Profile

```powershell
# Reload profile
. $PROFILE

# Test git aliases
gst

# Test kubernetes aliases (if kubectl installed)
k version --client

# Test enhanced cd
cx $env:USERPROFILE
```

### Test Nushell

```powershell
# Launch Nushell
nu

# Test aliases
gst
cx ~

# Exit
exit
```

### Test Stow (Automated)

```powershell
cd _scripts\windows\pwsh
.\Test-StowLocalAppData.ps1
```

### Test XDG Variables (Automated)

```powershell
cd _scripts\windows\pwsh
.\Test-EnvironmentVariables.ps1
```

### Verify Symlinks

```powershell
# Check if symlinks exist
Get-Item ~\.config\wezterm\wezterm.lua
Get-Item ~\.config\nushell\config.nu
Get-Item ~\.config\starship.toml
Get-Item ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

# Check LOCALAPPDATA symlinks (if applicable)
Get-Item $env:LOCALAPPDATA\nvim
```

## 🐛 Troubleshooting

### Icons not showing?
→ Install Nerd Fonts (see Quick Start step 2)

### Starship not loading?
→ Close and reopen terminal session
→ Verify: `Get-Command starship`

### Config not found?
→ Verify symlinks: `Get-Item ~\.config\wezterm\wezterm.lua`
→ Check stow output for errors

### Git aliases not working?
→ Check if `git-aliases.ps1` exists in PowerShell profile directory
→ Reload profile: `. $PROFILE`

### Need to refresh PATH?
→ Run `refreshenv` or restart terminal

### XDG variables not set?
→ Reload PowerShell profile: `. $PROFILE`
→ Check profile: `Test-Path $PROFILE`

### Stow errors?
→ Run with `-Verbose` flag: `.\stow.ps1 wezterm -Verbose`
→ Check [TESTING-STOW.md](TESTING-STOW.md) for detailed testing

## 📁 Repository Structure

```
.files/
├── _scripts/
│   ├── install.ps1                 # Main installer
│   ├── windows/
│   │   ├── QUICK-START.md          # Quick reference guide
│   │   ├── ENVIRONMENT-VARIABLES.md
│   │   ├── MACHINE-PROFILE.md
│   │   ├── LOCALAPPDATA-STOW.md
│   │   ├── TESTING-STOW.md
│   │   ├── NEXT-STEPS.md
│   │   ├── profile.ps1.template
│   │   └── pwsh/
│   │       ├── Install-ModernFonts.ps1
│   │       ├── Install-LazyVim.ps1
│   │       ├── install-packages.ps1
│   │       ├── install-js-packages.ps1
│   │       ├── Test-StowLocalAppData.ps1
│   │       └── Test-EnvironmentVariables.ps1
│   ├── configs/packages/
│   │   ├── pro/
│   │   │   ├── choco.pkg.yml
│   │   │   ├── winget.pkg.yml
│   │   │   └── js.pkg.yml
│   │   └── perso/
│   │       ├── choco.pkg.yml
│   │       └── winget.pkg.yml
│   └── GIT-ALIASES.md
├── stow.ps1                        # Stow script
├── powershell/
│   └── Documents/PowerShell/
│       ├── Microsoft.PowerShell_profile.ps1
│       └── git-aliases.ps1
├── nushell/
│   └── .config/nushell/
│       ├── config.nu
│       ├── env.nu
│       └── git-aliases.nu
├── wezterm/
│   └── .config/wezterm/
│       └── wezterm.lua
├── starship/
│   └── .config/
│       └── starship.toml
└── nvim/
    └── .local/nvim/
        └── (optional custom Neovim config)
```

## 🎓 Learning Resources

### PowerShell
- [PowerShell 7 Documentation](https://docs.microsoft.com/powershell/)
- [PSReadLine](https://github.com/PowerShell/PSReadLine)
- [Oh My Posh](https://ohmyposh.dev/) (alternative to Starship)

### Nushell
- [Nushell Official Site](https://www.nushell.sh/)
- [Nushell Book](https://www.nushell.sh/book/)
- [Nushell Cookbook](https://www.nushell.sh/cookbook/)

### Terminal & Tools
- [WezTerm Documentation](https://wezfurlong.org/wezterm/)
- [Starship Configuration](https://starship.rs/config/)
- [Neovim Documentation](https://neovim.io/doc/)
- [LazyVim](https://www.lazyvim.org/)

### Windows Development
- [Windows Terminal Documentation](https://docs.microsoft.com/windows-terminal/)
- [WSL Documentation](https://docs.microsoft.com/windows/wsl/)
- [Chocolatey Packages](https://community.chocolatey.org/packages)
- [winget Packages](https://winget.run/)

## 🤝 Contributing

This is a personal dotfiles repository, but suggestions and improvements are welcome!

### Reporting Issues
1. Check if symlinks were created correctly
2. Verify package installation succeeded
3. Check PowerShell/Nushell profiles loaded
4. Include error messages and system info

### Suggesting Enhancements
- New package recommendations
- Alias improvements
- Configuration optimizations
- Documentation clarifications

## 📝 License

Personal dotfiles - use at your own discretion. No warranty provided.

## 🙏 Credits

- [Starship](https://starship.rs/) - Cross-shell prompt
- [WezTerm](https://wezfurlong.org/wezterm/) - GPU-accelerated terminal
- [Nushell](https://www.nushell.sh/) - Modern shell
- [LazyVim](https://www.lazyvim.org/) - Neovim distribution
- [Oh My Zsh](https://ohmyz.sh/) - Git aliases inspiration
- [Catppuccin](https://github.com/catppuccin) - Color themes
- [Nerd Fonts](https://www.nerdfonts.com/) - Icon fonts

---

**Last Updated:** 2026-02-01  
**Branch:** feat/windows-dotfiles-installer  
**Status:** ✅ Feature Complete - Ready for Testing
