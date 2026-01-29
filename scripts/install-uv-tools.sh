#!/usr/bin/env bash
# Install Python tools via UV with venv
# This script helps manage the global Python tools defined in ~/pyproject.toml

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }

# Check if UV is installed
check_uv() {
    if ! command -v uv &> /dev/null; then
        log_error "UV is not installed"
        log_info "Install UV with mise: mise install uv"
        return 1
    fi
    
    log_info "UV version: $(uv --version)"
    return 0
}

# Check if pyproject.toml exists
check_pyproject() {
    if [[ ! -f "$HOME/pyproject.toml" ]]; then
        log_error "pyproject.toml not found at $HOME/pyproject.toml"
        log_info "Stow the UV package first: cd ~/.files && ./scripts/manage-stow.sh stow uv"
        return 1
    fi
    
    log_success "Found pyproject.toml"
    return 0
}

# Create venv if it doesn't exist
ensure_venv() {
    if [[ ! -d "$HOME/.venv" ]]; then
        log_step "Creating virtual environment at ~/.venv..."
        cd "$HOME"
        uv venv
        log_success "Virtual environment created"
    else
        log_info "Virtual environment already exists at ~/.venv"
    fi
}

# Install all tools
install_tools() {
    local extras="${1:-}"
    
    log_step "Installing Python tools via UV..."
    echo ""
    
    ensure_venv
    
    cd "$HOME"
    
    if [[ -n "$extras" ]]; then
        log_info "Syncing with extras: $extras"
        uv sync --extra "$extras"
    else
        log_info "Syncing core tools..."
        uv sync
    fi
    
    echo ""
    log_success "Python tools installed!"
    log_info "Virtual environment: ~/.venv"
    log_info "Add to PATH: export PATH=\"\$HOME/.venv/bin:\$PATH\""
}

# List installed tools
list_tools() {
    log_step "Listing installed Python tools..."
    echo ""
    
    if [[ -d "$HOME/.venv" ]]; then
        "$HOME/.venv/bin/pip" list
    else
        log_error "No virtual environment found at ~/.venv"
        log_info "Run: $(basename "$0") install"
        return 1
    fi
}

# Update all tools
update_tools() {
    log_step "Updating Python tools..."
    echo ""
    
    ensure_venv
    
    cd "$HOME"
    uv sync --upgrade
    
    echo ""
    log_success "Python tools updated!"
}

# Sync tools (install missing, remove unused)
sync_tools() {
    log_step "Syncing Python tools..."
    echo ""
    
    ensure_venv
    
    cd "$HOME"
    uv sync
    
    echo ""
    log_success "Python tools synced!"
}

# Show help
show_help() {
    cat << EOF
Usage: $(basename "$0") [COMMAND] [OPTIONS]

Manage global Python tools via UV with virtual environment at ~/.venv

Commands:
  install [EXTRAS]    Install Python tools with uv sync (default: core tools only)
  update              Update all installed tools (uv sync --upgrade)
  list                List installed Python tools
  sync                Sync tools with pyproject.toml (install missing, remove unused)
  help                Show this help message

Extras (optional dependencies):
  data                Data science tools (pandas, numpy, matplotlib)
  aws                 AWS/Azure tools (awscli, boto3, azure-cli)

Examples:
  # Install core tools
  $(basename "$0") install
  
  # Install with data science extras
  $(basename "$0") install data
  
  # Install with AWS extras
  $(basename "$0") install aws
  
  # Update all tools
  $(basename "$0") update
  
  # List installed tools
  $(basename "$0") list
  
  # Sync tools with pyproject.toml
  $(basename "$0") sync

Core Tools:
  - checkov          IaC security scanner
  - ty               Python type checker and formatter
  - pytest           Testing framework
  - ansible          Configuration management
  - httpie           Modern HTTP client
  - ipython          Enhanced Python REPL
  - rich             Rich terminal output

Note: Ruff (linter/formatter) is installed via mise, not pip.

Virtual Environment:
  Location:          ~/.venv
  Activation:        Automatic via PATH (configured in zsh env.zsh)
  PATH:              ~/.venv/bin is added to PATH

Configuration:
  UV config:         ~/.config/uv/uv.toml
  Python project:    ~/pyproject.toml
  Virtual env:       ~/.venv

Prerequisites:
  1. UV is installed via mise (already configured)
  2. UV package must be stowed:
     cd ~/.files && ./scripts/manage-stow.sh stow uv
  3. Shell must add ~/.venv/bin to PATH (configured in zsh env.zsh)

Workflow:
  1. Stow UV package    → Creates ~/pyproject.toml and ~/.config/uv/uv.toml
  2. Run install        → Creates ~/.venv and installs tools
  3. Use tools          → checkov, ansible, pytest, etc. available in PATH

EOF
}

# Main function
main() {
    local command="${1:-install}"
    
    case "$command" in
        install)
            check_uv || exit 1
            check_pyproject || exit 1
            install_tools "${2:-}"
            ;;
        update|upgrade)
            check_uv || exit 1
            check_pyproject || exit 1
            update_tools
            ;;
        list|ls)
            list_tools
            ;;
        sync)
            check_uv || exit 1
            check_pyproject || exit 1
            sync_tools
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"
