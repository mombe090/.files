# Nushell Environment Config File
# Adapted from omerxx/dotfiles for cross-platform use
# version = "0.99.0"

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
    ($nu.data-dir | path join 'completions')
]

# Directories to search for plugin binaries when calling register
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

# =============================================================================
# XDG Base Directory Specification (Cross-Platform)
# =============================================================================

if $nu.os-info.name == 'windows' {
    # Windows: Set XDG paths for cross-platform compatibility
    $env.XDG_CONFIG_HOME = ($env.USERPROFILE | path join ".config")
    $env.XDG_DATA_HOME = ($env.USERPROFILE | path join ".local" "share")
    $env.XDG_CACHE_HOME = ($env.USERPROFILE | path join ".cache")
    $env.XDG_STATE_HOME = ($env.USERPROFILE | path join ".local" "state")
} else {
    # Linux/macOS: Set XDG paths if not already set
    $env.XDG_CONFIG_HOME = ($env.XDG_CONFIG_HOME? | default ($env.HOME | path join ".config"))
    $env.XDG_DATA_HOME = ($env.XDG_DATA_HOME? | default ($env.HOME | path join ".local" "share"))
    $env.XDG_CACHE_HOME = ($env.XDG_CACHE_HOME? | default ($env.HOME | path join ".cache"))
    $env.XDG_STATE_HOME = ($env.XDG_STATE_HOME? | default ($env.HOME | path join ".local" "state"))
}

# Add local bin directories to PATH
use std "path add"

# Platform-specific PATH additions
if $nu.os-info.name == 'windows' {
    # Windows-specific paths
    path add ($env.USERPROFILE | path join ".local" "bin")
    path add ($env.USERPROFILE | path join ".bun" "bin")
    path add ($env.USERPROFILE | path join ".cargo" "bin")
} else if $nu.os-info.name == 'macos' {
    # macOS-specific paths
    path add /opt/homebrew/bin
    path add /opt/homebrew/sbin
    path add ($env.HOME | path join ".local" "bin")
    path add ($env.HOME | path join ".cargo" "bin")
    path add /opt/homebrew/opt/ruby/bin
} else {
    # Linux-specific paths
    path add ($env.HOME | path join ".local" "bin")
    path add ($env.HOME | path join ".cargo" "bin")
}

# =============================================================================
# Starship Prompt Integration
# =============================================================================

# Initialize Starship prompt (cross-platform)
if (which starship | is-not-empty) {
    mkdir ~/.cache/starship
    starship init nu | save -f ~/.cache/starship/init.nu
    
    # Set Starship config location based on platform
    if $nu.os-info.name == 'windows' {
        $env.STARSHIP_CONFIG = ($env.USERPROFILE | path join ".config" "starship" "starship.toml")
    } else {
        $env.STARSHIP_CONFIG = ($env.HOME | path join ".config" "starship" "starship.toml")
    }
}

# =============================================================================
# Tool Initializations
# =============================================================================

# Zoxide (smart cd)
if (which zoxide | is-not-empty) {
    zoxide init nushell | save -f ~/.zoxide.nu
}

# Carapace (completions)
if (which carapace | is-not-empty) {
    mkdir ~/.cache/carapace
    $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
    carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
}

# =============================================================================
# Environment Variables
# =============================================================================

$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

# Disable direnv logging (if installed)
if (which direnv | is-not-empty) {
    $env.DIRENV_LOG_FORMAT = ""
}
