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
        bash {{tools}}/manage-stow.sh stow
    else
        echo -e "{{color_blue}}[STEP]{{color_reset}} Stowing {{PKG}}..."
        bash {{tools}}/manage-stow.sh stow {{PKG}}
    fi

# Unstow package(s) - remove symlinks
[unix]
unstow PKG="":
    #!/usr/bin/env bash
    set -euo pipefail

    if [ -z "{{PKG}}" ]; then
        echo -e "{{color_blue}}[STEP]{{color_reset}} Unstowing all packages..."
        bash {{tools}}/manage-stow.sh unstow
    else
        echo -e "{{color_blue}}[STEP]{{color_reset}} Unstowing {{PKG}}..."
        bash {{tools}}/manage-stow.sh unstow {{PKG}}
    fi

# Restow package(s) - update symlinks
[unix]
restow PKG="":
    #!/usr/bin/env bash
    set -euo pipefail

    if [ -z "{{PKG}}" ]; then
        echo -e "{{color_blue}}[STEP]{{color_reset}} Restowing all packages..."
        bash {{tools}}/manage-stow.sh restow
    else
        echo -e "{{color_blue}}[STEP]{{color_reset}} Restowing {{PKG}}..."
        bash {{tools}}/manage-stow.sh restow {{PKG}}
    fi
