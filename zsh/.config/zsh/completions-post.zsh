# ===== POST-COMPINIT COMPLETIONS =====
# These completions must be loaded AFTER compinit has been called
# because they use 'compdef' which requires the completion system to be initialized

# Kubectl completion
if command -v kubectl &> /dev/null; then
    source <(kubectl completion zsh)
    if command -v kubecolor &> /dev/null; then
        compdef kubecolor=kubectl
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
