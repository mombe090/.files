#!/usr/bin/env bash
# Audit shell history for potentially leaked secrets
# Part of security improvements from SECURITY-DOTFILES.md

set -e

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Detect history file
detect_history_file() {
    if [[ -n "$ZSH_VERSION" ]]; then
        echo "${HISTFILE:-$HOME/.zsh_history}"
    elif [[ -n "$BASH_VERSION" ]]; then
        echo "${HISTFILE:-$HOME/.bash_history}"
    else
        echo "$HOME/.zsh_history"
    fi
}

HISTFILE=$(detect_history_file)

# Sensitive patterns to search for
PATTERNS=(
    "password"
    "passwd"
    "token"
    "secret"
    "api.key"
    "apikey"
    "bearer"
    "credential"
    "private.key"
    "aws.secret"
    "access.key"
    "client.secret"
)

main() {
    echo ""
    log_info "===== Shell History Security Audit ====="
    echo ""
    log_info "History file: $HISTFILE"
    
    if [[ ! -f "$HISTFILE" ]]; then
        log_error "History file not found: $HISTFILE"
        exit 1
    fi
    
    local total_entries=$(wc -l < "$HISTFILE")
    log_info "Total entries: $total_entries"
    echo ""
    
    # Search for sensitive patterns
    log_step "Scanning for sensitive patterns..."
    echo ""
    
    local found_issues=0
    local total_matches=0
    
    for pattern in "${PATTERNS[@]}"; do
        local matches=$(grep -i "$pattern" "$HISTFILE" 2>/dev/null | wc -l)
        total_matches=$((total_matches + matches))
        
        if [[ $matches -gt 0 ]]; then
            log_warn "Found $matches entries matching: $pattern"
            found_issues=$((found_issues + 1))
        fi
    done
    
    echo ""
    
    if [[ $found_issues -eq 0 ]]; then
        log_info "✓ No sensitive patterns detected in history"
    else
        log_warn "⚠️  Found $total_matches potential security issues across $found_issues patterns"
        echo ""
        log_info "Review your history with:"
        echo "    grep -i 'pattern' $HISTFILE"
        echo ""
        log_info "Clear specific entries with:"
        echo "    sed -i '/pattern/d' $HISTFILE"
        echo ""
        log_info "Or use the clear_history_pattern function (if available)"
    fi
    
    # Check for common leaked secrets
    echo ""
    log_step "Checking for common secret formats..."
    echo ""
    
    # AWS keys
    local aws_keys=$(grep -E 'AKIA[0-9A-Z]{16}' "$HISTFILE" 2>/dev/null | wc -l)
    if [[ $aws_keys -gt 0 ]]; then
        log_error "⚠️  Found $aws_keys potential AWS access keys!"
    fi
    
    # GitHub tokens (classic)
    local gh_tokens=$(grep -E 'ghp_[0-9a-zA-Z]{36}' "$HISTFILE" 2>/dev/null | wc -l)
    if [[ $gh_tokens -gt 0 ]]; then
        log_error "⚠️  Found $gh_tokens potential GitHub tokens!"
    fi
    
    # Generic base64 secrets (long strings)
    local base64_secrets=$(grep -E '[A-Za-z0-9+/]{40,}={0,2}' "$HISTFILE" 2>/dev/null | wc -l)
    if [[ $base64_secrets -gt 0 ]]; then
        log_warn "Found $base64_secrets potential base64-encoded values"
    fi
    
    # Recommendations
    echo ""
    log_step "Security Recommendations:"
    echo ""
    echo "1. Add to your shell config to ignore sensitive commands:"
    echo "   export HISTIGNORE='*password*:*token*:*secret*:*key*'"
    echo ""
    echo "2. Prefix sensitive commands with a space (if HIST_IGNORE_SPACE is set):"
    echo "    export API_KEY=secret123  # Note the leading space"
    echo ""
    echo "3. Clear history periodically or after working with secrets:"
    echo "   history -c  # Clear current session"
    echo "   rm ~/.zsh_history  # Clear all history (drastic)"
    echo ""
    echo "4. Use environment files instead of exporting in shell:"
    echo "   Put secrets in ~/.env or ~/.envrc (gitignored)"
    echo ""
    
    # Create backup before cleanup
    if [[ $total_matches -gt 0 ]]; then
        echo ""
        log_info "To clean history, first create a backup:"
        echo "  cp $HISTFILE ${HISTFILE}.backup.$(date +%Y%m%d-%H%M%S)"
    fi
}

main "$@"
