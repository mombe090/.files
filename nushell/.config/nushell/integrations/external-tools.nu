# External Tools Integration for Nushell
# Manages initialization of starship, carapace, atuin, and zoxide
#
# NOTE: This module only provides helper functions to generate cache files.
# The actual sourcing must happen in config.nu using 'try { source ... }'
# because 'source' is evaluated at parse-time and files may not exist yet.

# =============================================================================
# Generate Starship Cache
# =============================================================================

export def init_starship [] {
    if not ('~/.cache/starship/init.nu' | path exists) {
        mkdir ~/.cache/starship
        starship init nu | save --force ~/.cache/starship/init.nu
    }
}

# =============================================================================
# Generate Carapace Cache
# =============================================================================

export def init_carapace [] {
    if not ('~/.cache/carapace/init.nu' | path exists) {
        mkdir ~/.cache/carapace
        carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
    }
}

# =============================================================================
# Generate Atuin Cache
# =============================================================================

export def init_atuin [] {
    if not ('~/.local/share/atuin/init.nu' | path exists) {
        mkdir ~/.local/share/atuin
        atuin init nu | save --force ~/.local/share/atuin/init.nu
    }
}

# =============================================================================
# Generate Zoxide Cache
# =============================================================================

export def init_zoxide [] {
    if not ('~/.cache/zoxide/init.nu' | path exists) {
        mkdir ~/.cache/zoxide
        zoxide init nushell | save --force ~/.cache/zoxide/init.nu
    }
}

# =============================================================================
# Initialize All External Tools
# =============================================================================

export def init_all [] {
    init_starship
    init_carapace
    init_atuin
    # Don't init zoxide - we use custom integration to avoid export-env conflicts
    # init_zoxide
}
