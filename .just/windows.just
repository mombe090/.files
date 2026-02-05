# =============================================================================
# windows.just - Windows-specific recipes
# =============================================================================

# Install packages on Windows
[windows]
win_install_packages TYPE="pro":
    @echo "Installing Windows packages ({{TYPE}})..."
    @pwsh -NoProfile -ExecutionPolicy Bypass -File {{scripts_dir}}/install.ps1 -Type {{TYPE}}

# Install Nerd Fonts on Windows
[windows]
win_install_fonts:
    @echo "Installing modern fonts on Windows..."
    @pwsh -NoProfile -ExecutionPolicy Bypass -File {{windows_scripts}}/Install-ModernFonts.ps1

# Stow package on Windows
[windows]
win_stow PKG:
    @echo "Stowing {{PKG}} on Windows..."
    @pwsh -NoProfile -ExecutionPolicy Bypass -File {{windows_scripts}}/stow.ps1 -Stow {{PKG}}

# Unstow package on Windows
[windows]
win_unstow PKG:
    @echo "Unstowing {{PKG}} on Windows..."
    @pwsh -NoProfile -ExecutionPolicy Bypass -File {{windows_scripts}}/stow.ps1 -Unstow {{PKG}}

# Restow package on Windows
[windows]
win_restow PKG:
    @echo "Restowing {{PKG}} on Windows..."
    @pwsh -NoProfile -ExecutionPolicy Bypass -File {{windows_scripts}}/stow.ps1 -Restow {{PKG}}

# List available packages on Windows
[windows]
win_stow_list:
    @echo "Available stow packages on Windows..."
    @pwsh -NoProfile -ExecutionPolicy Bypass -File {{windows_scripts}}/stow.ps1 -ListPackages

# Setup PowerShell profile
[windows]
win_setup_powershell:
    @echo "Setting up PowerShell profile..."
    @pwsh -NoProfile -ExecutionPolicy Bypass -File {{windows_scripts}}/setup-windows.ps1

# Install JavaScript packages on Windows
[windows]
win_install_js_packages:
    @echo "Installing JavaScript packages on Windows..."
    @pwsh -NoProfile -ExecutionPolicy Bypass -File {{windows_scripts}}/install-js-packages.ps1

# Install LazyVim on Windows
[windows]
win_install_lazyvim:
    @echo "Installing LazyVim on Windows..."
    @pwsh -NoProfile -ExecutionPolicy Bypass -File {{windows_scripts}}/Install-LazyVim.ps1
