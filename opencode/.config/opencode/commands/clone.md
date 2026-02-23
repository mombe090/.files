---
description: Clone a git repo as a bare repo and set up the default branch as the first worktree — enables parallel branch workflow via /git-worktree
agent: general
subtask: false
---

# Clone Command

Clone a repo using the bare worktree pattern via the git-clone skill.

**Arguments:** $ARGUMENTS
**(expected: `<repo-url> [name]`)**

## Instructions

Load the **git-clone** skill and follow its workflow to:

1. Extract the URL (and optional name) from $ARGUMENTS — if URL is missing, ask the user
2. Run the clone script from the user's current working directory
3. Report the paths created and the `cd` command to enter the main worktree
4. Remind the user they can now use `/git-worktree <branch-name>` for parallel work
