#!/usr/bin/env bash
# Install custom packages

INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$INSTALL_DIR/.." && pwd)"

# Source helpers
source "$SCRIPT_DIR/helpers/all.sh"

PACKAGES_DIR="$INSTALL_DIR"
CUSTOM_LIST="$PACKAGES_DIR/custom.list"

if [[ ! -f "$CUSTOM_LIST" ]]; then
    log_info "No custom packages list found"
    exit 0
fi

# Read custom packages (skip comments and empty lines)
mapfile -t CUSTOM < <(grep -v '^#' "$CUSTOM_LIST" | grep -v '^$')

if [[ ${#CUSTOM[@]} -eq 0 ]]; then
    log_info "No custom packages to install"
    exit 0
fi

log_info "Checking ${#CUSTOM[@]} packages: ${CUSTOM[*]}"

# Check which packages are already installed
TO_INSTALL=()
for pkg in "${CUSTOM[@]}"; do
    if has_package "$pkg"; then
        log_info "  ✓ $pkg (already installed)"
    else
        log_info "  → $pkg (will install)"
        TO_INSTALL+=("$pkg")
    fi
done

if [[ ${#TO_INSTALL[@]} -eq 0 ]]; then
    log_success "All custom packages already installed"
    exit 0
fi

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would install: ${TO_INSTALL[*]}"
    exit 0
fi

# Install packages
log_info "Installing ${#TO_INSTALL[@]} packages..."
log_info "This may take a few moments..."

if sudo pacman -S --noconfirm --needed "${TO_INSTALL[@]}"; then
    log_success "Package installation completed"
else
    log_error "Package installation failed"
    exit 1
fi
