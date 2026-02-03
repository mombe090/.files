# Nushell Config File
# version = "0.99.0"
# Modular configuration - organized by functionality

# =============================================================================
# Import Modules
# =============================================================================

# UI Components
use ~/.config/nushell/ui/theme.nu
use ~/.config/nushell/ui/menus.nu
use ~/.config/nushell/ui/keybindings.nu

# Core Configuration
use ~/.config/nushell/core/hooks.nu

# Commands & Aliases
use ~/.config/nushell/aliases/commands.nu *
use ~/.config/nushell/aliases/git-aliases.nu *
use ~/.config/nushell/aliases/kubernetes-aliases.nu *

# External Integrations
use ~/.config/nushell/integrations/external-tools.nu *

# =============================================================================
# Main Configuration
# =============================================================================

$env.config = {
    show_banner: false
    
    ls: {
        use_ls_colors: true
        clickable_links: true
    }
    
    rm: {
        always_trash: false
    }
    
    table: {
        mode: rounded
        index_mode: always
        show_empty: true
        padding: { left: 1, right: 1 }
        trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
            truncating_suffix: "..."
        }
        header_on_separator: false
    }
    
    error_style: "fancy"
    
    datetime_format: {
        # normal: '%a, %d %b %Y %H:%M:%S %z'
        # table: '%m/%d/%y %I:%M:%S%p'
    }
    
    explore: {
        status_bar_background: { fg: "#1D1F21", bg: "#C4C9C6" }
        command_bar_text: { fg: "#C4C9C6" }
        highlight: { fg: "black", bg: "yellow" }
        status: {
            error: { fg: "white", bg: "red" }
            warn: {}
            info: {}
        }
        selected_cell: { bg: light_blue }
    }
    
    history: {
        max_size: 100_000
        sync_on_enter: true
        file_format: "plaintext"
        isolation: false
    }
    
    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "prefix"
        external: {
            enable: true
            max_results: 100
            completer: null
        }
        use_ls_colors: true
    }

    cursor_shape: {
        emacs: block
        vi_insert: block
        vi_normal: underscore
    }
    
    color_config: (theme dark_theme)
    footer_mode: 25
    float_precision: 2
    buffer_editor: ""
    use_ansi_coloring: true
    bracketed_paste: true
    edit_mode: vi
    
    shell_integration: {
        osc2: true
        osc7: true
        osc8: true
        osc9_9: false
        osc133: true
        osc633: true
        reset_application_mode: true
    }
    
    render_right_prompt_on_last_line: false
    use_kitty_protocol: false
    highlight_resolved_externals: false
    recursion_limit: 50
    
    plugins: {}
    
    plugin_gc: {
        default: {
            enabled: true
            stop_after: 10sec
        }
        plugins: {}
    }
    
    hooks: (hooks hooks)
    menus: (menus menus)
    keybindings: (keybindings keybindings)
}

# =============================================================================
# Initialize External Tools & Aliases
# =============================================================================

# Initialize external tools (starship, carapace, atuin, zoxide)
init_all

# Setup tree alias
setup_tree_alias

# Setup kubernetes aliases
setup_kubectl_aliases
setup_kubectl_context_aliases
