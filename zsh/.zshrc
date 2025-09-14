autoload -Uz compinit
# ===== ZINIT SETUP =====
# 📁 Set Zinit home directory based on XDG specification
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# 📦 Install Zinit if not already present
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")" && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# 📜 Source Zinit
source "$ZINIT_HOME/zinit.zsh"


# ===== CONFIGURATION LOADING =====
# 📂 Load configuration files in order
typeset -a zsh_configs=(
  ~/.config/zsh/env.zsh
  ~/.config/zsh/history.zsh
  ~/.config/zsh/plugins.zsh
  ~/.config/zsh/Keybindings.zsh
  ~/.config/zsh/aliases.zsh
  ~/.config/zsh/completions.zsh
  ~/.config/zsh/fzf.git.zsh
  ~/.config/zsh/themes/catppuccin-fzf-frappe.sh
)

for config in $zsh_configs; do
  [[ -f "$config" ]] && source "$config"
done

# 🔍 Enable completions and replay zinit
compinit
zinit cdreplay -q

# ===== SHELL INTEGRATIONS =====
# 🔗 Initialize modern shell tools
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(direnv hook zsh)"

# 🛠 User-specific setup
# TODO: add check option if devbox is activated or not here
if [[ "$USER" == "$PERSONAL_USER" ]]; then
  command -v devbox &> /dev/null && eval "$(devbox global shellenv --preserve-path-stack -r)" && hash -r
fi

# Activate vi keybindings
bindkey -v

# ===== PROMPT SETUP =====
# 🎨 Starship prompt
eval "$(starship init zsh)"

# 🎯 Customize the prompt (optional: adds spacing)
PROMPT="${PROMPT}"$'\n\n➡ '
