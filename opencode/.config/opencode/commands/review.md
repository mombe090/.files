---
description: Perform comprehensive tech lead-level pull request review
agent: general
subtask: false
---

# Pull Request Review Command

You are performing a comprehensive tech lead-level pull request code review using the pr-reviewer skill.

**Optional story context from user:** $ARGUMENTS

## Instructions

1. **Load the pr-reviewer skill** - This skill contains the complete review methodology, best practices references, and language-specific patterns.

2. **Follow the pr-reviewer skill workflow** to conduct the review:
   - Gather git context (current branch, base branch, changes)
   - Analyze changes and detect technologies
   - Perform deep multi-dimensional review
   - Generate comprehensive report

3. **Include story context** - If the user provided context in $ARGUMENTS, include it in the "Story Context" section of the review report.

4. **Save review report** to `local_stuff/reviews/review-<branch-name>-<timestamp>.md`

5. **Provide summary** after completion with:
   - File path to the review
   - Overall assessment (APPROVE / REQUEST CHANGES / NEEDS MAJOR REVISION)
   - Count of Critical/Major/Minor issues
   - Key concerns highlighted

That's it! The pr-reviewer skill has all the detailed instructions.
