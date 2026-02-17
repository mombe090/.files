# Feature Creator Skills - Platform Comparison

This document compares the three feature creator skills to help you choose the right one.

## Quick Reference

| Command | Platform | CLI Tool | Use When |
|---------|----------|----------|----------|
| `/feature-gh <desc>` | GitHub | `gh` | Working with GitHub repos |
| `/feature-tea <desc>` | Gitea | `tea` | Working with self-hosted Gitea |
| `/feature-az <desc>` | Azure DevOps | `az devops` | Working with Azure DevOps projects |

## Feature Comparison

| Feature | GitHub (gh) | Gitea (tea) | Azure DevOps (az) |
|---------|-------------|-------------|-------------------|
| **CLI Tool** | `gh` | `tea` | `az devops` |
| **Item Type** | Issue | Issue | Work Item (Feature) |
| **Labels/Tags** | ✅ Labels | ✅ Labels | ✅ Tags |
| **Milestones** | ✅ Yes | ✅ Yes | ✅ Iterations |
| **Projects** | ✅ Yes | ❌ Limited | ✅ Area paths |
| **Assignees** | ✅ Single/Multiple | ✅ Multiple | ✅ Single |
| **Deadlines** | ❌ No | ✅ Yes | ✅ Iterations |
| **Custom Fields** | ❌ No | ❌ No | ✅ Yes |
| **Markdown** | ✅ Full | ✅ Full | ✅ Full |
| **Mermaid** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Templates** | ✅ Yes | ✅ Yes | ✅ Work item templates |

## Installation

### GitHub CLI (gh)

```bash
# macOS
brew install gh
gh auth login

# Linux
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh
gh auth login

# Windows
winget install --id GitHub.cli
gh auth login
```

### Gitea CLI (tea)

```bash
# macOS
brew install tea
tea login add

# Linux
go install code.gitea.io/tea@latest
tea login add

# Windows
scoop install tea
tea login add
```

### Azure CLI (az)

```bash
# macOS
brew install azure-cli
az extension add --name azure-devops
az login
az devops configure --defaults organization=https://dev.azure.com/yourorg project=YourProject

# Linux
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az extension add --name azure-devops
az login
az devops configure --defaults organization=https://dev.azure.com/yourorg project=YourProject

# Windows
winget install -e --id Microsoft.AzureCLI
az extension add --name azure-devops
az login
az devops configure --defaults organization=https://dev.azure.com/yourorg project=YourProject
```

## Command Examples

### GitHub

```bash
# Basic
/feature-gh add dark mode support

# With options
/feature-gh implement rate limiting --assignee @me --milestone v2.0 --label api

# Specify repo
/feature-gh add caching --repo owner/repo
```

### Gitea

```bash
# Basic
/feature-tea add dark mode support

# With deadline
/feature-tea implement rate limiting --deadline 2024-12-31

# With assignees
/feature-tea add caching --assignees john,jane
```

### Azure DevOps

```bash
# Basic
/feature-az add dark mode support

# With area and iteration
/feature-az implement rate limiting --area Frontend --iteration Sprint1

# With custom fields
/feature-az add caching --fields "Priority=1" "Risk=Low" --assigned-to john@example.com
```

## Platform Strengths

### GitHub

- **Best for**: Open-source projects, public repositories
- **Strengths**:
  - Largest ecosystem
  - Excellent integrations
  - GitHub Actions workflows
  - Project boards
- **Limitations**:
  - No deadline support on issues
  - Limited custom fields

### Gitea

- **Best for**: Self-hosted projects, private teams
- **Strengths**:
  - Self-hosted control
  - Lightweight and fast
  - Similar to GitHub UX
  - Deadline support
- **Limitations**:
  - Smaller ecosystem
  - Fewer integrations
  - Limited project management features

### Azure DevOps

- **Best for**: Enterprise projects, structured workflows
- **Strengths**:
  - Advanced work item tracking
  - Custom fields and process templates
  - Area and iteration hierarchies
  - Built-in boards and sprints
  - Enterprise integrations
- **Limitations**:
  - More complex setup
  - Requires Azure subscription
  - Steeper learning curve

## Choosing the Right Skill

### Use GitHub (feature-gh) if

- ✅ Working with GitHub repositories
- ✅ Open-source projects
- ✅ Need simple issue tracking
- ✅ Want community visibility

### Use Gitea (feature-tea) if

- ✅ Self-hosted infrastructure
- ✅ Private or internal projects
- ✅ Need deadline tracking on issues
- ✅ Want GitHub-like UX without GitHub

### Use Azure DevOps (feature-az) if

- ✅ Enterprise environment
- ✅ Need structured work item tracking
- ✅ Using Azure DevOps for CI/CD
- ✅ Require custom fields and process templates
- ✅ Want area/iteration hierarchies

## Shared Features

All three skills share:

- ✅ Professional issue/work item generation
- ✅ Mermaid diagram support
- ✅ Smart condensing based on input detail
- ✅ Markdown formatting
- ✅ Repository/project detection
- ✅ Summary, Motivation, Proposed Solution structure

## Migration Between Platforms

If switching platforms, you can easily adapt:

1. The issue structure is compatible across platforms
2. Copy markdown content between systems
3. Adjust platform-specific fields (labels vs tags, etc.)

## Learn More

- [feature-gh Documentation](../feature-gh/SKILL.md)
- [feature-tea Documentation](../feature-tea/SKILL.md)
- [feature-az Documentation](../feature-az/SKILL.md)
- [Shared Templates](../feature-templates/ISSUE_STRUCTURE.md)
