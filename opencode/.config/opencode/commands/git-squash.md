---
description: Squash a range of commits into one — provide first and last commit SHA, or omit both to squash all commits on the current branch
agent: general
subtask: false
---

# Git Squash Command

Squash commits using the git-squasher skill.

**Arguments:** $ARGUMENTS
**(expected: `[first-commit-sha] [last-commit-sha]`)**

## Instructions

Load the **git-squasher** skill and follow its workflow:

1. Parse `first-commit` and `last-commit` from $ARGUMENTS
2. If neither is provided, ask the user if they want to squash all branch-local commits (auto-resolve the range)
3. Show the commits that will be squashed and confirm with the user before proceeding
4. Run the squash script
5. Report the resulting commit SHA and remind about `--force-with-lease` if the branch was already pushed
