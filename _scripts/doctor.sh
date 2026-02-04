#!/usr/bin/env bash
# Doctor - Comprehensive health check for dotfiles installation
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

ISSUES_FOUND=0
WARNINGS_FOUND=0

log_check() { echo -e "${BLUE}[CHECK]${NC} $1"; }
log_ok() { echo -e "${GREEN}  ✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}  ⚠${NC} $1"; WARNINGS_FOUND=$((WARNINGS_FOUND + 1)); }
log_error() { echo -e "${RED}  ✗${NC} $1"; ISSUES_FOUND=$((ISSUES_FOUND + 1)); }
log_info() { echo -e "${BLUE}  ℹ${NC} $1"; }

echo ""
echo -e "${BOLD}==================================${NC}"
echo -e "${BOLD}   Dotfiles Health Check${NC}"
echo -e "${BOLD}==================================${NC}"
echo ""

# Check 1: Git configuration
log_check "Git configuration..."
if [ -f "$HOME/.gitconfig.local" ]; then
    log_ok ".gitconfig.local exists"

    # Check if user name and email are set
    if grep -q "name.*Your Name" "$HOME/.gitconfig.local" 2>/dev/null; then
        log_warn "Git user name not configured (still 'Your Name')"
        log_info "Edit ~/.gitconfig.local with your information"
    else
        log_ok "Git user name configured"
    fi
else
    log_warn ".gitconfig.local not found"
    log_info "Create ~/.gitconfig.local with your git user info"
fi
echo ""

# Check 2: Shell setup
log_check "Shell setup..."
if [ "$SHELL" = "$(which zsh)" ] || [ "$SHELL" = "/bin/zsh" ]; then
    log_ok "Zsh is default shell"
else
    log_warn "Default shell is not zsh: $SHELL"
    log_info "Run: chsh -s $(which zsh)"
fi

if [ -d "$HOME/.local/share/zinit" ]; then
    log_ok "Zinit plugin manager installed"
else
    log_warn "Zinit not found"
    log_info "It will be installed on first zsh launch"
fi
echo ""

# Check 3: PATH configuration
log_check "PATH configuration..."

# Check mise
if command -v mise &> /dev/null; then
    log_ok "mise is in PATH: $(mise --version)"
else
    log_error "mise not found in PATH"
    log_info "Install with: just install_mise"
fi

# Check bun
if command -v bun &> /dev/null; then
    log_ok "bun is in PATH: $(bun --version)"

    # Check if bun global bin is in PATH
    if echo "$PATH" | grep -q ".bun/bin"; then
        log_ok "bun global bin directory in PATH"
    else
        log_warn "~/.bun/bin not in PATH"
        log_info "Add to your shell config: export PATH=\"\$HOME/.bun/bin:\$PATH\""
    fi
else
    log_warn "bun not found"
    log_info "Install via mise: just mise_use bun@latest"
fi

# Check dotnet
if command -v dotnet &> /dev/null; then
    log_ok "dotnet is in PATH: $(dotnet --version)"
else
    log_warn ".NET SDK not found"
    log_info "Install with: just install_dotnet"
fi
echo ""

# Check 4: Symlink status
log_check "Symlink status..."
BROKEN_LINKS=$(find "$HOME/.config" -maxdepth 2 -type l ! -exec test -e {} \; -print 2>/dev/null | wc -l)
if [ "$BROKEN_LINKS" -eq 0 ]; then
    log_ok "No broken symlinks found"
else
    log_warn "Found $BROKEN_LINKS broken symlink(s) in ~/.config"
    log_info "Run: just restow to fix"
fi
echo ""

# Check 5: Tool versions
log_check "Installed tools..."

# Core tools
for tool in git curl stow; do
    if command -v $tool &> /dev/null; then
        log_ok "$tool: $(command -v $tool)"
    else
        log_error "$tool not installed"
    fi
done

# Optional but recommended
for tool in bat eza fzf rg fd zoxide starship nvim delta jq yq; do
    if command -v $tool &> /dev/null; then
        log_ok "$tool: installed"
    else
        log_info "$tool: not installed (optional)"
    fi
done
echo ""

# Check 6: Build tools (if essentials were installed)
log_check "Build essentials..."
if command -v gcc &> /dev/null; then
    log_ok "gcc: $(gcc --version | head -n1)"
else
    log_info "gcc not installed (install with: just install_essentials)"
fi

if command -v make &> /dev/null; then
    log_ok "make: $(make --version | head -n1)"
else
    log_info "make not installed"
fi
echo ""

# Check 7: Environment files
log_check "Environment files..."
if [ -f "$HOME/.env" ]; then
    log_ok ".env file exists"
else
    log_info ".env not found (optional)"
fi

if [ -f "$HOME/.envrc" ]; then
    log_ok ".envrc file exists"
else
    log_info ".envrc not found (optional, for direnv)"
fi
echo ""

# Summary
echo -e "${BOLD}==================================${NC}"
echo -e "${BOLD}   Summary${NC}"
echo -e "${BOLD}==================================${NC}"
echo ""

if [ $ISSUES_FOUND -eq 0 ] && [ $WARNINGS_FOUND -eq 0 ]; then
    echo -e "${GREEN}✓ Everything looks good!${NC}"
    echo ""
    exit 0
elif [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${YELLOW}⚠ Found $WARNINGS_FOUND warning(s)${NC}"
    echo ""
    echo "Your system is functional but some optional improvements are available."
    echo ""
    exit 0
else
    echo -e "${RED}✗ Found $ISSUES_FOUND issue(s) and $WARNINGS_FOUND warning(s)${NC}"
    echo ""
    echo "Please address the issues above to ensure proper functionality."
    echo ""
    exit 1
fi
