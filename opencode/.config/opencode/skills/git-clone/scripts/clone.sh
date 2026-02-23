#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: clone.sh <repo-url> [target-dir]"
    echo ""
    echo "  Bare-clones the repo and sets up a 'main' worktree."
    echo ""
    echo "  Result layout:"
    echo "    <target>.git/     ← bare repo (the .git)"
    echo "    <target>/main/    ← worktree for the default branch"
    exit 1
}

[[ $# -lt 1 ]] && usage

URL="$1"

if [[ $# -ge 2 ]]; then
    NAME="$2"
else
    NAME="$(basename "$URL" .git)"
fi

BARE_DIR="${NAME}.git"
MAIN_WORKTREE="${NAME}/main"

if [[ -e "$BARE_DIR" ]]; then
    echo "ERROR: '$BARE_DIR' already exists." >&2
    exit 1
fi

echo "→ Cloning bare: $URL"
git clone --bare "$URL" "$BARE_DIR"

DEFAULT_BRANCH="$(git -C "$BARE_DIR" symbolic-ref --short HEAD 2>/dev/null || echo "main")"

echo "→ Default branch: $DEFAULT_BRANCH"

git -C "$BARE_DIR" config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git -C "$BARE_DIR" fetch --quiet

mkdir -p "$NAME"
echo "→ Adding worktree: $MAIN_WORKTREE"
git -C "$BARE_DIR" worktree add "../${MAIN_WORKTREE}" "$DEFAULT_BRANCH"

echo ""
echo "✓ Done."
echo ""
echo "  Bare repo : $(pwd)/${BARE_DIR}"
echo "  Worktree  : $(pwd)/${MAIN_WORKTREE}"
echo ""
echo "  cd ${MAIN_WORKTREE}"
