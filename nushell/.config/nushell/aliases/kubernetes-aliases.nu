# Kubernetes Aliases for Nushell

# =============================================================================
# Kubectl Aliases (Oh My Zsh style)
# =============================================================================

export def setup_kubectl_aliases [] {
    if (which kubectl | is-not-empty) {
        alias k = kubectl
        alias ka = kubectl apply -f
        alias kg = kubectl get
        alias kd = kubectl describe
        alias kdel = kubectl delete
        alias kl = kubectl logs -f
        alias kgpo = kubectl get pod
        alias kgd = kubectl get deployments
        alias ke = kubectl exec -it
    }
}

# =============================================================================
# Kubectl Context/Namespace Aliases
# =============================================================================

export def setup_kubectl_context_aliases [] {
    if (which kubectx | is-not-empty) {
        alias kc = kubectx
    }

    if (which kubens | is-not-empty) {
        alias kns = kubens
    }
}
