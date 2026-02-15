---
name: committer
description: Create git commits following Conventional Commits specification (v1.0.0). Use when the user requests to commit changes with commands like "/commit [en|fr]", "commit this", "stage and commit", or when they provide commit direction/context. Supports English (default) and French commit messages. Always handles pre-commit hooks properly by fixing real issues, never using workarounds like --no-verify unless explicitly requested by the user.
model: claude-haiku-4-5-20251001
---

# Committer

## Overview

This skill enables creating well-structured git commits that follow the Conventional Commits specification. It ensures commits are semantic, meaningful, and properly formatted while automatically handling pre-commit hook failures by fixing the underlying issues.

## Commit Workflow

### 1. Analyze Changes

Run these commands in parallel to understand what will be committed:

```bash
git status
git diff --staged
git diff
git log --oneline -5
```

Review all changes (both staged and unstaged) to understand:

- What files were modified
- The nature of changes (new feature, bug fix, refactor, etc.)
- Recent commit message style for consistency


### 2. Determine Commit Type

Based on the changes, select the appropriate conventional commit type:

- **feat**: New feature for the user (e.g., new function, new capability)
- **fix**: Bug fix for the user (patches a bug)
- **docs**: Documentation only changes
- **style**: Code style changes (formatting, missing semi-colons, etc.) - no code logic change
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Performance improvement
- **test**: Adding or updating tests
- **build**: Changes to build system or external dependencies (npm, cargo, etc.)
- **ci**: Changes to CI configuration files and scripts
- **chore**: Other changes that don't modify src or test files (updating dependencies, etc.)
- **revert**: Reverting a previous commit

### 3. Craft Commit Message

Follow this structure:

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Rules:**

- **Type**: Required (see list above)
- **Scope**: Optional, describes section of codebase in parentheses (e.g., `feat(auth):`, `fix(parser):`)
- **Description**: Required, short summary of changes
  - Use imperative mood: "add" not "added" or "adds"
  - Don't capitalize first letter
  - No period at the end
  - Keep under 72 characters
- **Body**: Optional, provides additional context
  - Separated from description by blank line
  - Explain the "why" not the "what"
  - Wrap at 72 characters
- **Footer**: Optional, for breaking changes and issue references
  - `BREAKING CHANGE:` for breaking changes
  - `Refs:` or `Closes:` for issue references

**Examples:**

```text
feat(auth): add OAuth2 authentication support

Implement OAuth2 flow with Google and GitHub providers.
This allows users to sign in using their existing accounts.

Refs: #123
```

```text
fix: prevent race condition in request handling

Introduce a request id and reference to latest request.
Dismiss incoming responses other than from latest request.

Closes: #456
```

```text
docs: update installation instructions
```

```text
chore(deps)!: drop support for Node 14

BREAKING CHANGE: minimum Node version is now 16.0.0
```


### 4. Stage and Commit

**Stage relevant files:**

```bash
git add <files>
```

**Create commit:**

```bash
git commit -m "<type>[scope]: <description>" -m "<body>" -m "<footer>"
```

Or for simple commits:

```bash
git commit -m "<type>[scope]: <description>"
```

**Verify commit:**

```bash
git status
git log -1 --format=full
```

### 5. Handle Pre-commit Hooks


**CRITICAL RULES:**

- **NEVER use --no-verify** unless explicitly requested by user
- **NEVER use --no-gpg-sign** unless explicitly requested
- **NEVER skip hooks** to bypass failures
- **ALWAYS fix the real issue** that caused the hook to fail

**When pre-commit hook fails:**

1. **Read the error message carefully** to understand what failed
2. **Identify the root cause** (linting error, formatting issue, test failure, etc.)
3. **Fix the issue** by modifying the code:
   - Linting errors: Fix code style issues
   - Formatting errors: Run formatter (prettier, black, etc.)
   - Test failures: Fix failing tests or broken code
   - Secrets detected: Remove secrets, use environment variables
   - Trailing whitespace: Remove it
4. **Re-stage the fixes:**

   ```bash
   git add <fixed-files>
   ```

5. **Try commit again** - the hook will re-run automatically
6. **Repeat** until hook passes

**If hook auto-modifies files (e.g., prettier, black):**

The hook may modify files during the commit. If this happens:

```bash
git add <auto-modified-files>
git commit --amend --no-edit
```

**Only use --amend if:**

1. Commit SUCCEEDED but hook auto-modified files, OR
2. User explicitly requested amend, AND
3. Commit was created in this conversation (verify with `git log -1`), AND
4. Commit has NOT been pushed to remote

**If hook FAILED or REJECTED the commit:**

- DO NOT use --amend
- Fix the issue and create a NEW commit attempt


### 6. User Feedback

After successful commit:

- Show the commit message
- Show git status to confirm clean state
- Mention any hook auto-corrections that occurred

If commit failed:

- Explain what failed
- Show what was fixed
- Confirm when ready to retry


## Command: /commit

When user invokes `/commit [language] [direction]`:

### Language Selection

**Syntax:**

- `/commit` - Default to English
- `/commit en` - English (explicit)
- `/commit fr` - French (français)
- `/commit en <direction>` - English with direction
- `/commit fr <direction>` - French with direction

**Language-specific behavior:**

- **English (en)**: Commit messages in English (default)
- **French (fr)**: Commit messages in French

**Examples:**

```text
/commit                          # English (default)
/commit en                       # English (explicit)
/commit fr                       # French
/commit en add user login        # English with direction
/commit fr ajouter connexion     # French with direction
```

### Parsing Arguments

1. **First check for language code** (en/fr)
   - If first argument is `en` or `fr`, use that language
   - Otherwise, default to English

2. **Parse remaining arguments as direction** (optional)
   - Direction can be: commit type, scope, description, or context
   - Examples: `fix auth bug`, `feat: add login`, `"refactor database layer"`

3. **Follow full workflow** above (analyze → determine type → craft message → stage → commit → handle hooks)

4. **Use provided direction** to guide commit message:
   - If type provided: use that type
   - If scope provided: include scope
   - If description provided: use or adapt it
   - If context provided: incorporate into body

5. **Still analyze changes** to ensure direction matches actual changes
   - If mismatch, inform user and suggest correction
   - Example: User says "feat" but only docs changed → suggest "docs" instead


### Language-Specific Commit Messages

**English (default):**

```text
feat(auth): add OAuth2 authentication support

Implement OAuth2 flow with Google and GitHub providers.
This allows users to sign in using their existing accounts.
```

**French:**

```text
feat(auth): ajouter la prise en charge de l'authentification OAuth2

Implémente le flux OAuth2 avec Google et GitHub.
Cela permet aux utilisateurs de se connecter avec leurs comptes existants.
```

**Note**: The commit type and scope remain in English (per Conventional Commits spec), but the description and body are translated to the selected language.

### French Translation Guidelines

When creating French commit messages:

**Description (ligne de sujet):**

- Use imperative mood: "ajouter" not "ajoute" or "a ajouté"
- Keep natural French phrasing
- No capital letter at start (following Conventional Commits)
- No period at end
- Max 72 characters

**Common translations:**

- add → ajouter
- fix → corriger / résoudre
- update → mettre à jour
- remove → supprimer
- refactor → refactoriser
- improve → améliorer
- implement → implémenter

**Body (corps du message):**

- Use complete French sentences
- Explain "pourquoi" (why) not "quoi" (what)
- Use proper French grammar and accents
- Wrap at 72 characters

**Footers:**

- Keep footer tokens in English: `BREAKING CHANGE:`, `Refs:`, `Closes:`
- Footer descriptions can be in French

**Example French commits:**

```text
feat(auth): ajouter l'authentification par empreinte digitale

Permet aux utilisateurs de se connecter en utilisant leur empreinte
digitale sur les appareils compatibles. Améliore la sécurité et
l'expérience utilisateur.

Refs: #456
```

```text
fix(api): corriger la gestion des erreurs de timeout

Les requêtes qui expiraient n'étaient pas correctement gérées,
causant des erreurs non capturées. Ajoute une gestion appropriée
avec réessai automatique.

Closes: #123
```

```text
docs: mettre à jour le guide d'installation
```


## Breaking Changes

When changes introduce breaking changes:

**Option 1: Use `!` after type/scope:**

```text
feat(api)!: redesign authentication endpoint
```

**Option 2: Use footer:**

```text
feat(api): redesign authentication endpoint

BREAKING CHANGE: endpoint now requires OAuth2 token instead of API key
```

**Both options are valid** and can be used together for emphasis.

## Multi-commit Strategy

If changes include multiple unrelated modifications:

1. **Ask user** if they want to split into multiple commits
2. **Stage selectively** using `git add -p` or individual files
3. **Create separate commits** for each logical change
4. **Follow conventional commits** for each

Example:

```bash
# First commit - feature
git add src/feature.js
git commit -m "feat: add user profile page"

# Second commit - fix
git add src/bugfix.js
git commit -m "fix: resolve memory leak in cache"

# Third commit - docs
git add README.md
git commit -m "docs: update API documentation"
```

## References

For complete Conventional Commits specification, see:

- [references/conventional-commits-spec.md](references/conventional-commits-spec.md) - Full v1.0.0 specification

