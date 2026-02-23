---
name: git-worktree
description: Create a new git branch and worktree as a sibling directory for parallel work. Use when the user runs /git-worktree <branch-name> [from-branch], wants to work on a new feature/fix in parallel without disturbing other branches, or says "new worktree", "add worktree", "start new branch". Requires the repo to have been cloned with /clone (bare clone).
---

# git-worktree Skill

## Concept

Each branch lives in its own directory on disk. You can have multiple branches open simultaneously with no stashing, no switching.

```text
myrepo.git/            ← bare repo
myrepo/
  main/                ← default branch worktree
  myrepo--feature-x/  ← worktree for feature-x  (sibling to main/)
  myrepo--fix-123/     ← worktree for fix-123
```

## /git-worktree Workflow

### 1. Parse arguments

Syntax: `/git-worktree <branch-name> [from-branch]`

- `branch-name` — required. Name of the new branch to create.
- `from-branch` — optional. Which branch/ref to base it on. If omitted, ask the user: "Branch from? (leave blank for default remote branch)"

### 2. Confirm location

The script derives everything from `git rev-parse --git-common-dir` — it works from **any worktree** of the bare repo. No need to cd to the bare repo first.

New worktree lands at: `../<repo-name>--<branch-name>/`

### 3. Run the script

```bash
bash /Users/mombe090/.files/opencode/.config/opencode/skills/git-worktree/scripts/worktree.sh <branch-name> [from-branch]
```

The script:

- Fetches latest from origin
- Resolves the base ref (remote default branch if not specified)
- Creates the local branch pointing at the base ref
- Adds the worktree at the sibling path

### 4. Report to user

```text
✓ Branch   : feature-x  (from origin/main)
✓ Worktree : /path/to/myrepo--feature-x

cd ../myrepo--feature-x
```

## Useful git worktree commands to share when relevant

```bash
git worktree list                      # see all worktrees
git worktree remove ../repo--branch    # remove a worktree when done
git branch -d branch-name              # delete the branch after merge
```
