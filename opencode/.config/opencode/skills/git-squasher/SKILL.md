---
name: git-squasher
description: Squash a range of commits into one on the current branch. Use when the user runs /git-squash, provides two commit SHAs to squash between, or asks to squash commits. If no commit IDs given, ask the user if they want to squash all commits on the current branch since it diverged from its base.
---

# git-squasher Skill

## /git-squash Workflow

### 1. Parse arguments

Syntax: `/git-squash [first-commit] [last-commit]`

**Both SHAs provided** → go straight to step 3.

**No SHAs provided** → ask the user:

> "No commit range given. Do you want to squash all commits on this branch since it diverged from its base?"
>
> - If yes: resolve automatically (see step 2)
> - If no: ask them to provide the range with `git log --oneline`

### 2. Auto-resolve range (when no SHAs given)

Find the point where the current branch diverged from its upstream or default base:

```bash
git log --oneline HEAD ^$(git merge-base HEAD origin/main) | tail -1
```

This gives the oldest commit on the branch. The range is:

- `first-commit` = that oldest commit SHA
- `last-commit`  = `HEAD`

Show the user the commits that will be squashed and confirm before proceeding.

### 3. Run the script

```bash
bash /Users/mombe090/.files/opencode/.config/opencode/skills/git-squasher/scripts/squash.sh <first-commit> <last-commit>
```

The script:

- Validates both SHAs exist and that `last-commit` is `HEAD`
- Computes the base as `first-commit^` (the commit just before)
- Shows the list of commits being squashed (oldest → newest)
- Assembles a combined message: first commit subject as title, remaining subjects as bullet list
- Does `git reset --soft <base>` then `git commit -m <combined>`
- Reports the new single commit SHA

### 4. Report to user

```text
✓ Squashed 4 commits into: a1b2c3d
  feat(auth): add login flow
```

Remind the user: if this branch was already pushed, they'll need `git push --force-with-lease`.

## Safety rules

- **Never squash commits that include commits already on the remote default branch** — only squash branch-local commits
- `last-commit` must always be `HEAD` — the script enforces this
- If the working tree is dirty, tell the user to stash or commit first
