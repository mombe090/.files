# History

HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Load security functions for history management
# Provides: clear_history_pattern, secure, history_off, history_on
[[ -f ~/.config/zsh/security/history-security.zsh ]] && source ~/.config/zsh/security/history-security.zsh
