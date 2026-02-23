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

# Kubectx/Kubens completion (fpath completions loaded via ~/.local/share/zsh/completions/)

if command -v kubectx &> /dev/null; then
    compdef kx=kubectx
fi

if command -v kubens &> /dev/null; then
    compdef kn=kubens
fi

# Flux CD completion

if command -v flux &> /dev/null; then
    source <(flux completion zsh)
    compdef _flux flux
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

# Helm completion

if command -v helm &> /dev/null; then
    source <(helm completion zsh)
fi

# K9s completion

if command -v k9s &> /dev/null; then
    source <(k9s completion zsh)
fi

# Kind completion

if command -v kind &> /dev/null; then
    source <(kind completion zsh)
fi

# ArgoCD completion

if command -v argocd &> /dev/null; then
    source <(argocd completion zsh)
fi

# YQ (YAML processor) completion

if command -v yq &> /dev/null; then
    source <(yq shell-completion zsh)
fi

# Terraform-docs completion

if command -v terraform-docs &> /dev/null; then
    source <(terraform-docs completion zsh)
fi


# OpenCode completion

if command -v opencode &> /dev/null; then
    source <(opencode completion)
fi

# ===== ALIAS COMPLETIONS =====

# Terraform aliases (completions provided by carapace)

if command -v terraform &> /dev/null; then
    compdef tf=terraform
fi

# Zellij alias

if command -v zellij &> /dev/null; then
    compdef zj=zellij
fi
