# Committer Skill - Usage Examples

## Example 1: Simple Feature Commit

**User Input:**

```text
/commit add new user profile page
```

**Skill Actions:**

1. Runs `git status`, `git diff --staged`, `git diff`, `git log -5`
2. Analyzes changes: sees new React component, routes, styles
3. Determines type: `feat`
4. Suggests scope: `ui` or `profile`
5. Crafts message: `feat(profile): add user profile page`

**Result:**

```bash
git add src/components/Profile.jsx src/routes.js src/styles/profile.css
git commit -m "feat(profile): add user profile page"
```


---

## Example 2: Bug Fix with Body

**User Input:**

```text
/commit fix memory leak in cache
```

**Skill Actions:**

1. Analyzes changes in cache management code
2. Type: `fix`
3. Scope: `cache`
4. Adds explanatory body

**Result:**

```bash
git add src/cache/manager.js
git commit -m "fix(cache): resolve memory leak in cache cleanup

Implement proper cleanup of event listeners when cache entries
are evicted. This prevents listeners from accumulating over time
and consuming memory."
```


---

## Example 3: Breaking Change

**User Input:**

```text
/commit redesign authentication API
```

**Skill Actions:**

1. Detects API signature changes
2. Type: `feat` (new API design)
3. Scope: `api`
4. Breaking change: `!` indicator

**Result:**

```bash
git add src/api/auth.js
git commit -m "feat(api)!: redesign authentication endpoint

BREAKING CHANGE: endpoint now requires OAuth2 token instead of API key.
Update your API calls to use the new authentication flow."
```


---

## Example 4: Pre-commit Hook Failure

**Scenario:** Prettier hook fails due to formatting

**User Input:**

```text
/commit add login form validation
```

**Skill Actions:**

1. Creates commit: `feat(auth): add login form validation`
2. Pre-commit hook runs prettier and **FAILS**
3. Skill reads error: "File src/LoginForm.jsx needs formatting"
4. Runs: `prettier --write src/LoginForm.jsx`
5. Re-stages: `git add src/LoginForm.jsx`
6. Retries commit (hook succeeds this time)

**User Sees:**

```text
Pre-commit hook failed: prettier found formatting issues
Fixed formatting in src/LoginForm.jsx
Re-staged fixed files
Commit created successfully!
```


---

## Example 5: Multiple Unrelated Changes

**User Input:**

```text
/commit
```

**Skill Actions:**

1. Analyzes changes:
   - New feature in `src/dashboard.js`
   - Bug fix in `src/utils.js`
   - Docs update in `README.md`
2. Asks: "I see 3 unrelated changes. Create separate commits?"
3. User confirms
4. Creates 3 commits:

**Result:**

```bash
# Commit 1
git add src/dashboard.js
git commit -m "feat(dashboard): add analytics widget"

# Commit 2
git add src/utils.js
git commit -m "fix(utils): handle null values in parseDate"

# Commit 3
git add README.md
git commit -m "docs: update installation instructions"
```


---

## Example 6: Chore with Scope

**User Input:**

```text
/commit update dependencies
```

**Skill Actions:**

1. Sees package.json and package-lock.json changes
2. Type: `chore`
3. Scope: `deps`

**Result:**

```bash
git add package.json package-lock.json
git commit -m "chore(deps): update eslint and prettier to latest versions"
```


---

## Example 7: Documentation Only

**User Input:**

```text
/commit fix typos in API docs
```

**Skill Actions:**

1. Analyzes: only .md files changed
2. Type: `docs`
3. No scope needed

**Result:**

```bash
git add docs/api/*.md
git commit -m "docs: correct typos in API documentation"
```


---

## Example 8: Revert Commit

**User Input:**

```text
/commit revert the database migration
```

**Skill Actions:**

1. Type: `revert`
2. Finds commit SHA being reverted
3. References it in footer

**Result:**

```bash
git add db/migrations/*.sql
git commit -m "revert: rollback database schema changes

Refs: 676104e"
```


---

## Key Behaviors

### Always Does

- Analyzes ALL changes (staged and unstaged)
- Reviews recent commit history for style consistency
- Fixes pre-commit hook failures by addressing root cause
- Suggests meaningful commit messages based on code changes
- Uses conventional commit format

### Never Does

- Use `--no-verify` to bypass hooks
- Use `--no-gpg-sign` to skip signing
- Skip hooks to force commits through
- Create vague commit messages
- Commit without analyzing changes

### Asks User When

- Multiple unrelated changes detected
- Commit type doesn't match changes (e.g., user says "feat" but only docs changed)
- Breaking change detected but user didn't indicate it
- Unclear what scope should be


---

## French Language Examples

### Example 9: Feature in French

**User Input:**

```text
/commit fr ajouter page de profil utilisateur
```

**Skill Actions:**

1. Detects language: French
2. Analyzes changes: new React component, routes, styles
3. Type: `feat`
4. Scope: `profile`
5. Crafts French message

**Result:**

```bash
git add src/components/Profile.jsx src/routes.js src/styles/profile.css
git commit -m "feat(profile): ajouter la page de profil utilisateur"
```


---

### Example 10: Bug Fix in French with Body

**User Input:**

```text
/commit fr corriger la fuite mémoire dans le cache
```

**Skill Actions:**

1. Language: French
2. Analyzes cache management code
3. Type: `fix`
4. Scope: `cache`
5. Adds French explanatory body

**Result:**

```bash
git add src/cache/manager.js
git commit -m "fix(cache): corriger la fuite mémoire dans le nettoyage du cache

Implémente un nettoyage approprié des écouteurs d'événements lorsque
les entrées du cache sont supprimées. Cela empêche l'accumulation
des écouteurs au fil du temps et la consommation de mémoire."
```


---

### Example 11: Breaking Change in French

**User Input:**

```text
/commit fr reconcevoir l'API d'authentification
```

**Skill Actions:**

1. Language: French
2. Detects API signature changes
3. Type: `feat`
4. Scope: `api`
5. Breaking change: `!` indicator
6. French description and body

**Result:**

```bash
git add src/api/auth.js
git commit -m "feat(api)!: reconcevoir le point de terminaison d'authentification

BREAKING CHANGE: le point de terminaison nécessite désormais un jeton
OAuth2 au lieu d'une clé API. Mettez à jour vos appels API pour utiliser
le nouveau flux d'authentification."
```


---

### Example 12: Documentation in French

**User Input:**

```text
/commit fr mettre à jour la documentation
```

**Skill Actions:**

1. Language: French
2. Sees only .md files changed
3. Type: `docs`
4. Simple French description

**Result:**

```bash
git add docs/**/*.md
git commit -m "docs: mettre à jour le guide d'installation"
```


---

### Example 13: Mixed Language Context

**User Input:**

```text
/commit fr
```

(No direction provided, changes are in code with comments)

**Skill Actions:**

1. Language: French
2. Analyzes changes: bug fix in validation
3. Auto-detects type: `fix`
4. Auto-detects scope: `validation`
5. Crafts appropriate French message

**Result:**

```bash
git add src/validation/form.js
git commit -m "fix(validation): gérer correctement les valeurs nulles

Les champs de formulaire avec des valeurs nulles causaient des erreurs
non gérées. Ajoute une validation appropriée pour les cas limites."
```


---

## Language Selection Notes

### Default Behavior

- No language specified → **English** (default)
- `/commit` = `/commit en`

### Explicit Language

- `/commit en` → English
- `/commit fr` → French (français)

### What Gets Translated

✅ **Translated:**

- Commit description (subject line)
- Commit body (detailed explanation)
- Footer descriptions (after `BREAKING CHANGE:`, etc.)

❌ **Not Translated:**

- Commit type (`feat`, `fix`, `docs`, etc.)
- Scope names (should be code-related: `auth`, `api`, `db`)
- Footer tokens (`BREAKING CHANGE:`, `Refs:`, `Closes:`)

**Why?** The Conventional Commits specification requires types and scopes in English for tool compatibility and automation.

