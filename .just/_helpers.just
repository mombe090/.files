# =============================================================================
# _helpers.just - Shared variables and helper functions
# =============================================================================

# OS detection
os_type := os()
is_windows := if os() == "windows" { "true" } else { "false" }
is_macos := if os() == "macos" { "true" } else { "false" }
is_linux := if os() == "linux" { "true" } else { "false" }
is_unix := if os() == "windows" { "false" } else { "true" }

# Paths
dotfiles_root := justfile_directory()
scripts_dir := dotfiles_root / "_scripts"
linux_scripts := scripts_dir / "linux/sh"
windows_scripts := scripts_dir / "windows/pwsh"
installers := linux_scripts / "installers"
tools := linux_scripts / "tools"
just_scripts := scripts_dir / "just"

# User home
home := env_var_or_default("HOME", env_var_or_default("USERPROFILE", ""))

# Target directory
config_dir := home / ".config"
stow_target := config_dir

# Colors for output
color_reset := "\033[0m"
color_green := "\033[0;32m"
color_blue := "\033[0;34m"
color_yellow := "\033[1;33m"
color_red := "\033[0;31m"
color_bold := "\033[1m"

# Helper function to print colored messages
@_log_info msg:
    echo -e "{{color_green}}[INFO]{{color_reset}} {{msg}}"

@_log_step msg:
    echo -e "{{color_blue}}[STEP]{{color_reset}} {{color_bold}}{{msg}}{{color_reset}}"

@_log_warn msg:
    echo -e "{{color_yellow}}[WARN]{{color_reset}} {{msg}}"

@_log_error msg:
    echo -e "{{color_red}}[ERROR]{{color_reset}} {{msg}}"

@_log_success msg:
    echo -e "{{color_green}}[✓]{{color_reset}} {{color_bold}}{{msg}}{{color_reset}}"
