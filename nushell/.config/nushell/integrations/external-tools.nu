# External Tools Integration for Nushell
# Manages initialization of starship, carapace, atuin, and zoxide
#
# Note: nushell's `source` only accepts bare literal paths at parse time —
# no variables, no string interpolation.  nushell parses every branch of an
# if/else regardless of which one runs, so any `source $dynamic` anywhere
# in the file will fail.  Windows support with dynamic USERNAME paths is not
# possible in a single file; use a dedicated Windows config if needed.

# =============================================================================
# Starship Prompt
# =============================================================================

export def init_starship [] {
    try {
        if (which starship | is-not-empty) {
            if not ("~/.cache/starship/init.nu" | path exists) {
                mkdir --full-path ~/.cache/starship
                starship init nu | save --force ~/.cache/starship/init.nu
            }
            source ~/.cache/starship/init.nu
        }
    }
}

# =============================================================================
# Carapace Completions
# =============================================================================

export def init_carapace [] {
    try {
        if (which carapace | is-not-empty) {
            mkdir --full-path ~/.cache/carapace
            carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
            source ~/.cache/carapace/init.nu
        }
    }
}

# =============================================================================
# Atuin Shell History
# =============================================================================

export def init_atuin [] {
    try {
        if (which atuin | is-not-empty) {
            if not ("~/.local/share/atuin/init.nu" | path exists) {
                atuin init nu | save --force ~/.local/share/atuin/init.nu
            }
            source ~/.local/share/atuin/init.nu
        }
    }
}

# =============================================================================
# Zoxide Smart CD
# =============================================================================

export def init_zoxide [] {
    try {
        if (which zoxide | is-not-empty) {
            if not ("~/.cache/zoxide/init.nu" | path exists) {
                mkdir --full-path ~/.cache/zoxide
                zoxide init nushell | save --force ~/.cache/zoxide/init.nu
            }
            source ~/.cache/zoxide/init.nu
        }
    }
}

# =============================================================================
# Initialize All External Tools
# =============================================================================

export def init_all [] {
    init_starship
    init_carapace
    init_atuin
    init_zoxide
}
