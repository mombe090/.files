# ===== KEY BINDINGS =====

# Use Vim-style key bindings

bindkey -v

# History search

bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^r' history-incremental-search-backward

# Text manipulation

bindkey '^[w' kill-region
bindkey '^w' backward-kill-word
bindkey '^u' kill-whole-line
bindkey '^k' kill-line

# Navigation

bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey '^f' forward-char
bindkey '^b' backward-char
bindkey '^[f' forward-word
bindkey '^[b' backward-word

# Clear screen

bindkey '^l' clear-screen
