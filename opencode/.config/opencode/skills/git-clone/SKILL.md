---
name: git-clone
description: Clone a git repo as a bare repo and set up the default branch as the first worktree. Use when the user runs /clone <url>, wants to set up a worktree-based git workflow, or says "clone repo for worktree workflow". This is the entry point before /git-worktree.
---

# git-clone Skill

## Concept

Instead of a normal clone (working tree + hidden `.git/`), this creates:

```text
<name>.git/       ← bare repo (no working tree, just git objects + config)
<name>/
  main/           ← first worktree, checked out to the default branch
```

The bare repo is the single source of truth. Every branch lives in its own sibling worktree created via `/git-worktree`. You never work directly inside `<name>.git/`.

## /clone Workflow

### 1. Get the URL from the user

If not provided in arguments, ask: "What is the repo URL?"
Optionally accept a custom name: `/clone <url> [name]`

### 2. Run the script

```bash
bash /Users/mombe090/.files/opencode/.config/opencode/skills/git-clone/scripts/clone.sh <url> [name]
```

Run from the directory where the user wants the repo to live.

The script:

- `git clone --bare <url> <name>.git`
- Fixes the fetch refspec so `git fetch` works from worktrees
- Adds a worktree at `<name>/main` for the default branch

### 3. Report to user

Show the exact paths created and the `cd` command to get started:

```text
✓ Bare repo : /path/to/<name>.git
✓ Worktree  : /path/to/<name>/main

cd <name>/main
```

Remind them: use `/git-worktree <branch-name>` from inside any worktree to start parallel work.
