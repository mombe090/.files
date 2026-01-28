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

export PATH="$HOME/.local/bin:$PATH"

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS paths
    export PATH="$PATH:/Applications/IntelliJ IDEA.app/Contents/MacOS"
    
    # Java configuration (macOS)
    if [[ -d "/opt/homebrew/opt/openjdk@21" ]]; then
        export JAVA_HOME=/opt/homebrew/opt/openjdk@21
        export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"
        export MAVEN_OPTS="--add-opens java.base/sun.misc=ALL-UNNAMED"
    fi
    
    # Node.js (use mise or nvm instead of hardcoded path)
    # If you need a specific version, use: mise use -g node@25
    
    # LM Studio CLI
    export PATH="$PATH:$HOME/.lmstudio/bin"
    
elif [[ -n "$WSL_DISTRO_NAME" ]]; then
    # WSL paths
    export PATH="$PATH:$WSL_USER_HOME/AppData/Local/Programs/Microsoft VS Code/bin"
    
    # Java configuration (WSL)
    if [[ -d "/usr/lib/jvm/java-21-openjdk" ]]; then
        export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
        export PATH="$JAVA_HOME/bin:$PATH"
    fi
fi

# Ignore Python Warnings

export PYTHONWARNINGS="ignore::FutureWarning"


