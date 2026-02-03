# External Tools Integration for Nushell
# Manages initialization of starship, carapace, atuin, and zoxide
#
# Windows paths contain #{USERNAME}# tokens — replaced at deploy time by
# `task replacetokens` (see Taskfile.yml).  After replacement the paths become
# bare literals, which is what nushell's `source` requires.  Do NOT wrap them
# in $"..." — that makes them string interpolations and breaks the parser.

# =============================================================================
# Starship Prompt
# =============================================================================

export def init_starship [] {
    try {
        if $nu.os-info.name == 'windows' {
            if not (C:/Users/#{USERNAME}#/.cache/starship/init.nu | path exists) {
                mkdir --full-path C:/Users/#{USERNAME}#/.cache/starship
                starship init nu | save --force C:/Users/#{USERNAME}#/.cache/starship/init.nu
            }
            source C:/Users/#{USERNAME}#/.cache/starship/init.nu
        } else {
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
        if $nu.os-info.name == 'windows' {
            mkdir --full-path C:/Users/#{USERNAME}#/.cache/carapace
            carapace _carapace nushell | save --force C:/Users/#{USERNAME}#/.cache/carapace/init.nu
            source C:/Users/#{USERNAME}#/.cache/carapace/init.nu
        } else {
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
        if $nu.os-info.name == 'windows' {
            if not (C:/Users/#{USERNAME}#/.cache/atuin/init.nu | path exists) {
                atuin init nu | save --force C:/Users/#{USERNAME}#/.cache/atuin/init.nu
            }
            source C:/Users/#{USERNAME}#/.cache/atuin/init.nu
        } else {
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
        if $nu.os-info.name == 'windows' {
            if not (C:/Users/#{USERNAME}#/.cache/zoxide/init.nu | path exists) {
                mkdir --full-path C:/Users/#{USERNAME}#/.cache/zoxide
                zoxide init nushell | save --force C:/Users/#{USERNAME}#/.cache/zoxide/init.nu
            }
            source C:/Users/#{USERNAME}#/.cache/zoxide/init.nu
        } else {
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
