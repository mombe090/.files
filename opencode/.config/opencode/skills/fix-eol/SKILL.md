---
name: fix-eol
description: Fix end-of-line (CRLF/LF) drift in unstaged files where the ONLY diff vs the index is EOL characters. Skips files with real content changes. Does NOT stage anything. Use when the user runs /fix-eol, says "fix line endings", "clean EOL drift", or sees a git diff full of CRLF noise with no real changes.
---

# fix-eol Skill

## What it does

Scans unstaged modified files. For each file where `git diff` shows **only EOL changes and nothing else**, it restores the working-tree file's line endings to match what is committed in the index — then leaves it unstaged.

Files with real content changes are left completely untouched.

## Permanent fix (run once in WSL)

```bash
git config --global core.autocrlf input
```

Converts CRLF→LF on every `git add` in WSL silently, forever. This is the root fix.

IntelliJ on Windows: Settings → Editor → Code Style → Line separator → `\n (Unix and macOS)`

## /fix-eol Workflow

### 1. Run the script

```bash
python3 /Users/mombe090/.files/opencode/.config/opencode/skills/fix-eol/scripts/fix-eol.py
```

The script:

- Lists unstaged modified files (`git diff --name-only`)
- For each: checks if diff disappears with `--ignore-cr-at-eol` (EOL-only = yes)
- If EOL-only: reads what EOL the committed version uses, restores the working-tree file to match
- Skips binary files and files with real content changes

Nothing is staged. The working tree is cleaned so `git diff` goes silent on those files.

### 2. Verify

```bash
git diff
```

EOL-only drift files should no longer appear. Files with real changes remain untouched.

### 3. Report to user

- How many files were restored and to which EOL
- Which files were skipped due to real content changes (user should be aware)
- Remind about `core.autocrlf input` if not already set
