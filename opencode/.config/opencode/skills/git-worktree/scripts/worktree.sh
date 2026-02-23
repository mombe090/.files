#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: worktree.sh <branch-name> [from-branch]"
    echo ""
    echo "  Must be run from inside a bare repo (.git dir) or any worktree of one."
    echo ""
    echo "  Creates a new branch and worktree as a sibling directory:"
    echo "    ../<repo-name>--<branch-name>/"
    echo ""
    echo "  from-branch defaults to the remote default branch (origin/main or origin/master)."
    exit 1
}

[[ $# -lt 1 ]] && usage

BRANCH="$1"

GIT_DIR="$(git rev-parse --git-common-dir 2>/dev/null)" || {
    echo "ERROR: not inside a git repository." >&2
    exit 1
}
GIT_DIR="$(cd "$GIT_DIR" && pwd)"

BARE_NAME="$(basename "$GIT_DIR")"
REPO_NAME="${BARE_NAME%.git}"

WORKTREE_PATH="$(dirname "$GIT_DIR")/${REPO_NAME}--${BRANCH}"

if [[ -e "$WORKTREE_PATH" ]]; then
    echo "ERROR: '$WORKTREE_PATH' already exists." >&2
    exit 1
fi

if git -C "$GIT_DIR" show-ref --verify --quiet "refs/heads/${BRANCH}"; then
    echo "ERROR: branch '${BRANCH}' already exists locally. Use a different name or delete it first." >&2
    exit 1
fi

echo "→ Fetching latest from origin..."
git -C "$GIT_DIR" fetch --quiet origin

if [[ $# -ge 2 ]]; then
    FROM="$2"
    if ! git -C "$GIT_DIR" rev-parse --verify "$FROM" &>/dev/null; then
        echo "ERROR: base branch '$FROM' not found." >&2
        exit 1
    fi
else
    DEFAULT_BRANCH="$(git -C "$GIT_DIR" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|origin/||' || true)"
    if [[ -z "$DEFAULT_BRANCH" ]]; then
        git -C "$GIT_DIR" remote set-head origin --auto --quiet 2>/dev/null || true
        DEFAULT_BRANCH="$(git -C "$GIT_DIR" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|origin/||' || echo "main")"
    fi
    FROM="origin/${DEFAULT_BRANCH}"
    echo "→ Base branch: $FROM"
fi

echo "→ Creating branch '${BRANCH}' from '${FROM}'"
git -C "$GIT_DIR" branch "$BRANCH" "$FROM"

echo "→ Adding worktree: $WORKTREE_PATH"
git -C "$GIT_DIR" worktree add "$WORKTREE_PATH" "$BRANCH"

echo ""
echo "✓ Done."
echo ""
echo "  Branch   : ${BRANCH}  (from ${FROM})"
echo "  Worktree : ${WORKTREE_PATH}"
echo ""
echo "  cd ${WORKTREE_PATH}"
