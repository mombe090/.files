#!/usr/bin/env bash
# Deploy .gitconfig from template
# Replaces #{TOKEN}# placeholders with env vars or interactive prompts,
# then copies the result to ~/.gitconfig (never symlinked).
#
# Env vars (set these to skip the prompts):
#   USER_FULLNAME   e.g. "Mamadou Yaya DIALLO"
#   USER_EMAIL      e.g. "yayamombeya090@gmail.com"
#
# Usage:
#   USER_FULLNAME="John Doe" USER_EMAIL="john@example.com" ./deploy-gitconfig.sh
#   ./deploy-gitconfig.sh          # prompts for missing values

set -e

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
log_step()    { echo -e "${BLUE}[STEP]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
# Ensure HOME points to the actual current user (fixes stale HOME after su)
REAL_HOME=$(getent passwd "$(whoami)" | cut -d: -f6)
if [[ "$HOME" != "$REAL_HOME" ]]; then
    echo "[WARN] HOME was $HOME, correcting to $REAL_HOME"
    export HOME="$REAL_HOME"
fi

# Script is at: _scripts/unix/tools/ — 3 levels up to repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TEMPLATE="$DOTFILES_ROOT/git/.gitconfig.template"
TARGET="$HOME/.gitconfig"

# ---------------------------------------------------------------------------
# Validate template exists
# ---------------------------------------------------------------------------
if [[ ! -f "$TEMPLATE" ]]; then
    log_error "Template not found: $TEMPLATE"
    exit 1
fi

log_step "Deploying .gitconfig from template..."

# ---------------------------------------------------------------------------
# Resolve token values — env var first, then prompt
# ---------------------------------------------------------------------------
if [[ -z "$USER_FULLNAME" ]]; then
    # Try to read existing value from current .gitconfig as default
    default_name=""
    if [[ -f "$TARGET" ]]; then
        default_name=$(git config --file "$TARGET" user.name 2>/dev/null || true)
    fi

    if [[ -n "$default_name" ]]; then
        read -p "  Full name [$default_name]: " USER_FULLNAME
        USER_FULLNAME="${USER_FULLNAME:-$default_name}"
    else
        read -p "  Full name: " USER_FULLNAME
    fi
fi

if [[ -z "$USER_EMAIL" ]]; then
    default_email=""
    if [[ -f "$TARGET" ]]; then
        default_email=$(git config --file "$TARGET" user.email 2>/dev/null || true)
    fi

    if [[ -n "$default_email" ]]; then
        read -p "  Email [$default_email]: " USER_EMAIL
        USER_EMAIL="${USER_EMAIL:-$default_email}"
    else
        read -p "  Email: " USER_EMAIL
    fi
fi

# ---------------------------------------------------------------------------
# Validate — don't deploy with empty tokens
# ---------------------------------------------------------------------------
if [[ -z "$USER_FULLNAME" || -z "$USER_EMAIL" ]]; then
    log_error "Both USER_FULLNAME and USER_EMAIL are required"
    exit 1
fi

log_info "Name:  $USER_FULLNAME"
log_info "Email: $USER_EMAIL"

# ---------------------------------------------------------------------------
# Replace tokens and copy to target
# ---------------------------------------------------------------------------
sed \
    -e "s/#{USER_FULLNAME}#/$USER_FULLNAME/g" \
    -e "s/#{USER_EMAIL}#/$USER_EMAIL/g" \
    "$TEMPLATE" > "$TARGET"

log_success ".gitconfig deployed to $TARGET"
