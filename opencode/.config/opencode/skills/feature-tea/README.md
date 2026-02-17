# Gitea Feature Creator

Quickly create professional Gitea feature request issues using natural language.

## Quick Start

```bash
/feature-tea add dark mode support
```

## What It Does

- Generates well-structured Gitea issues with proper formatting
- Follows best practices from popular projects
- Automatically detects your Gitea repository
- Creates issues with appropriate labels

## Prerequisites

```bash
# Install Gitea CLI
brew install tea

# Configure your Gitea instance
tea login add
```

## Examples

### Simple Feature

```bash
/feature-tea add dark mode support
```

Creates:

- Title: "Add dark mode support for UI components"
- Sections: Summary, Motivation, Proposed Solution
- Labels: enhancement, feature-request

### With Deadline

```bash
/feature-tea implement rate limiting --deadline 2024-12-31
```

Gitea supports due dates on issues!

### With Assignee

```bash
/feature-tea add api caching --assignees johndoe,janedoe
```

## When to Use

- ✅ Creating new feature requests on Gitea
- ✅ Proposing enhancements for self-hosted projects
- ✅ Documenting feature ideas with deadlines
- ✅ Including architecture diagrams with Mermaid
- ❌ Reporting bugs (use bug report templates instead)
- ❌ Asking questions (use discussions if available)

## Important Notes

### Mermaid Diagrams

This skill properly handles Mermaid diagrams in issue descriptions. When using heredoc syntax with `cat <<'EOF'`, the skill ensures:

- ✅ Triple backticks are NOT escaped (renders correctly)
- ✅ Proper markdown formatting is preserved
- ✅ Diagrams display correctly in Gitea's UI

**Example with diagram:**

```bash
/feature-tea add monitoring dashboard with metrics visualization
```

This creates an issue with a properly rendered Mermaid architecture diagram.

## Gitea vs GitHub

Gitea follows a similar model to GitHub with some additions:

- ✅ Deadline support (due dates)
- ✅ Multiple assignees
- ✅ Similar markdown support
- ℹ️ Self-hosted instances

## Learn More

See [SKILL.md](./SKILL.md) for complete documentation.
