#!/usr/bin/env bash
# Post-install orchestration

POST_INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$POST_INSTALL_DIR/.." && pwd)"

# Source helpers
source "$SCRIPT_DIR/helpers/all.sh"

bash "$POST_INSTALL_DIR/verify.sh"
bash "$POST_INSTALL_DIR/summary.sh"
