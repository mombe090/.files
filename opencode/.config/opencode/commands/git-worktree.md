---
description: Create a new git branch and worktree as a sibling directory for parallel work — no stashing, no branch switching
agent: general
subtask: false
---

# Git Worktree Command

Add a new branch and worktree via the git-worktree skill.

**Arguments:** $ARGUMENTS
**(expected: `<branch-name> [from-branch]`)**

## Instructions

Load the **git-worktree** skill and follow its workflow to:

1. Extract `branch-name` from $ARGUMENTS — if missing, ask the user
2. Extract optional `from-branch` — if missing, ask "Branch from? (leave blank for remote default)"
3. Run the worktree script from the user's current directory (works from any worktree)
4. Report the new worktree path and the `cd` command to enter it
