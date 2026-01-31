# Nushell Config File
#
# This file configures Nushell behavior and appearance.

# General settings
$env.config = {
    show_banner: false  # Disable startup banner
    
    # Editor settings
    buffer_editor: "nvim"
    
    # Shell behavior
    use_ansi_coloring: true
    edit_mode: vi  # Use vi keybindings (emacs also available)
    shell_integration: {
        osc2: true
        osc7: true
        osc8: true
        osc9_9: false
        osc133: true
        osc633: true
        reset_application_mode: true
    }
    
    # History configuration
    history: {
        max_size: 100_000
        sync_on_enter: true
        file_format: "sqlite"
        isolation: false
    }
    
    # Completions
    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "prefix"
    }
    
    # File size display
    filesize: {
        metric: false
        format: "auto"
    }
    
    # Cursor shape
    cursor_shape: {
        emacs: line
        vi_insert: line
        vi_normal: block
    }
    
    # Color config
    color_config: {
        separator: white
        leading_trailing_space_bg: { attr: n }
        header: green_bold
        empty: blue
        bool: white
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
        shape_filepath: cyan
        shape_flag: blue_bold
        shape_float: purple_bold
        shape_garbage: { fg: white bg: red attr: b }
        shape_globpattern: cyan_bold
        shape_int: purple_bold
        shape_internalcall: cyan_bold
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
    }
    
    # Table display
    table: {
        mode: rounded
        index_mode: auto
        show_empty: true
        trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
            truncating_suffix: "..."
        }
    }
    
    # Error handling
    error_style: "fancy"
    
    # Date format
    datetime_format: {
        normal: "%Y-%m-%d %H:%M:%S"
        table: "%Y-%m-%d %H:%M:%S"
    }
    
    # Explore settings
    explore: {
        status_bar_background: { fg: "#1D1F21", bg: "#C4C9C6" }
        command_bar_text: { fg: "#C4C9C6" }
        highlight: { fg: "black", bg: "yellow" }
        status: {
            error: { fg: "white", bg: "red" }
            warn: {}
            info: {}
        }
        table: {
            split_line: { fg: "#404040" }
            selected_cell: { bg: light_blue }
            selected_row: {}
            selected_column: {}
        }
    }
    
    # Hooks (can be customized later)
    hooks: {
        pre_prompt: [{ null }]
        pre_execution: [{ null }]
        env_change: {
            PWD: [{|before, after| null }]
        }
        display_output: "if (term size).columns >= 100 { table -e } else { table }"
        command_not_found: { null }
    }
    
    # Keybindings
    keybindings: [
        {
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: completion_menu }
                    { send: menunext }
                    { edit: complete }
                ]
            }
        }
        {
            name: history_menu
            modifier: control
            keycode: char_r
            mode: [vi_insert vi_normal]
            event: { send: menu name: history_menu }
        }
        {
            name: clear_screen
            modifier: control
            keycode: char_l
            mode: [vi_insert vi_normal]
            event: { send: clearscrollback }
        }
    ]
    
    # Menus
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
                selected_text: green_reverse
                description_text: yellow
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
    ]
}

# ===== Aliases =====
# Basic commands
alias ll = ls -l
alias la = ls -a
alias lla = ls -la

# Git aliases (if git is available)
alias g = git
alias gs = git status
alias ga = git add
alias gc = git commit
alias gp = git push
alias gl = git pull
alias gd = git diff
alias gco = git checkout
alias gb = git branch

# Directory navigation
alias .. = cd ..
alias ... = cd ../..
alias .... = cd ../../..

# Modern tool replacements (if available)
alias cat = if (which bat | is-not-empty) { bat } else { cat }
alias ls = if (which eza | is-not-empty) { eza --icons } else { ls }

# ===== Custom Commands =====
# Quick directory jump to dotfiles
def dotfiles [] {
    cd ~/.files
}

# Quick edit of Nushell config
def nu-config [] {
    $env.EDITOR ~/.config/nushell/config.nu
}

def nu-env [] {
    $env.EDITOR ~/.config/nushell/env.nu
}

# Reload Nushell config
def nu-reload [] {
    source ~/.config/nushell/env.nu
    source ~/.config/nushell/config.nu
    print "Nushell configuration reloaded"
}
