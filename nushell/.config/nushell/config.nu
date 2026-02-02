# Nushell Config File
# Adapted from omerxx/dotfiles for cross-platform use
# version = "0.99.0"

# =============================================================================
# Theme Configuration
# =============================================================================

let dark_theme = {
    separator: white
    leading_trailing_space_bg: { attr: n }
    header: green_bold
    empty: blue
    bool: light_cyan
    int: white
    filesize: cyan
    duration: white
    date: purple
    range: white
    float: white
    string: white
    nothing: white
    binary: white
    cell-path: white
    row_index: green_bold
    record: white
    list: white
    block: white
    hints: dark_gray
    search_result: { bg: red fg: white }
    
    # Syntax highlighting
    shape_and: purple_bold
    shape_binary: purple_bold
    shape_block: blue_bold
    shape_bool: light_cyan
    shape_closure: green_bold
    shape_custom: green
    shape_datetime: cyan_bold
    shape_directory: cyan
    shape_external: cyan
    shape_externalarg: green_bold
    shape_external_resolved: light_yellow_bold
    shape_filepath: cyan
    shape_flag: blue_bold
    shape_float: purple_bold
    shape_garbage: { fg: white bg: red attr: b}
    shape_glob_interpolation: cyan_bold
    shape_globpattern: cyan_bold
    shape_int: purple_bold
    shape_internalcall: cyan_bold
    shape_keyword: cyan_bold
    shape_list: cyan_bold
    shape_literal: blue
    shape_match_pattern: green
    shape_matching_brackets: { attr: u }
    shape_nothing: light_cyan
    shape_operator: yellow
    shape_or: purple_bold
    shape_pipe: purple_bold
    shape_range: yellow_bold
    shape_record: cyan_bold
    shape_redirection: purple_bold
    shape_signature: green_bold
    shape_string: green
    shape_string_interpolation: cyan_bold
    shape_table: blue_bold
    shape_variable: purple
    shape_vardecl: purple
    shape_raw_string: light_purple
}

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
    
    filesize: {
        metric: false
        format: "auto"
    }
    
    cursor_shape: {
        emacs: block
        vi_insert: block
        vi_normal: underscore
    }
    
    color_config: $dark_theme
    use_grid_icons: true
    footer_mode: "25"
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
    
    hooks: {
        pre_prompt: [{||
            # Direnv integration (if installed)
            if (which direnv | is-empty) {
                return
            }
            try {
                direnv export json | from json | default {} | load-env
                if 'PATH' in $env {
                    $env.PATH = ($env.PATH | split row (char esep))
                }
            } catch {}
        }]
        pre_execution: [{ null }]
        env_change: {
            PWD: [{|before, after| null }]
        }
        display_output: "if (term size).columns >= 100 { table -e } else { table }"
        command_not_found: { null }
    }
    
    menus: [
        {
            name: completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
                layout: columnar
                columns: 4
                col_width: 20
                col_padding: 2
            }
            style: {
                text: green
                selected_text: { attr: r }
                description_text: yellow
                match_text: { attr: u }
                selected_match_text: { attr: ur }
            }
        }
        {
            name: ide_completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
                layout: ide
                min_completion_width: 0
                max_completion_width: 50
                max_completion_height: 10
                padding: 0
                border: true
                cursor_offset: 0
                description_mode: "prefer_right"
                min_description_width: 0
                max_description_width: 50
                max_description_height: 10
                description_offset: 1
                correct_cursor_pos: false
            }
            style: {
                text: green
                selected_text: { attr: r }
                description_text: yellow
                match_text: { attr: u }
                selected_match_text: { attr: ur }
            }
        }
        {
            name: history_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: list
                page_size: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
        {
            name: help_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: description
                columns: 4
                col_width: 20
                col_padding: 2
                selection_rows: 4
                description_rows: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
    ]
    
    keybindings: [
        {
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: completion_menu }
                    { send: menunext }
                    { edit: complete }
                ]
            }
        }
        {
            name: ide_completion_menu
            modifier: control
            keycode: char_n
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: ide_completion_menu }
                    { send: menunext }
                    { edit: complete }
                ]
            }
        }
        {
            name: history_menu
            modifier: control
            keycode: char_r
            mode: [emacs, vi_insert, vi_normal]
            event: { send: menu name: history_menu }
        }
        {
            name: help_menu
            modifier: none
            keycode: f1
            mode: [emacs, vi_insert, vi_normal]
            event: { send: menu name: help_menu }
        }
        {
            name: cancel_command
            modifier: control
            keycode: char_c
            mode: [emacs, vi_normal, vi_insert]
            event: { send: ctrlc }
        }
        {
            name: quit_shell
            modifier: control
            keycode: char_d
            mode: [emacs, vi_normal, vi_insert]
            event: { send: ctrld }
        }
        {
            name: clear_screen
            modifier: control
            keycode: char_l
            mode: [emacs, vi_normal, vi_insert]
            event: { send: clearscreen }
        }
    ]
}

# =============================================================================
# Custom Commands & Aliases
# =============================================================================

# Enhanced cd with ls
def --env cx [arg] {
    cd $arg
    ls -l
}

# File operations
alias l = ls --all
alias ll = ls -l
alias c = clear

# Editor
alias v = nvim

# Git aliases (Oh My Zsh style)
source ~/.config/nushell/git-aliases.nu

# Kubernetes aliases (if kubectl is installed)
if (which kubectl | is-not-empty) {
    alias k = kubectl
    alias ka = kubectl apply -f
    alias kg = kubectl get
    alias kd = kubectl describe
    alias kdel = kubectl delete
    alias kl = kubectl logs -f
    alias kgpo = kubectl get pod
    alias kgd = kubectl get deployments
    alias ke = kubectl exec -it
}

# Kubectl context/namespace (if installed)
if (which kubectx | is-not-empty) {
    alias kc = kubectx
}

if (which kubens | is-not-empty) {
    alias kns = kubens
}

# Platform-specific tree command
if (which eza | is-not-empty) {
    alias lt = eza --tree --level=2 --long --icons --git
} else if (which tree | is-not-empty) {
    alias lt = tree -L 2
}

# =============================================================================
# Source External Configurations
# =============================================================================

# Load environment config
source ~/.config/nushell/env.nu

# Load Starship prompt (if initialized)
if ('~/.cache/starship/init.nu' | path exists) {
    source ~/.cache/starship/init.nu
}

# Load Zoxide (if initialized)
if ('~/.zoxide.nu' | path exists) {
    source ~/.zoxide.nu
}

# Load Carapace completions (if initialized)
if ('~/.cache/carapace/init.nu' | path exists) {
    source ~/.cache/carapace/init.nu
}

# Load Atuin history (if initialized)
if ('~/.local/share/atuin/init.nu' | path exists) {
    source ~/.local/share/atuin/init.nu
}
