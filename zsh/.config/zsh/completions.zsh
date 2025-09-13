# CARAPACE CONFIGURATION
export CARAPACE_BRIDGES='zsh,bash,inshellisense'
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)

zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'



# ===== COMPLETION STYLING =====
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# ===== FZF-TAB CONFIGURATION =====
# Use eza instead of ls for better previews
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color=always $realpath'

# ===== TOOL-SPECIFIC COMPLETIONS =====
# Carapace completion
if command -v carapace &> /dev/null; then
    source <(carapace _carapace)
fi

# Kubectl completion
if command -v kubectl &> /dev/null; then
    source <(kubectl completion zsh)
    if command -v kubecolor &> /dev/null; then
        compdef kubecolor=kubectl
    fi
fi

# AWS KIRO INTEGRATION
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
