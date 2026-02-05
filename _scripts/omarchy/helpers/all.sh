#!/usr/bin/env bash
# Source all helper scripts

HELPERS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$HELPERS_DIR/logging.sh"
source "$HELPERS_DIR/detection.sh"
source "$HELPERS_DIR/backup.sh"
source "$HELPERS_DIR/inject.sh"
