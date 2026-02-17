# Feature Creator Skills - Migration Complete

## Summary of Changes

Successfully reorganized feature creator skills following Anthropic's best practices:

### ✅ Completed Actions

1. **Removed** old `feature-creator` skill directory
2. **Created** three focused, platform-specific skills
3. **Updated** all commands to use unique slash commands
4. **Documented** shared templates and platform comparison

## New Skill Structure

```text
skills/
├── feature-gh/              # GitHub skill
│   ├── README.md           # Quick start guide
│   └── SKILL.md            # Full documentation
├── feature-tea/            # Gitea skill
│   ├── README.md           # Quick start guide
│   └── SKILL.md            # Full documentation
├── feature-az/             # Azure DevOps skill
│   ├── README.md           # Quick start guide
│   └── SKILL.md            # Full documentation
└── _shared/                # Shared resources
    ├── PLATFORM_COMPARISON.md
    └── feature-templates/
        ├── ISSUE_STRUCTURE.md
        └── README.md
```

## New Commands

| Old Format | New Format | Platform |
|------------|------------|----------|
| `/feature gh <desc>` | `/feature-gh <desc>` | GitHub |
| `/feature tea <desc>` | `/feature-tea <desc>` | Gitea |
| `/feature az <desc>` | `/feature-az <desc>` | Azure DevOps |

## Usage Examples

### GitHub

```bash
/feature-gh add dark mode support
/feature-gh implement rate limiting --assignee @me --milestone v2.0
```

### Gitea

```bash
/feature-tea add dark mode support
/feature-tea implement rate limiting --deadline 2024-12-31
```

### Azure DevOps

```bash
/feature-az add dark mode support
/feature-az implement rate limiting --area Frontend --iteration Sprint1
```

## Benefits of New Structure

### 1. Clearer Intent

Each command explicitly states the target platform:

- `/feature-gh` → Obviously GitHub
- `/feature-tea` → Obviously Gitea
- `/feature-az` → Obviously Azure DevOps

### 2. Better Model Loading

- Each skill loads only platform-specific context
- Reduced token usage per invocation
- Faster skill activation

### 3. Independent Skills

- Update one platform without affecting others
- Platform-specific error messages
- Dedicated CLI command documentation
- Isolated testing per platform

### 4. Shared Best Practices

- Common issue structure in `_shared/feature-templates/`
- Consistent formatting across platforms
- Reusable Mermaid diagram guidelines

## Verification

All skills verified:

- ✅ Skill names: `feature-gh`, `feature-tea`, `feature-az`
- ✅ Commands updated: `/feature-gh`, `/feature-tea`, `/feature-az`
- ✅ Documentation consistent across all skills
- ✅ Shared templates in `_shared/`
- ✅ Platform comparison document available

## Next Steps

Users should:

1. **Use new commands** immediately with `/feature-gh|tea|az <description>`
2. **Configure platform defaults** in OpenCode config (optional)
3. **Read platform comparison** at `_shared/PLATFORM_COMPARISON.md`
4. **Refer to README** in each skill for quick start examples

## Migration Notes

- **No backward compatibility** with old `/feature gh|tea|az` format
- Old `feature-creator` skill has been removed
- New commands are clearer and more intuitive
- Each skill is now independently invocable

The migration follows **Anthropic's skill design principles**:

1. ✅ **Single Responsibility**: Each skill handles one platform
2. ✅ **Clear Naming**: Command names match skill purpose
3. ✅ **Minimal Context**: Only load what's needed
4. ✅ **Shared Resources**: Common patterns in `_shared/`
5. ✅ **Independence**: Skills don't depend on each other

---

**Date**: February 16, 2026
**Status**: Complete
**Skills Created**: 3 (feature-gh, feature-tea, feature-az)
**Shared Resources**: 3 files
