# =============================================================================
# templates.just - Deploy templates (zed)
#
# This module contains recipes that deploy tracked templates from the
# templates/ directory into the user's $HOME (breaking symlinks when
# necessary and backing up existing files). Follow the same conventions
# used by other .just modules: [unix] tag, bash shebang, set -euo pipefail,
# and use helpers from .just/_helpers.just ({{dotfiles_root}}, {{home}},
# {{color_*}}, _log_*).
# =============================================================================

[unix]
deploy_zed:
    #!/usr/bin/env bash
    set -euo pipefail

    # Source private envrc if present to load secret env vars
    if [ -f "${HOME}/.private.envrc" ]; then
        # shellcheck disable=SC1090
        source "${HOME}/.private.envrc"
    fi

    # Validate required env vars
    if [ -z "${GITHUB_TOKEN:-}" ]; then
        @just _log_error "GITHUB_TOKEN is not set. Please set it in ~/.private.envrc or export it in your shell."
        exit 1
    fi

    if [ -z "${CONTEXT7_API_KEY:-}" ]; then
        @just _log_error "CONTEXT7_API_KEY is not set. Please set it in ~/.private.envrc or export it in your shell."
        exit 1
    fi

    @just _log_step "Preparing Zed settings deploy..."

    BACKUP_DIR="${HOME}/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)/zed"
    mkdir -p "${BACKUP_DIR}"

    TARGET_DIR="${HOME}/.config/zed"
    TARGET_FILE="${TARGET_DIR}/settings.json"

    # If target exists (file or symlink), copy dereferenced content to backup
    if [ -e "${TARGET_FILE}" ] || [ -L "${TARGET_FILE}" ]; then
        # copy dereferenced (follow symlink) if possible
        if [ -L "${TARGET_FILE}" ]; then
            # Resolve real path and copy content
            cp -L "${TARGET_FILE}" "${BACKUP_DIR}/settings.json"
            # Unlink the symlink so we don't overwrite a tracked repo file
            unlink "${TARGET_FILE}" || true
        else
            cp "${TARGET_FILE}" "${BACKUP_DIR}/settings.json"
        fi
        @just _log_info "Backed up existing settings.json to ${BACKUP_DIR}/settings.json"
    else
        @just _log_info "No existing ~/.config/zed/settings.json to back up"
    fi

    # Ensure target dir exists
    mkdir -p "${TARGET_DIR}"

    # Run replacetokens from dotfiles root so relative template path resolves
    (cd "{{dotfiles_root}}" && \
        npx --yes @qetza/replacetokens \
            --sources "templates/zed/settings.json => ${TARGET_FILE}" \
            --token-prefix '#{' \
            --token-suffix '}#')

    @just _log_success "Zed settings deployed to ${TARGET_FILE}. Backup (if any) at ${BACKUP_DIR}/settings.json"
