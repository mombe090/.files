# GitHub Feature Creator

Quickly create professional GitHub feature request issues using natural language.

## Quick Start

```bash
/feature-gh add dark mode support
```

## What It Does

- Generates well-structured GitHub issues with proper formatting
- Follows best practices from top open-source projects
- Automatically detects your GitHub repository
- Creates issues with appropriate labels

## Prerequisites

```bash
# Install GitHub CLI
brew install gh

# Authenticate
gh auth login
```

## Examples

### Simple Feature

```bash
/feature-gh add dark mode support
```

Creates:

- Title: "Add dark mode support for UI components"
- Sections: Summary, Motivation, Proposed Solution
- Labels: enhancement, feature-request

### Detailed Feature

```bash
/feature-gh add support for importing terraform modules from private git repos using ssh authentication
```

Creates a comprehensive issue with:

- Clear problem statement
- Security justification
- Implementation suggestions
- Related examples

### With Options

```bash
/feature-gh implement rate limiting --assignee @me --milestone v2.0
```

## When to Use

- ✅ Creating new feature requests
- ✅ Proposing enhancements
- ✅ Documenting feature ideas
- ❌ Reporting bugs (use bug report templates instead)
- ❌ Asking questions (use discussions)

## Learn More

See [SKILL.md](./SKILL.md) for complete documentation.
