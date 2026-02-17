# Azure DevOps Feature Creator

Quickly create professional Azure DevOps feature work items using natural language.

## Quick Start

```bash
/feature-az add dark mode support
```

## What It Does

- Generates well-structured Feature work items with proper formatting
- Follows Azure DevOps conventions and best practices
- Automatically detects your Azure DevOps project
- Creates work items with appropriate tags and fields

## Prerequisites

```bash
# Install Azure CLI
brew install azure-cli

# Add DevOps extension
az extension add --name azure-devops

# Authenticate
az login

# Configure defaults
az devops configure --defaults \
  organization=https://dev.azure.com/yourorg \
  project=YourProject
```

## Examples

### Simple Feature

```bash
/feature-az add dark mode support
```

Creates:

- Title: "Add dark mode support for UI components"
- Sections: Summary, Motivation, Proposed Solution, Acceptance Criteria
- Tags: enhancement, feature-request
- Type: Feature

### With Area and Iteration

```bash
/feature-az implement rate limiting --area Frontend --iteration Sprint1
```

Azure DevOps uses area and iteration paths for organization!

### With Assignment and Priority

```bash
/feature-az add api caching --assigned-to john@example.com --fields "Priority=1"
```

## When to Use

- ✅ Creating new feature work items
- ✅ Proposing enhancements for Azure DevOps projects
- ✅ Documenting features with acceptance criteria
- ❌ Reporting bugs (create Bug work items instead)
- ❌ Small tasks (create Task work items instead)

## Azure DevOps Specifics

Azure DevOps uses structured work items instead of issues:

- **Work Item Type**: Feature (for large features)
- **Area Paths**: Organizational structure
- **Iteration Paths**: Sprint/release planning
- **Custom Fields**: Priority, Risk, Effort, etc.
- **Acceptance Criteria**: Included automatically

## Process Templates

Supports all Azure DevOps process templates:

- Agile (default)
- Scrum
- CMMI
- Basic

## Learn More

See [SKILL.md](./SKILL.md) for complete documentation.
