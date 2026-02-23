#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: squash.sh <first-commit> <last-commit>"
    echo ""
    echo "  Squashes commits from <first-commit> up to and including <last-commit>"
    echo "  into a single commit on the current branch."
    echo ""
    echo "  <first-commit>  SHA of the oldest commit to include in the squash"
    echo "  <last-commit>   SHA of the newest commit to include (usually HEAD)"
    echo ""
    echo "  The squash base is the commit just before <first-commit>."
    echo "  A combined commit message is assembled from all squashed commits."
    exit 1
}

[[ $# -lt 2 ]] && usage

FIRST="$1"
LAST="$2"

if ! git rev-parse --git-dir &>/dev/null; then
    echo "ERROR: not inside a git repository." >&2
    exit 1
fi

if ! git rev-parse --verify "${FIRST}^{commit}" &>/dev/null; then
    echo "ERROR: '${FIRST}' is not a valid commit." >&2
    exit 1
fi

if ! git rev-parse --verify "${LAST}^{commit}" &>/dev/null; then
    echo "ERROR: '${LAST}' is not a valid commit." >&2
    exit 1
fi

FIRST_FULL="$(git rev-parse "$FIRST")"
LAST_FULL="$(git rev-parse "$LAST")"
HEAD_FULL="$(git rev-parse HEAD)"

if [[ "$LAST_FULL" != "$HEAD_FULL" ]]; then
    echo "ERROR: <last-commit> must be HEAD ($(git rev-parse --short HEAD))." >&2
    echo "       Squashing into the middle of a branch is not supported." >&2
    exit 1
fi

BASE="$(git rev-parse "${FIRST_FULL}^")" 2>/dev/null || {
    echo "ERROR: '${FIRST}' has no parent — it may be the root commit." >&2
    exit 1
}

COMMIT_COUNT="$(git rev-list --count "${BASE}..${LAST_FULL}")"
if [[ "$COMMIT_COUNT" -lt 2 ]]; then
    echo "ERROR: need at least 2 commits to squash (found ${COMMIT_COUNT})." >&2
    exit 1
fi

echo "→ Squashing ${COMMIT_COUNT} commits:"
git log --oneline "${BASE}..${LAST_FULL}" | awk '{lines[NR]=$0} END{for(i=NR;i>=1;i--) print lines[i]}'
echo ""

COMBINED_MSG="$(git log --format="%s%n%n%b" --reverse "${BASE}..${LAST_FULL}" | sed '/^[[:space:]]*$/d' | awk 'NR==1{print; next} /^./{print "- "$0}')"

git reset --soft "$BASE"

git commit --allow-empty -m "$COMBINED_MSG"

NEW_SHA="$(git rev-parse --short HEAD)"
echo "✓ Squashed into: ${NEW_SHA}"
echo ""
git log --oneline -1
