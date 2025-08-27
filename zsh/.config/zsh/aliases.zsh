# ===== CORE TOOL REPLACEMENTS =====
alias vim='nvim'
alias cat='bat'

# OS-specific aliases
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias python='python3'
    alias code="open -a 'Visual Studio Code'"
fi

# ===== MODERN LS REPLACEMENT (EZA) =====
# Eza is a modern replacement for ls - find more at https://eza.rocks/
alias ls='eza --icons --color=always --group-directories-first --time-style=long-iso -l'
alias ll='eza --icons --color=always --group-directories-first --time-style=long-iso -l'
alias lla='eza --icons --color=always --group-directories-first --time-style=long-iso -la'
alias la='eza --icons --color=always --group-directories-first --time-style=long-iso -a'
alias lt='eza --icons --color=always --group-directories-first --time-style=long-iso --tree'

# ===== GIT ALIASES =====
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gca='git commit --amend'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gpa='git push origin --all'
alias gp='git push origin'
alias gp='git push'
alias gl='git pull'
alias gst='git status'
alias gb='git branch'
alias gd='git diff'
alias glg='git log --oneline --graph'

# ===== KUBERNETES ALIASES =====
# Context and namespace management
alias kn='kubens'
alias kx='kubectx'

# Kubecolor (kubectl with colors)
alias kubectl='kubecolor'
alias kubeclt='kubecolor'  # Keep typo alias for muscle memory
alias k='kubecolor'

# Basic kubectl operations
alias kg='kubecolor get'
alias kgp='kubecolor get pods'
alias kgd='kubecolor get deploy'
alias kgs='kubecolor get svc'
alias kgn='kubecolor get ns'
alias kd='kubecolor describe'
alias kdel='kubecolor delete'

# Apply and create
alias kaf='kubecolor apply -f'
alias kak='kubecolor apply -k'

# Logs
alias klogs='kubecolor logs'
alias klogsf='kubecolor logs -f'

# ===== FLUX CD ALIASES =====
alias frk='flux reconcile ks'
alias frh='flux reconcile hr'
alias fget='flux get'

# ===== INFRA TOOLS =====
# Ansible
alias an='ansible'
alias ap='ansible-playbook'
alias av='ansible-vault'

# Terraform
alias tf='terraform'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfmt='terraform fmt -recursive'
alias tfnc='terraform init -configure=false'
alias tfi='terraform init'
alias tfv='terraform validate'

# Other development tools
alias q='quarkus'
alias zj='zellij'
alias lc='localstack'

# ===== SYSTEM SPECIFIC =====
# Nix Darwin
alias nix-rebuild-mac='sudo darwin-rebuild switch --flake ~/.config/nix#'

# ===== NAVIGATION HELPERS =====
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# ===== PROCESS MANAGEMENT =====
alias psg='ps aux | grep'
alias h='history'
alias j='jobs -l'
alias b='btop'
