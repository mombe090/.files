#!/usr/bin/env bash
# Remove unwanted Omarchy default packages

UNINSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$UNINSTALL_DIR/.." && pwd)"

# Source helpers
source "$SCRIPT_DIR/helpers/all.sh"

PACKAGES_DIR="$UNINSTALL_DIR"
UNWANTED_LIST="$PACKAGES_DIR/unwanted.list"

if [[ ! -f "$UNWANTED_LIST" ]]; then
    log_info "No unwanted packages list found"
    exit 0
fi

# Read unwanted packages (skip comments and empty lines)
mapfile -t UNWANTED < <(grep -v '^#' "$UNWANTED_LIST" | grep -v '^$')

if [[ ${#UNWANTED[@]} -eq 0 ]]; then
    log_info "No unwanted packages to remove"
    exit 0
fi

log_info "Packages to remove: ${UNWANTED[*]}"

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would remove packages"
    exit 0
fi

# Remove packages
for pkg in "${UNWANTED[@]}"; do
    if has_package "$pkg"; then
        log_info "Removing package: $pkg"
        sudo pacman -R --noconfirm "$pkg" || log_warn "Failed to remove: $pkg"
    else
        log_info "Package not installed: $pkg"
    fi
done

log_success "Package removal completed"
