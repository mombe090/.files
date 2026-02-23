---
description: Fix EOL drift in unstaged files — restore line endings to match what is committed, only for files where the diff is EOL-only noise
agent: general
subtask: false
---

# Fix EOL Command

Fix end-of-line drift in unstaged working-tree files using the fix-eol skill.

**Optional arguments:** $ARGUMENTS

## Instructions

Load the **fix-eol** skill and follow its workflow:

1. Find unstaged modified files where `git diff` shows only EOL changes (no real content diff)
2. Restore each file's line endings to match what is committed in the index
3. Leave files with real content changes completely untouched
4. Do NOT stage anything
5. Report what was fixed and what was skipped
