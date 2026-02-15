# Feature Creator - Quick Start Guide

## What You Just Got

A complete OpenCode skill for creating professional GitHub feature request issues in seconds!

## Files Created

```text
~/.config/opencode/skills/feature-creator/
├── SKILL.md                 # Complete skill documentation
└── README.md               # Usage guide

~/.config/opencode/commands/
└── feature.md              # /feature command implementation
```

## Quick Test

### 1. Verify Installation

```bash
# Check if gh CLI is installed
gh --version

# Check if authenticated
gh auth status

# If not authenticated, login
gh auth login
```

### 2. Navigate to a GitHub Repo

```bash
cd /path/to/your/github/repo
```

### 3. Try the Command in OpenCode

Open OpenCode in that directory:

```bash
opencode
```

Then try these examples:

#### Example 1: Simple Feature

```text
/feature add dark mode support
```

Expected output:

- Title: "Add dark mode support for UI components"
- Creates issue with Summary, Motivation, and Proposed Solution
- Returns issue URL

Expected output:

- Title: "Implement automatic API retry with exponential backoff"
- Creates detailed issue with code examples
- Includes alternatives and additional context
- Returns issue URL

## What Makes It Smart

### 1. Adaptive Detail Level

- **Short description** → Concise issue (Summary + Motivation + Solution)
- **Medium description** → Standard issue (adds Additional Context)
- **Long description** → Comprehensive issue (adds Alternatives Considered)

### 2. Professional Formatting

- Action-oriented titles (Add, Support, Implement, Enable)
- Markdown structure optimized for readability
- Bullet points for multi-part solutions
- Code blocks for syntax examples

### 3. Best Practices from Top Projects

Analyzed and condensed patterns from:

- ✅ **Next.js** - Structured validation and clear sections
- ✅ **OpenAI Python** - Succinct, focused format
- ✅ **Kubernetes** - Comprehensive but organized

### 4. Auto-labeling

- Applies `enhancement` label automatically
- Suggests additional labels based on content:
  - `documentation` if docs mentioned
  - `performance` for optimization features
  - `security` for auth/security features
  - `api` for API-related changes

## Command Options

### Basic Usage

```text
/feature <description>
```

### With Repository (if not in a repo)

```text
/feature <description> --repo owner/repo
```

### Examples in Practice

```bash
# In OpenCode TUI
/feature add webhook support for real-time notifications

# OpenCode will:
# 1. Detect current repo (e.g., "yourname/yourproject")
# 2. Generate professional issue:
#    Title: "Add webhook support for real-time notifications"
#    Body: Summary, Motivation, Proposed Solution
# 3. Create issue via: gh issue create --title "..." --body "..." --label "enhancement"
# 4. Return: ✅ Created issue #42: https://github.com/yourname/yourproject/issues/42
```

## Troubleshooting

### "gh CLI not found"

```bash
# macOS/Linux
brew install gh

# Or download from
<https://cli.github.com>
```

### "Not authenticated"

```bash
gh auth login
# Follow the prompts
```

### "Not in a GitHub repository"

```bash
# Either cd to a GitHub repo, or specify one:
/feature add feature --repo owner/repo
```

## Customization

Want to adjust the skill behavior? Edit these files:

**Change command behavior:**

```bash
code ~/.config/opencode/commands/feature.md
```

**Modify skill instructions:**

```bash
code ~/.config/opencode/skills/feature-creator/SKILL.md
```

## Real-World Example

Let's create an actual feature request:

```bash
# In your project directory
opencode

# In OpenCode TUI
/feature add support for Azure DevOps pipeline integration with automatic build triggering on commit
```

OpenCode will generate:

```text
Title: Support Azure DevOps pipeline integration with automatic builds

## Summary

Enable integration with Azure DevOps Pipelines to automatically trigger builds when commits are pushed to the repository.

## Motivation

Teams using Azure DevOps need seamless CI/CD integration. Manual build triggering reduces productivity and increases deployment friction for development workflows.

## Proposed Solution

- Add Azure DevOps webhook support for commit events
- Configure pipeline triggers via YAML configuration
- Support branch-specific build rules
- Include authentication via Personal Access Tokens (PAT)

## Additional Context

Similar to GitHub Actions and GitLab CI integration patterns.
```

Then creates it:

```text
Created issue #123: https://github.com/you/yourproject/issues/123
```

## Next Steps

1. Test with a simple feature request
2. Review the generated issue on GitHub
3. Adjust the description if needed
4. Share with your team!

## Tips for Best Results

1. **Be specific:** "add dark mode" → "add dark mode toggle with system preference detection"
2. **Mention the problem:** "add export" → "add CSV export because users need offline data analysis"
3. **Include context:** "add API auth" → "add API key authentication similar to how GitHub handles tokens"

Happy feature requesting!
