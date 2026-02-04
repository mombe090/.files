#!/usr/bin/env bash
# Verify - Check all installations and report status
set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# Parse arguments
CORE_ONLY=false
PATH_ONLY=false
SHELL_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --core)
            CORE_ONLY=true
            shift
            ;;
        --path-only)
            PATH_ONLY=true
            shift
            ;;
        --shell-only)
            SHELL_ONLY=true
            shift
            ;;
        *)
            echo "Usage: $0 [--core] [--path-only] [--shell-only]"
            exit 1
            ;;
    esac
done

check_tool() {
    local tool=$1
    local label=${2:-$tool}

    if command -v "$tool" &> /dev/null; then
        local version=$($tool --version 2>&1 | head -n1 || echo "installed")
        echo -e "${GREEN}✓${NC} $label: $version"
        return 0
    else
        echo -e "${RED}✗${NC} $label: not found"
        return 1
    fi
}

echo ""
echo -e "${BOLD}==================================${NC}"
echo -e "${BOLD}   Installation Verification${NC}"
echo -e "${BOLD}==================================${NC}"
echo ""

if [ "$PATH_ONLY" = true ]; then
    echo "PATH Configuration:"
    echo "  $PATH"
    echo ""
    exit 0
fi

if [ "$SHELL_ONLY" = true ]; then
    echo "Shell Configuration:"
    echo "  Current shell: $SHELL"
    echo "  Zsh location: $(which zsh 2>/dev/null || echo 'not found')"
    echo "  Zinit: $([ -d "$HOME/.local/share/zinit" ] && echo 'installed' || echo 'not installed')"
    echo ""
    exit 0
fi

# Core tools
echo "Core Tools:"
check_tool git
check_tool curl
check_tool zsh
check_tool stow "GNU Stow"
echo ""

if [ "$CORE_ONLY" = true ]; then
    exit 0
fi

# Version managers
echo "Version Managers:"
check_tool mise || echo -e "${YELLOW}  ℹ${NC} Install with: just install_mise"
echo ""

# Modern CLI tools
echo "Modern CLI Tools:"
check_tool bat || echo -e "${YELLOW}  ℹ${NC} Install with: just mise_use bat@latest"
check_tool eza || echo -e "${YELLOW}  ℹ${NC} Install with: just mise_use eza@latest"
check_tool fzf || echo -e "${YELLOW}  ℹ${NC} Install with: just mise_use fzf@latest"
check_tool rg "ripgrep" || echo -e "${YELLOW}  ℹ${NC} Install with: just mise_use ripgrep@latest"
check_tool fd || echo -e "${YELLOW}  ℹ${NC} Install with: just mise_use fd@latest"
check_tool zoxide || echo -e "${YELLOW}  ℹ${NC} Install with: just mise_use zoxide@latest"
check_tool starship || echo -e "${YELLOW}  ℹ${NC} Install with: just mise_use starship@latest"
check_tool nvim "Neovim" || echo -e "${YELLOW}  ℹ${NC} Install with: just install_lazyvim"
check_tool delta || echo -e "${YELLOW}  ℹ${NC} Install with: just mise_use delta@latest"
check_tool jq || echo -e "${YELLOW}  ℹ${NC} Install with: just mise_use jq@latest"
check_tool yq || echo -e "${YELLOW}  ℹ${NC} Install with: just mise_use yq@latest"
check_tool btop || echo -e "${YELLOW}  ℹ${NC} Install with: just mise_use btop@latest"
echo ""

# Development tools
echo "Development Tools:"
check_tool node "Node.js" || echo -e "${YELLOW}  ℹ${NC} Install with: just mise_use node@lts"
check_tool bun || echo -e "${YELLOW}  ℹ${NC} Install with: just mise_use bun@latest"
check_tool python || echo -e "${YELLOW}  ℹ${NC} Install with: just mise_use python@latest"
check_tool go || echo -e "${YELLOW}  ℹ${NC} Install with: just mise_use go@latest"
check_tool rust "rustc" || echo -e "${YELLOW}  ℹ${NC} Install with: just mise_use rust@latest"
check_tool dotnet ".NET SDK" || echo -e "${YELLOW}  ℹ${NC} Install with: just install_dotnet"
echo ""

# Build tools
echo "Build Tools:"
check_tool gcc || echo -e "${YELLOW}  ℹ${NC} Install with: just install_essentials"
check_tool make || echo -e "${YELLOW}  ℹ${NC} Install with: just install_essentials"
check_tool cmake || echo -e "${YELLOW}  ℹ${NC} Install with: just install_essentials"
echo ""

echo -e "${GREEN}✓ Verification complete${NC}"
echo ""
