# =============================================================================
# stow.just - Symlink management recipes
# =============================================================================

# Stow package(s) - create symlinks
[unix]
stow PKG="":
    #!/usr/bin/env bash
    set -euo pipefail

    if [ -z "{{PKG}}" ]; then
        echo -e "{{color_blue}}[STEP]{{color_reset}} Stowing all packages..."
        {{tools}}/manage-stow.sh stow
    else
        echo -e "{{color_blue}}[STEP]{{color_reset}} Stowing {{PKG}}..."
        {{tools}}/manage-stow.sh stow {{PKG}}
    fi

# Unstow package(s) - remove symlinks
[unix]
unstow PKG="":
    #!/usr/bin/env bash
    set -euo pipefail

    if [ -z "{{PKG}}" ]; then
        echo -e "{{color_blue}}[STEP]{{color_reset}} Unstowing all packages..."
        {{tools}}/manage-stow.sh unstow
    else
        echo -e "{{color_blue}}[STEP]{{color_reset}} Unstowing {{PKG}}..."
        {{tools}}/manage-stow.sh unstow {{PKG}}
    fi

# Restow package(s) - update symlinks
[unix]
restow PKG="":
    #!/usr/bin/env bash
    set -euo pipefail

    if [ -z "{{PKG}}" ]; then
        echo -e "{{color_blue}}[STEP]{{color_reset}} Restowing all packages..."
        {{tools}}/manage-stow.sh restow
    else
        echo -e "{{color_blue}}[STEP]{{color_reset}} Restowing {{PKG}}..."
        {{tools}}/manage-stow.sh restow {{PKG}}
    fi

# List available packages
[unix]
stow_list:
    @just _log_step "Available stow packages:"
    @{{tools}}/manage-stow.sh status

# Show stow status
[unix]
stow_status:
    @just _log_step "Stow status:"
    @{{tools}}/manage-stow.sh status
