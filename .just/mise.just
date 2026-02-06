# =============================================================================
# mise.just - Tool version management recipes
# =============================================================================

# Install tools from mise configuration
mise_install:
    @just _log_step "Installing mise tools from configuration..."
    @mise install

# Upgrade all mise tools
mise_upgrade:
    @just _log_step "Upgrading all mise tools..."
    @mise upgrade

# List installed mise tools
mise_list:
    @just _log_step "Installed mise tools:"
    @mise list

# Add tool to global mise configuration
mise_use TOOL:
    @just _log_step "Adding {{TOOL}} to global mise configuration..."
    @mise use -g {{TOOL}}

# Show outdated mise tools
mise_outdated:
    @just _log_step "Checking for outdated tools..."
    @mise outdated

# Show mise doctor output
mise_doctor:
    @just _log_step "Running mise doctor..."
    @mise doctor

# Prune unused mise tool versions
mise_prune:
    @just _log_step "Pruning unused mise tool versions..."
    @mise prune
