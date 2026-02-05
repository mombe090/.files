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
unix_scripts := scripts_dir / "unix"
windows_scripts := scripts_dir / "windows"
installers := unix_scripts / "installers"
tools := unix_scripts / "tools"
just_scripts := scripts_dir / "just"

# User home
home := env_var_or_default("HOME", env_var_or_default("USERPROFILE", ""))

# Target directory
config_dir := home / ".config"
stow_target := config_dir

# Colors for output — \u{1b} is the ESC character (U+001B)
color_reset := "\u{1b}[0m"
color_green := "\u{1b}[0;32m"
color_blue := "\u{1b}[0;34m"
color_yellow := "\u{1b}[1;33m"
color_red := "\u{1b}[0;31m"
color_bold := "\u{1b}[1m"

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
