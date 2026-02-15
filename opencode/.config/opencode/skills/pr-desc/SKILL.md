# Skill: pr-desc

## Overview

Generate pull request descriptions by analyzing changes between current branch and base branch (main/master).

## Command: /pr-desc

**Syntax:**

```text
/pr-desc [base-branch] [--gh|--no-gh]
```

**Arguments:**

- `base-branch` (optional): Target branch to compare against. Defaults to `main`, falls back to `master`.
- `--gh`: Create PR using GitHub CLI after generating description
- `--no-gh` (default): Only output the description, don't create PR

**Examples:**

```text
/pr-desc                    # Compare with main/master, output only
/pr-desc develop            # Compare with develop, output only
/pr-desc --gh               # Compare with main/master, create PR
/pr-desc main --gh          # Compare with main, create PR
```

## Workflow

### 1. Detect Base Branch

```bash
# If base-branch provided, use it
# Otherwise, detect default branch:
git rev-parse --verify main >/dev/null 2>&1 && echo "main" || echo "master"
```

### 2. Collect Changes

Run in parallel:

```bash
# Current branch name
git branch --show-current

# Check if up to date with remote
git fetch origin && git status

# All commits in current branch not in base
git log base-branch..HEAD --oneline

# Detailed commit messages
git log base-branch..HEAD --format='%h %s%n%b'

# File changes summary
git diff base-branch...HEAD --stat

# Actual diff
git diff base-branch...HEAD
```

### 3. Analyze Changes

Review:

- Commit messages (understand intent)
- Modified files (scope of changes)
- Diff content (implementation details)

Categorize changes:

- New features (`feat:`)
- Bug fixes (`fix:`)
- Documentation (`docs:`)
- Refactoring (`refactor:`)
- Performance (`perf:`)
- Tests (`test:`)
- CI/CD (`ci:`)
- Chores (`chore:`)

### 4. Generate PR Description

**Format:**

```text
## Summary

- Bullet point 1 (high-level change)
- Bullet point 2
- Bullet point 3

## Changes

### Features
- Feature 1
- Feature 2

### Fixes
- Fix 1

### Documentation
- Doc update 1

## Technical Details

Brief explanation of implementation approach (optional, only if complex).

## Testing

How changes were verified (if applicable).
```

**Guidelines:**

- **Summary**: 2-4 bullet points, focus on user impact
- **Changes**: Group by type (features, fixes, docs, etc.)
- **Concise**: No fluff, straight to the point
- **Technical Details**: Only if non-trivial
- **Testing**: Only if tests added or manual testing required

### 5. Output PR Description

**Default behavior (--no-gh):**

Present the description:

```text
## Pull Request Description

[Generated description]

---

**Branch:** `current-branch` → `base-branch`
**Commits:** X commits
**Files changed:** Y files
```

**With --gh flag:**

1. Generate description
2. Output the description for review
3. Create PR using `gh pr create` with the generated description

## Examples

### Simple Feature PR

```text
## Summary

- Add OAuth2 authentication support for Google and GitHub providers
- Implement token refresh mechanism

## Changes

### Features
- OAuth2 flow with provider selection
- Automatic token refresh
- User profile sync from OAuth providers

### Documentation
- Update authentication guide with OAuth2 setup instructions
```

### Bug Fix PR

```text
## Summary

- Fix memory leak in cache manager
- Resolve race condition in request handling

## Changes

### Fixes
- Memory leak in LRU cache (closes #456)
- Race condition when processing concurrent requests (closes #457)

## Technical Details

Introduced request ID tracking to ensure only latest response is processed.
Added proper cleanup in cache eviction handler.

## Testing

- Added unit tests for concurrent request scenarios
- Verified memory usage under load (no growth over 24h)
```

### Documentation PR

```text
## Summary

- Improve CI/CD documentation with multi-registry setup guide
- Fix formatting and consistency issues

## Changes

### Documentation
- Add Docker build pipeline setup guide
- Update service connection naming convention
- Fix markdown formatting across 10+ files
```

## Edge Cases

**No commits:**

```text
No commits found between base-branch and current branch.
Nothing to describe.
```

**Many commits (>20):**
Group by type and summarize instead of listing all.

**Mixed changes:**
Prioritize by impact (features > fixes > docs > chores).

**Breaking changes:**
Call out explicitly in a separate section:

```text
## ⚠️ Breaking Changes

- API endpoint `/v1/auth` now requires OAuth2 token instead of API key
```

## Integration with GitHub CLI

**Only when --gh flag is provided:**

1. Check if `gh` is installed:

   ```bash
   gh --version
   ```

2. Generate title from first/main commit or summary

3. Create PR:

   ```bash
   gh pr create \
     --title "feat: add OAuth2 authentication support" \
     --body "$(cat <<'EOF'
   [Generated PR description]
   EOF
   )" \
     --base base-branch \
     --head current-branch
   ```

4. Return PR URL

## Notes

- Analyze actual changes, not just commit messages
- Focus on "why" and "what changed", not "how"
- Keep it scannable (bullets, headings)
- Link to issues when applicable (closes #123)
- Be honest about breaking changes
