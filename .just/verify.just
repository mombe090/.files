# =============================================================================
# verify.just - Health checks and verification recipes
# =============================================================================

# Run comprehensive health check
doctor:
    @just _log_step "Running health check..."
    @{{dotfiles_root}}/_scripts/doctor.sh

# Verify all installations
verify:
    @just _log_step "Verifying installations..."
    @{{dotfiles_root}}/_scripts/verify.sh

# Verify core tools only
verify_core:
    @just _log_step "Verifying core tools..."
    @{{dotfiles_root}}/_scripts/verify.sh --core

# Check PATH configuration
check_path:
    @just _log_step "Checking PATH configuration..."
    @{{dotfiles_root}}/_scripts/verify.sh --path-only

# Check shell setup
check_shell:
    @just _log_step "Checking shell setup..."
    @{{dotfiles_root}}/_scripts/verify.sh --shell-only
