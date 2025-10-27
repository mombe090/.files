# ===== POST-COMPINIT COMPLETIONS =====

# These completions must be loaded AFTER compinit has been called

# because they use 'compdef' which requires the completion system to be initialized

# Kubectl completion

if command -v kubectl &> /dev/null; then
    # Get the actual kubectl binary path (not the alias)
    local kubectl_bin=$(whence -p kubectl)

    # Load kubectl completion from the actual binary
    source <($kubectl_bin completion zsh)

    # If kubecolor is installed, copy kubectl completion to it and common aliases
    if command -v kubecolor &> /dev/null; then
        compdef kubecolor=kubectl
        compdef k=kubectl
        compdef kubeclt=kubectl  # Typo alias
    fi
fi

# Azure CLI completion

# Requires: python3-argcomplete (install with: sudo pacman -S python-argcomplete)

if command -v az &> /dev/null && command -v register-python-argcomplete &> /dev/null; then
    # Use native Zsh completion via argcomplete
    eval "$(register-python-argcomplete az)"
fi

# Initialize carapace completion definitions

if command -v carapace &> /dev/null; then
    source <(carapace _carapace)
fi
