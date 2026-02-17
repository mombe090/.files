# Shared Feature Request Templates

This directory contains shared templates and guidelines used by all feature creator skills.

## Purpose

To ensure consistency across GitHub, Gitea, and Azure DevOps feature requests, we maintain common formatting and structure templates here.

## Files

### ISSUE_STRUCTURE.md

Defines the standard structure for feature requests:

- Title formatting guidelines
- Body structure (Summary, Motivation, Proposed Solution, etc.)
- Mermaid diagram guidelines
- Smart condensing rules
- Examples by description length

## Usage

All feature creator skills reference these templates:

- **feature-gh** (GitHub)
- **feature-tea** (Gitea)
- **feature-az** (Azure DevOps)

## Design Principles

1. **Platform Agnostic**: Core structure works across all platforms
2. **Markdown First**: Full markdown support including Mermaid diagrams
3. **Succinct**: Keep sections to 1-3 sentences
4. **Actionable**: Clear problem statements and solutions
5. **Scalable**: Works for minimal to detailed descriptions

## Customization

Each platform skill adapts these templates to platform-specific conventions:

- **GitHub**: Standard issues with labels
- **Gitea**: Issues with deadline support
- **Azure DevOps**: Work items with acceptance criteria and custom fields

## Contributing

When updating templates, ensure changes work across all three platforms. Test with:

- Minimal descriptions (3-10 words)
- Moderate descriptions (1-2 sentences)
- Detailed descriptions (multiple paragraphs)
