# ~/.bash_profile - Bash login shell configuration
# Sourced for login shells

# Source .bashrc if it exists
[[ -f ~/.bashrc ]] && source ~/.bashrc

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# XDG Base Directory Specification
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/mombe090/.lmstudio/bin"
# End of LM Studio CLI section

