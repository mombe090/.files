# Committer Skill

The committer skill provides conventional commit support for the dotfiles repository.

## Overview

This OpenCode skill helps you create well-structured git commits following the [Conventional Commits specification v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).

## Features

- **Conventional Commits**: Automatic formatting following the spec
- **Multi-language Support**: English (default) and French commit messages
- **Pre-commit Hook Handling**: Always fixes real issues, never uses workarounds
- **Multi-commit Strategy**: Intelligently splits unrelated changes
- **Breaking Change Support**: Handles breaking changes with `!` or footer
- **Scope Support**: Optional scopes for better context

## Usage

### Using the /commit Command

Invoke the `/commit` command with optional language and direction:

**Basic usage:**

```text
/commit              # English (default)
/commit en           # English (explicit)
/commit fr           # French
```

**With direction:**

```text
/commit fix auth bug
/commit en add user login
/commit fr ajouter connexion utilisateur
/commit "refactor database layer"
```

**Language codes:**

- `en` - English (default if not specified)
- `fr` - French (français)

The skill will:

1. Detect language (defaults to English)
2. Analyze all staged and unstaged changes
3. Review recent commit history for style consistency
4. Determine the appropriate commit type
5. Craft a conventional commit message in the selected language
6. Stage relevant files
7. Create the commit
8. Handle any pre-commit hook failures by fixing the real issues


### Commit Types

- **feat**: New feature (correlates with MINOR in SemVer)
- **fix**: Bug fix (correlates with PATCH in SemVer)
- **docs**: Documentation only changes
- **style**: Code style changes (formatting, no logic change)
- **refactor**: Code change that neither fixes bug nor adds feature
- **perf**: Performance improvement
- **test**: Adding or updating tests
- **build**: Changes to build system or dependencies
- **ci**: Changes to CI configuration
- **chore**: Maintenance tasks
- **revert**: Reverting a previous commit

### Examples

**Simple commit:**

```text
feat(auth): add OAuth2 authentication support
```

**With body:**

```text
fix: prevent race condition in request handling

Introduce a request id and reference to latest request.
Dismiss incoming responses other than from latest request.
```

**Breaking change with `!`:**

```text
feat(api)!: redesign authentication endpoint
```

**Breaking change with footer:**

```text
chore: drop support for Node 14

BREAKING CHANGE: minimum Node version is now 16.0.0
```

### French Examples

**Simple commit:**

```text
feat(auth): ajouter la prise en charge de l'authentification OAuth2
```

**With body:**

```text
fix: corriger la condition de course dans le traitement des requêtes

Introduit un identifiant de requête et une référence à la dernière requête.
Ignore les réponses entrantes autres que celles de la dernière requête.
```

**Breaking change:**

```text
feat(api)!: reconcevoir le point de terminaison d'authentification

BREAKING CHANGE: le point de terminaison nécessite désormais un jeton OAuth2
au lieu d'une clé API.
```

**Documentation:**

```text
docs: mettre à jour les instructions d'installation
```

**Note:** Commit types and scopes remain in English per the Conventional Commits specification. Only the description and body are translated.


## Pre-commit Hook Handling

The skill NEVER uses `--no-verify` or `--no-gpg-sign` workarounds. Instead, it:

1. Reads the error message carefully
2. Identifies the root cause (linting, formatting, tests, secrets, etc.)
3. Fixes the actual issue
4. Re-stages the fixed files
5. Retries the commit

This ensures code quality is maintained and hooks serve their purpose.

## Installation

The skill is located at:

```text
~/.config/opencode/skills/committer/
```

The packaged skill file is:

```text
~/.config/opencode/skills/committer.skill
```

The `/commit` command is configured in:

```text
~/.config/opencode/opencode.jsonc
```

OpenCode will automatically load this skill when you use the `/commit` command.

## Reference

For the complete Conventional Commits specification, see:

- [Official Specification](<https://www.conventionalcommits.org/en/v1.0.0/>)
- [Skill Reference](~/.config/opencode/skills/committer/references/conventional-commits-spec.md)


## Related Tools

- **commitlint**: Linter for commit messages
- **conventional-changelog**: Generate changelogs from commits
- **commitizen**: Interactive commit message CLI
