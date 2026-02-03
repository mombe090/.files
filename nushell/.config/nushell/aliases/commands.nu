    # Nushell Custom Commands and Aliases

# =============================================================================
# Enhanced Commands
# =============================================================================

# Enhanced cd with ls
export def --env cx [arg] {
    cd $arg
    ls -l
}

# =============================================================================
# File Operations Aliases
# =============================================================================

export alias l = ls --all
export alias ll = ls -l
export alias c = clear

# =============================================================================
# Editor Aliases
# =============================================================================

export alias v = nvim

# =============================================================================
# Platform-specific Tree Command
# =============================================================================

export def setup_tree_alias [] {
    if (which eza | is-not-empty) {
        alias lt = eza --tree --level=2 --long --icons --git
    } else if (which tree | is-not-empty) {
        alias lt = tree -L 2
    }
}
