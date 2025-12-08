#!/usr/bin/env bash
# System and application detection utilities

# Check if running on Omarchy
is_omarchy() {
    [[ -f /etc/omarchy-release ]] || \
    [[ -d ~/.local/share/omarchy ]]
}

# Check if package is installed
has_package() {
    pacman -Q "$1" &>/dev/null
}

# Check if config directory exists
has_config() {
    [[ -d "$1" ]]
}

# Check if command is available
has_command() {
    command -v "$1" &>/dev/null
}

# Check if systemd service is enabled
is_service_enabled() {
    systemctl is-enabled "$1" &>/dev/null
}

# Get Omarchy version
get_omarchy_version() {
    if [[ -f /etc/omarchy-release ]]; then
        cat /etc/omarchy-release
    else
        echo "unknown"
    fi
}
