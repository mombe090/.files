# =============================================================================
# dev.just - Development and testing recipes
# =============================================================================

# Run all tests
[unix]
test:
    @just _log_step "Running tests..."
    @echo ""
    @just _log_info "Running pre-commit hooks..."
    @pre-commit run --all-files || true
    @echo ""
    @just _log_info "Verifying installations..."
    @just verify
    @echo ""
    @just _log_success "Tests complete!"

# Test stow configuration (dry run)
[unix]
test_stow PKG="":
    #!/usr/bin/env bash
    set -euo pipefail

    echo -e "{{color_blue}}[STEP]{{color_reset}} Testing stow configuration (dry run)..."

    if [ -z "{{PKG}}" ]; then
        stow -v -n -t "$HOME" zsh bash mise zellij bat nvim starship wezterm nushell powershell 2>&1 | grep -v "BUG in find_stowed_path" || true
    else
        stow -v -n -t "$HOME" {{PKG}} 2>&1 | grep -v "BUG in find_stowed_path" || true
    fi

    echo ""
    echo -e "{{color_green}}[✓]{{color_reset}} Dry run complete (no changes made)"

# Lint shell scripts
[unix]
lint:
    @just _log_step "Linting shell scripts..."
    @find . -name "*.sh" -not -path "./.git/*" -exec shellcheck {} + || echo "shellcheck not installed"
    @just _log_success "Lint complete!"

# Format shell scripts
[unix]
format:
    @just _log_step "Formatting shell scripts..."
    @find . -name "*.sh" -not -path "./.git/*" -exec shfmt -w {} + || echo "shfmt not installed"
    @just _log_success "Format complete!"

# Run MkDocs development server
docs_serve:
    @just _log_step "Starting MkDocs server..."
    @mkdocs serve

# Build MkDocs static site
docs_build:
    @just _log_step "Building MkDocs site..."
    @mkdocs build

# Deploy MkDocs to GitHub Pages
docs_deploy:
    @just _log_step "Deploying docs to GitHub Pages..."
    @mkdocs gh-deploy -m "docs: update just integration documentation"

# Show dependency tree
show_deps:
    @echo "Justfile Module Dependencies:"
    @echo ""
    @echo "justfile (main)"
    @echo "  ├── _helpers.just"
    @echo "  ├── install.just"
    @echo "  │     ├── mise.just (mise_install)"
    @echo "  │     └── stow.just (stow after install)"
    @echo "  ├── stow.just"
    @echo "  ├── mise.just"
    @echo "  ├── verify.just"
    @echo "  ├── maintenance.just"
    @echo "  │     ├── stow.just (restow)"
    @echo "  │     └── verify.just (verify after update)"
    @echo "  ├── windows.just"
    @echo "  └── dev.just"
    @echo ""

# Show recipe count
show_stats:
    @echo "Justfile Statistics:"
    @echo ""
    @echo "Total recipes: $(just --summary | wc -w)"
    @echo ""
    @echo "Recipes by module:"
    @echo "  justfile:        $(grep -c "^[a-z_]*:" justfile || echo 0)"
    @echo "  install.just:    $(grep -c "^[a-z_]*:" .just/install.just || echo 0)"
    @echo "  stow.just:       $(grep -c "^[a-z_]*:" .just/stow.just || echo 0)"
    @echo "  mise.just:       $(grep -c "^[a-z_]*:" .just/mise.just || echo 0)"
    @echo "  verify.just:     $(grep -c "^[a-z_]*:" .just/verify.just || echo 0)"
    @echo "  maintenance.just: $(grep -c "^[a-z_]*:" .just/maintenance.just || echo 0)"
    @echo "  windows.just:    $(grep -c "^[a-z_]*:" .just/windows.just || echo 0)"
    @echo "  dev.just:        $(grep -c "^[a-z_]*:" .just/dev.just || echo 0)"
    @echo ""
