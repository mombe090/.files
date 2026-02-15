# Feature Creator Skill

A professional GitHub feature request issue creator for OpenCode.

## Overview

The `feature-creator` skill enables you to quickly create well-structured GitHub feature request issues using the `gh` CLI. It follows best practices from popular open-source projects like Next.js, OpenAI Python, and Kubernetes.

## Installation

The skill is installed at: `~/.config/opencode/skills/feature-creator/`

The command is available at: `~/.config/opencode/commands/feature.md`

## Usage

### Basic Command

```bash
/feature <description>
```

### Examples

#### Minimal Description

```bash
/feature add dark mode support
```

Creates an issue with:

- **Title:** "Add dark mode support for UI components"
- **Body:** Includes Summary, Motivation, and Proposed Solution sections

#### Moderate Description

```bash
/feature add support for importing terraform modules from private git repos using ssh authentication
```

Creates a detailed issue with SSH authentication implementation details.

#### Detailed Description

```bash
/feature I need a way to automatically retry failed ansible tasks with exponential backoff. Right now when a task fails due to network issues we have to manually re-run the entire playbook. I'd like to configure retries per task with configurable delays between attempts.
```

Creates a comprehensive issue with all sections including alternatives and additional context.

## Features

### Smart Issue Generation

- **Adaptive structure:** Adjusts detail level based on input length
- **Professional formatting:** Clean markdown with proper sections
- **Succinct content:** Each section limited to 1-3 sentences, max 500 words total
- **Code examples:** Includes syntax examples when relevant

### Best Practices

- ✅ Clear, actionable titles (50-70 characters)
- ✅ Action verb prefixes (Add, Support, Implement, Enable)
- ✅ Problem-focused motivation
- ✅ Concrete solution proposals
- ✅ Bullet points for better scannability
- ✅ Automatic label application

### Repository Detection

- Automatically detects current GitHub repository
- Supports manual repository specification with `--repo owner/repo`
- Validates GitHub authentication status

## Issue Structure

### Minimal (< 10 words input)

```text
## Summary
[2-3 sentence overview]

## Motivation
[Problem statement]

## Proposed Solution
[High-level approach]
```

### Moderate (10-50 words input)

```text
## Summary
[2-3 sentence overview]

## Motivation
[Problem with context]

## Proposed Solution
[Solution with bullet points]

## Additional Context
[Examples/references]
```

### Detailed (> 50 words input)

```text
## Summary
[Clear overview]

## Motivation
[Detailed problem explanation]

## Proposed Solution
[Detailed solution with examples]

## Alternatives Considered
[Other approaches]

## Additional Context
[Screenshots, links, related issues]
```

## Requirements

- **gh CLI:** GitHub command-line tool

  ```bash
  brew install gh
  ```

  Or visit: <https://cli.github.com>

- **Authentication:** Must be authenticated with GitHub

  ```bash
  gh auth login
  ```

- **Repository:** Must be in a GitHub repository or specify with `--repo`

## Error Messages

### gh CLI Not Installed

```text
GitHub CLI (gh) not found.
Install: brew install gh
Or visit: https://cli.github.com
```

### Not Authenticated

```text
Not authenticated with GitHub.
Run: gh auth login
```

### Not in GitHub Repo

```text
Not in a GitHub repository.
Specify repository: /feature <description> --repo owner/repo
```

## Labels

Default labels applied:

- `enhancement` (standard feature request label)

Additional labels suggested based on content:

- `documentation` - if docs mentioned
- `performance` - if optimization related
- `security` - if security/auth related
- `api` - if API changes involved
- `breaking-change` - if backward compatibility affected

## Tips

1. **Provide context:** Give enough detail for OpenCode to understand the problem
2. **Include examples:** Reference existing code or similar features
3. **Be specific:** Clear problem statements lead to better issue structure
4. **Review before creating:** OpenCode will show you the generated issue first

## Integration with OpenCode

This skill integrates seamlessly with OpenCode's command system:

1. Type `/feature` in the OpenCode TUI
2. Add your feature description
3. OpenCode will:
   - Detect your repository
   - Generate a professional issue
   - Create it using gh CLI
   - Return the issue URL

## Customization

You can customize the skill by editing:

- `~/.config/opencode/skills/feature-creator/SKILL.md` - Main skill instructions
- `~/.config/opencode/commands/feature.md` - Command configuration

## Examples from Popular Projects

The skill is based on issue templates from:

- **Next.js** - Structured sections with clear validation requirements
- **OpenAI Python** - Succinct format with context focus
- **Kubernetes** - Comprehensive but organized approach

## Support

For issues or suggestions:

1. Check the skill documentation in `SKILL.md`
2. Review the command configuration in `feature.md`
3. Test with `gh` CLI directly to isolate issues
4. Verify authentication: `gh auth status`

## License

Part of the OpenCode skills ecosystem.
