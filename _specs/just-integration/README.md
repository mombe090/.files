# Just Integration Documentation

This directory contains the MkDocs Material documentation for the Just integration specification.

## Structure

```
specs/just-integration/
└── 2026-02-04/
    └── specification.md    # Original dated specification

docs/
├── index.md                # Main landing page
├── stylesheets/
│   └── extra.css           # Catppuccin-inspired theme
└── specs/just-integration/
    ├── specification.md    # Copy of main spec
    ├── architecture.md     # Architecture details
    ├── recipes.md          # Recipe reference (TODO)
    ├── implementation.md   # Implementation plan (TODO)
    ├── getting-started/    # Getting started guides (TODO)
    ├── usage/              # Usage examples (TODO)
    ├── development/        # Development docs (TODO)
    └── reference/          # Technical reference (TODO)

mkdocs.yml                  # MkDocs configuration at root
```

## Running the Documentation

### Prerequisites

Install MkDocs Material and required plugins:

```bash
# Using pip
pip install mkdocs-material mkdocs-git-revision-date-localized-plugin

# Or using mise (if Python is managed by mise)
mise exec pip install mkdocs-material mkdocs-git-revision-date-localized-plugin
```

### Local Development

```bash
# Serve docs locally with live reload
mkdocs serve

# Open browser to http://127.0.0.1:8000
```

### Build Static Site

```bash
# Build static site to site/ directory
mkdocs build

# The site/ directory contains the complete static site
```

### Deploy to GitHub Pages

```bash
# Deploy to GitHub Pages (gh-pages branch)
mkdocs gh-deploy

# Or with custom commit message
mkdocs gh-deploy -m "docs: update just integration spec"
```

## Customization

### Theme Colors

The theme uses Catppuccin Frappe colors defined in `docs/stylesheets/extra.css`.

To customize:
1. Edit color variables in `docs/stylesheets/extra.css`
2. Modify palette in `mkdocs.yml`

### Adding Pages

1. Create markdown file in appropriate `docs/` subdirectory
2. Add to navigation in `mkdocs.yml` under `nav:` section
3. Run `mkdocs serve` to preview

Example:
```yaml
nav:
  - New Page: path/to/newpage.md
```

### Plugins

Configured plugins:
- **search**: Full-text search
- **git-revision-date-localized**: Shows last updated dates

To add more plugins, see [MkDocs Material Plugins](https://squidfunk.github.io/mkdocs-material/plugins/).

## Features Enabled

### Markdown Extensions

- ✅ Code highlighting with line numbers
- ✅ Mermaid diagrams
- ✅ Tabbed content
- ✅ Task lists
- ✅ Emojis
- ✅ Admonitions
- ✅ Table of contents

### Navigation Features

- ✅ Instant loading
- ✅ Navigation tabs
- ✅ Section expansion
- ✅ Breadcrumb path
- ✅ Back to top button
- ✅ Search suggestions

## Using Just Commands (Future)

Once Just integration is implemented:

```bash
# Serve documentation
just docs_serve

# Build documentation
just docs_build

# Deploy documentation
just docs_deploy
```

## TODO

Documentation pages to create:

- [ ] `recipes.md` - Complete recipe reference
- [ ] `implementation.md` - Implementation timeline
- [ ] `getting-started/installation.md` - Install just and setup
- [ ] `getting-started/quickstart.md` - Quick start guide
- [ ] `getting-started/bootstrap.md` - Bootstrap process
- [ ] `usage/workflows.md` - Common workflows
- [ ] `usage/examples.md` - Recipe examples
- [ ] `usage/troubleshooting.md` - Troubleshooting guide
- [ ] `development/contributing.md` - Contribution guide
- [ ] `development/testing.md` - Testing guide
- [ ] `development/decisions.md` - Design decisions
- [ ] `reference/modules.md` - Module reference
- [ ] `reference/variables.md` - Variables reference
- [ ] `reference/errors.md` - Error handling reference

## License

MIT License - Same as the parent dotfiles repository.
