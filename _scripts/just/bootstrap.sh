#!/usr/bin/env bash
# Bootstrap script - Install just and set up dotfiles
set -e

# Ensure HOME points to the actual current user (fixes stale HOME after su)
REAL_HOME=$(getent passwd "$(whoami)" | cut -d: -f6)
if [[ "$HOME" != "$REAL_HOME" ]]; then
    echo "[WARN] HOME was $HOME, correcting to $REAL_HOME"
    export HOME="$REAL_HOME"
fi

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPTS_DIR="$DOTFILES_ROOT/_scripts"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} ${BOLD}$1${NC}"; }
log_success() { echo -e "${GREEN}[✓]${NC} ${BOLD}$1${NC}"; }

echo ""
echo -e "${BOLD}==================================${NC}"
echo -e "${BOLD}   Dotfiles Bootstrap${NC}"
echo -e "${BOLD}==================================${NC}"
echo ""

# Step 1: Install just
log_step "1. Installing just command runner..."
if bash "$SCRIPTS_DIR/just/install-just.sh"; then
    log_success "just installed"
else
    echo ""
    log_info "Please install just manually and re-run this script"
    exit 1
fi

# Step 2: Verify just is in PATH
echo ""
log_step "2. Verifying just installation..."
if command -v just &> /dev/null; then
    log_success "just is available: $(just --version)"
else
    echo ""
    log_info "just installed but not in PATH yet"
    log_info "Please restart your shell or source your RC file:"
    echo "    source ~/.zshrc"
    echo ""
    log_info "Then run: just --list"
    exit 0
fi

# Step 3: Show next steps
echo ""
log_step "3. Bootstrap complete!"
echo ""
log_success "You can now use just to manage your dotfiles"
echo ""
echo -e "Next steps:"
echo ""
echo -e "  1. See available commands:"
echo -e "     ${BOLD}just --list${NC}"
echo ""
echo -e "  2. Install dotfiles (full):"
echo -e "     ${BOLD}just install_full${NC}"
echo ""
echo -e "  3. Install dotfiles (minimal):"
echo -e "     ${BOLD}just install_minimal${NC}"
echo ""
echo -e "  4. Check system health:"
echo -e "     ${BOLD}just doctor${NC}"
echo ""
echo "For more help:"
echo "  just help"
echo "  cat README.md"
echo ""
