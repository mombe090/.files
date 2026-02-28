# Shell History Security Functions
# Source this file to add security features to your shell history
# Part of security improvements from SECURITY-DOTFILES.md

# Function to clear history entries matching a pattern
clear_history_pattern() {
    local pattern="$1"
    local histfile="${HISTFILE:-$HOME/.zsh_history}"
    
    if [[ -z "$pattern" ]]; then
        echo "Usage: clear_history_pattern <pattern>"
        echo "Example: clear_history_pattern 'password123'"
        return 1
    fi
    
    # Backup history
    local backup="${histfile}.backup.$(date +%Y%m%d-%H%M%S)"
    cp "$histfile" "$backup"
    echo "✓ Backup created: $backup"
    
    # Remove lines matching pattern
    local before=$(wc -l < "$histfile")
    grep -v "$pattern" "$histfile" > "${histfile}.tmp"
    mv "${histfile}.tmp" "$histfile"
    local after=$(wc -l < "$histfile")
    local removed=$((before - after))
    
    # Reload history (shell-specific)
    if [[ -n "$ZSH_VERSION" ]]; then
        fc -R
    elif [[ -n "$BASH_VERSION" ]]; then
        history -r
    fi
    
    echo "✓ Removed $removed entries matching: $pattern"
    echo "  Backup available at: $backup"
}

# Function to run a command without saving to history
secure() {
    local HISTFILE=/dev/null
    "$@"
}

# Function to temporarily disable history
history_off() {
    if [[ -n "$ZSH_VERSION" ]]; then
        unsetopt HIST_SAVE_NO_DUPS
        unsetopt INC_APPEND_HISTORY
    elif [[ -n "$BASH_VERSION" ]]; then
        set +o history
    fi
    echo "⚠️  History disabled for this session"
    echo "   Run 'history_on' to re-enable"
}

# Function to re-enable history
history_on() {
    if [[ -n "$ZSH_VERSION" ]]; then
        setopt HIST_SAVE_NO_DUPS
        setopt INC_APPEND_HISTORY
    elif [[ -n "$BASH_VERSION" ]]; then
        set -o history
    fi
    echo "✓ History re-enabled"
}

# Export functions (bash)
if [[ -n "$BASH_VERSION" ]]; then
    export -f clear_history_pattern
    export -f secure
    export -f history_off
    export -f history_on
fi
