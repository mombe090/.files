# Nushell Environment Config File
#
# This file sets up the environment for Nushell sessions.
# It runs before config.nu on startup.

# Environment Variables
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

# Prompt configuration
$env.PROMPT_INDICATOR = "〉"
$env.PROMPT_INDICATOR_VI_INSERT = ": "
$env.PROMPT_INDICATOR_VI_NORMAL = "〉"
$env.PROMPT_MULTILINE_INDICATOR = "::: "

# Specifies how environment variables are mapped to Nushell values
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
]

# Directories to search for plugin binaries when calling register
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

# PATH setup
# Add common binary directories to PATH
$env.PATH = (
    $env.PATH
    | split row (char esep)
    | prepend $"($env.HOME)/.local/bin"
    | prepend $"($env.HOME)/.venv/bin"
    | prepend $"($env.HOME)/.bun/bin"
    | prepend $"($env.HOME)/.cargo/bin"
    | uniq
)

# Mise (tool version manager) integration
if (which mise | is-not-empty) {
    $env.PATH = (
        mise activate nu
        | lines
        | where $it starts-with '$env.PATH'
        | first
        | parse '$env.PATH = ({rest})'
        | get rest.0
        | from nuon
    )
}

# Homebrew integration (macOS)
if ($nu.os-info.name == "macos") {
    # Apple Silicon
    if ("/opt/homebrew/bin/brew" | path exists) {
        $env.PATH = ($env.PATH | prepend "/opt/homebrew/bin")
        $env.PATH = ($env.PATH | prepend "/opt/homebrew/sbin")
        $env.HOMEBREW_PREFIX = "/opt/homebrew"
    }
    # Intel
    else if ("/usr/local/bin/brew" | path exists) {
        $env.PATH = ($env.PATH | prepend "/usr/local/bin")
        $env.PATH = ($env.PATH | prepend "/usr/local/sbin")
        $env.HOMEBREW_PREFIX = "/usr/local"
    }
}
