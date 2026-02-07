# CARAPACE CONFIGURATION

export CARAPACE_BRIDGES='zsh,bash,inshellisense'

# ===== BASIC COMPLETION SETUP =====

# Add system completion directories to fpath FIRST

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS paths
    fpath=(
        /opt/homebrew/share/zsh/site-functions
        /usr/share/zsh/5.9/functions
        ~/.local/share/zsh/completions
        $fpath
    )
else
    # Linux paths
    fpath=(
        /usr/share/zsh/functions/Completion/Unix
        /usr/share/zsh/functions/Completion/Base
        /usr/share/zsh/functions/Completion/Linux
        /usr/share/zsh/functions/Completion/Zsh
        ~/.local/share/zsh/completions
        $fpath
    )
fi

# ===== LOAD COMPLETION DEFINITIONS (BEFORE compinit) =====

# Load standard completion functions

autoload -Uz _files_complete _match_approximate _path_files _directories

# ===== COMPLETION STYLING =====

zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Enable file completion

zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Directory navigation

zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' squeeze-slashes true

# File and directory completion behavior

zstyle ':completion:*' file-sort modification
zstyle ':completion:*' special-dirs true

# Git completion grouping

zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'

# ===== FZF-TAB CONFIGURATION =====

# Disable default zsh menu and use fzf-tab instead

zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' continuous-trigger '/'

# Configure file/directory previews with fallbacks

zstyle ':fzf-tab:complete:cd:*' fzf-preview '[[ -d $realpath ]] && { ls --color=always $realpath 2>/dev/null || ls $realpath }'
zstyle ':fzf-tab:complete:ls:*' fzf-preview '[[ -f $realpath ]] && { cat $realpath 2>/dev/null | head -50 } || [[ -d $realpath ]] && { ls --color=always $realpath 2>/dev/null || ls $realpath }'

# Configure generic file preview

zstyle ':fzf-tab:complete:*:*' fzf-preview 'if [[ -d $realpath ]]; then
    ls --color=always $realpath 2>/dev/null || ls $realpath
elif [[ -f $realpath ]]; then
    cat $realpath 2>/dev/null | head -50
fi'

# Configure fzf-tab appearance

zstyle ':fzf-tab:*' fzf-bindings 'ctrl-j:accept,ctrl-k:kill-line,ctrl-alt-j:preview-down,ctrl-alt-k:preview-up'
zstyle ':fzf-tab:*' fzf-flags '--height=80%' '--preview-window=right:50%' '--bind=tab:down,shift-tab:up'

# ===== INTEGRATIONS =====

# AWS KIRO INTEGRATION

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
