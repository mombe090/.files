---
name: feature-creator
description: Create well-structured GitHub feature request issues using gh CLI. Use when the user requests to create a feature issue with commands like "/feature <description>", "create feature issue", or "new feature request". Generates professional, succinct issues following best practices from top open-source projects.
model: claude-haiku-4-5-20251001
---

# Feature Creator

## Overview

This skill creates professional GitHub feature request issues using the `gh` CLI. It generates well-structured, succinct issues that follow patterns from popular open-source projects like Next.js, OpenAI Python, and Kubernetes.

## When to Use

- User executes `/feature <description>` command
- User asks to "create a feature issue"
- User requests "new feature request"
- User wants to propose a new capability or improvement

## Workflow

### 1. Parse Input

Extract the feature description from user input:

- Accept short descriptions (3-10 words minimum)
- Accept longer detailed descriptions
- If description is too vague, ask clarifying questions

### 2. Detect Repository Context

Check if we're in a git repository and if it has a GitHub remote:

```bash
# Check if in git repo
git rev-parse --is-inside-work-tree 2>/dev/null

# Get GitHub remote
gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null
```

If not in a GitHub repo, ask user to specify the repository (format: `owner/repo`).

### 3. Generate Issue Structure

Based on best practices from top open-source projects, create a succinct but complete issue:

**Title Format:**

- Clear, actionable statement (50-70 characters)
- Start with action verb: "Add", "Support", "Implement", "Enable"
- Be specific but concise

**Body Structure:**

```markdown
## Summary

[2-3 sentence overview of the feature and its value]

## Motivation

[Why is this feature needed? What problem does it solve?]

## Proposed Solution

[High-level description of how this could work]

## Alternatives Considered

[Optional: Other approaches you've thought about]

## Additional Context

[Optional: Screenshots, mockups, links, examples from other projects]
```

**Smart Condensing Rules:**

- If user provides minimal description → Generate Summary + Motivation
- If user provides moderate description → Generate full structure except Alternatives
- If user provides detailed description → Use full structure
- Always keep each section to 1-3 sentences
- Use bullet points for clarity when listing multiple items

### 4. Create the Issue

Use `gh issue create` with the generated content:

```bash
gh issue create \
  --repo <owner/repo> \
  --title "<generated-title>" \
  --body "<generated-body>" \
  --label "enhancement,feature-request"
```

**Optional flags** (ask user if needed):

- `--assignee <username>` - Assign to someone
- `--milestone <milestone>` - Add to milestone
- `--project <project>` - Add to project board
- `--label <additional-labels>` - Extra labels beyond default

### 5. Confirm Creation

After successful creation:

- Display the issue URL
- Show issue number
- Confirm labels applied

## Examples

### Example 1: Minimal Description

**User Input:**

```text
/feature add dark mode support
```

**Generated Issue:**

**Title:** `Add dark mode support for UI components`

**Body:**

```markdown
## Summary

Add support for dark mode theme across all UI components to improve user experience in low-light environments.

## Motivation

Users working in low-light conditions would benefit from a dark color scheme. This is a commonly requested feature that improves accessibility and reduces eye strain.

## Proposed Solution

Implement a theme toggle that switches between light and dark color palettes, persisting user preference in localStorage.
```

### Example 2: Moderate Description

**User Input:**

```text
/feature add support for importing terraform modules from private git repos using ssh authentication instead of just https
```

**Generated Issue:**

**Title:** `Support SSH authentication for private Git repository module imports`

**Body:**

```markdown
## Summary

Enable Terraform module imports from private Git repositories using SSH authentication as an alternative to HTTPS.

## Motivation

Teams using SSH keys for Git authentication cannot currently import private modules without setting up HTTPS credentials. SSH authentication is more secure for automated workflows and CI/CD pipelines.

## Proposed Solution

- Support `git::ssh://` URL scheme in module sources
- Allow SSH key configuration via environment variables or config files
- Update documentation with SSH authentication examples

## Additional Context

Similar to how Terraform Cloud handles private module sources.
```

### Example 3: Detailed Description

**User Input:**

```text
/feature I need a way to automatically retry failed ansible tasks with exponential backoff. Right now when a task fails due to network issues we have to manually re-run the entire playbook. I'd like to configure retries per task with configurable delays between attempts, maybe using until loops but more intuitive.
```

**Generated Issue:**

**Title:** `Implement automatic task retry with exponential backoff`

**Body:**

```markdown
## Summary

Add native support for automatic task retries with configurable exponential backoff to handle transient failures gracefully.

## Motivation

Network instability and temporary service unavailability cause playbook failures that require manual intervention. Automatic retries would improve reliability in production deployments and CI/CD pipelines.

## Proposed Solution

- Add `retry` directive to task configuration
- Support exponential backoff with configurable base delay
- Allow max retry attempts configuration
- Provide retry conditions (e.g., specific error codes)

Example syntax:
```yaml
- name: Download package
  get_url:
    url: https://example.com/package.tar.gz
    dest: /tmp/package.tar.gz
  retry:
    max_attempts: 5
    backoff: exponential
    base_delay: 2
```

## Alternatives Considered

- Using `until` loops with `retries` - works but verbose and not intuitive
- External retry wrapper scripts - adds complexity outside playbook

## Additional Context

Similar to Kubernetes backoff policies and GitHub Actions retry mechanisms.

## Command Integration

Create an OpenCode command that triggers this skill:

**Command:** `/feature <description>`

**Behavior:**

1. Load the feature-creator skill
2. Parse the argument
3. Execute the workflow above
4. Create the issue and return URL

## Error Handling

### No GitHub Remote

```text
❌ Not in a GitHub repository.

Please specify repository: /feature <description> --repo owner/repo
```

### gh CLI Not Installed

```text
❌ GitHub CLI (gh) not found.

Install with: brew install gh
Or visit: <https://cli.github.com>
```

### gh Not Authenticated

```text
❌ Not authenticated with GitHub.

Run: gh auth login
```

### Issue Creation Failed

```text
❌ Failed to create issue: [error details]

Verify:

- Repository exists and you have write access
- Labels exist in the repository
- Milestone/project exists (if specified)
```

## Best Practices

### Title Guidelines

- ✅ "Add support for custom DNS resolvers"
- ✅ "Implement rate limiting for API endpoints"
- ✅ "Enable multi-region deployment"
- ❌ "DNS thing" (too vague)
- ❌ "We should probably add rate limiting at some point" (not actionable)
- ❌ "Implement comprehensive enterprise-grade multi-region deployment strategy" (too long)

### Body Guidelines

- Be specific about the problem, not just the solution
- Include concrete examples when possible
- Reference related issues or PRs if applicable
- Keep each section focused and brief
- Use code blocks for syntax examples
- Use bullet points for lists (more scannable)

### Label Strategy

Default labels to apply:

- `enhancement` or `feature-request` (standard across projects)

Suggest additional labels based on content:

- `documentation` if docs are mentioned
- `performance` if related to speed/optimization
- `security` if related to vulnerabilities/auth
- `api` if related to API changes
- `breaking-change` if backward compatibility affected

## Configuration

Allow user to set defaults in OpenCode config:

```yaml
skills:
  feature-creator:
    default_repo: "owner/repo"  # Skip repo detection
    default_labels:
      - "enhancement"
      - "needs-triage"
    auto_assign: true  # Assign to authenticated user
    template: "standard"  # or "minimal", "detailed"
```

## Success Criteria

A well-created feature issue should:

- ✅ Have a clear, actionable title
- ✅ Explain the problem/motivation
- ✅ Propose a concrete solution
- ✅ Be succinct (under 500 words)
- ✅ Use proper markdown formatting
- ✅ Include relevant labels
- ✅ Be immediately actionable by maintainers
