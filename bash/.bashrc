# ~/.bashrc - Bash configuration
# Sourced for interactive non-login shells

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source environment files
[[ -f ~/.env ]] && source ~/.env
[[ -f ~/.envrc ]] && source ~/.envrc

# Activate mise if available
if command -v mise &> /dev/null; then
  eval "$(mise activate bash)"
fi

# Bun (mise-installed bun should be in PATH via mise activation above)
# But also add manual path as fallback
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Load shared shell aliases if they exist
[[ -f ~/.config/shell/aliases.sh ]] && source ~/.config/shell/aliases.sh

# History settings
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# Better bash completion
if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
elif [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
fi

# Catppuccin theme for FZF
[[ -f ~/.config/bash/themes/catppuccin-fzf-mocha.sh ]] && source ~/.config/bash/themes/catppuccin-fzf-mocha.sh

# Starship prompt (if available via mise)
if command -v starship &> /dev/null; then
  # Set shell name for Starship prompt
  export STARSHIP_SHELL="bash"
  eval "$(starship init bash)"
fi

# ===== HOMEBREW CONFIGURATION =====
eval "$(/opt/homebrew/bin/brew shellenv)"

# ===== DOTNET TOOLS =====
export PATH="$PATH:$HOME/.dotnet/tools"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/mombe090/.lmstudio/bin"
# End of LM Studio CLI section

