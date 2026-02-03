# External Tools Integration for Nushell
# Manages initialization of starship, carapace, atuin, and zoxide

# =============================================================================
# Starship Prompt
# =============================================================================

export def init_starship [] {
    try {
        if $nu.os-info.name == 'windows' {
            let starship_cache = $"C:/Users/#{USERNAME}#/.cache/starship/init.nu"
            if not ($starship_cache | path exists) {
                mkdir C:/Users/#{USERNAME}#/.cache/starship
                starship init nu | save --force $starship_cache
            }
            source $starship_cache
        } else {
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
            let carapace_cache = $"C:/Users/#{USERNAME}#/.cache/carapace/init.nu"
            if not ($carapace_cache | path exists) {
                mkdir C:/Users/#{USERNAME}#/.cache/carapace
                carapace _carapace nushell | save --force $carapace_cache
            }
            source $carapace_cache
        } else {
            mkdir ~/.cache/carapace
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
            let atuin_cache = $"C:/Users/#{USERNAME}#/.cache/atuin/init.nu"
            if not ($atuin_cache | path exists) {
                mkdir C:/Users/#{USERNAME}#/.cache/atuin
                atuin init nu | save --force $atuin_cache
            }
            source $atuin_cache
        } else {
            mkdir ~/.cache/atuin
            atuin init nu | save --force ~/.cache/atuin/init.nu
            source ~/.cache/atuin/init.nu
        }
    }
}

# =============================================================================
# Zoxide Smart CD
# =============================================================================

export def init_zoxide [] {
    try {
        if $nu.os-info.name == 'windows' {
            let zoxide_cache = $"C:/Users/#{USERNAME}#/.cache/zoxide/init.nu"
            if not ($zoxide_cache | path exists) {
                mkdir C:/Users/#{USERNAME}#/.cache/zoxide
                zoxide init nushell | save --force $zoxide_cache
            }
            source $zoxide_cache
        } else {
            mkdir ~/.cache/zoxide
            zoxide init nushell | save --force ~/.cache/zoxide/init.nu
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
