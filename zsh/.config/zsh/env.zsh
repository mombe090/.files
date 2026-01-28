# Source environment files safely

[[ -f ~/.env ]] && source ~/.env
[[ -f ~/.envrc ]] && source ~/.envrc

# System environment fixes

export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# XDG Base Directory Specification

export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# CARAPACE CONFIGURATION

export CARAPACE_BRIDGES='zsh,bash,inshellisense'
export LS_COLORS="$(vivid generate catppuccin-frappe)"

# Development tools

export KUBE_EDITOR=nvim
export TALOS_EDITOR=nvim
export K9S_CONFIG_DIR=~/.config/k9s
export LOCALSTACK_ACTIVATE_PRO=0

# Path additions (OS-specific)

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS paths
    export PATH="$PATH:/Applications/IntelliJ IDEA.app/Contents/MacOS"
elif [[ -n "$WSL_DISTRO_NAME" ]]; then
    # WSL paths
    export PATH="$PATH:$WSL_USER_HOME/AppData/Local/Programs/Microsoft VS Code/bin"
fi

# Ignore Python Warnings

export PYTHONWARNINGS="ignore::FutureWarning"

export PATH="$HOME/.local/bin:$PATH"

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS paths
    export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"
    export JAVA_HOME=/opt/homebrew/opt/openjdk@21

    export MAVEN_OPTS="--add-opens java.base/sun.misc=ALL-UNNAMED"
    export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"
    export JAVA_HOME=/opt/homebrew/opt/openjdk@21
    export PATH="/opt/homebrew/Cellar/node/25.2.1/bin:$PATH"

    # Added by LM Studio CLI (lms)

    export PATH="$PATH:$HOME/.lmstudio/bin"

    # End of LM Studio CLI section
elif [[ -n "$WSL_DISTRO_NAME" ]]; then
    export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
    export PATH="$JAVA_HOME/bin:$PATH"

    # WSL paths
    export PATH="$PATH:$WSL_USER_HOME/AppData/Local/Programs/Microsoft VS Code/bin"
fi


