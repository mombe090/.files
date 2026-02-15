# Conventional Commit Types - Quick Reference

## Primary Types (Required by Spec)

| Type | SemVer | Description | Example |
|------|--------|-------------|---------|
| **feat** | MINOR | New feature for the user | `feat(auth): add OAuth2 login` |
| **fix** | PATCH | Bug fix for the user | `fix(api): handle null responses` |

## Additional Types (Recommended)

| Type | Description | Example |
|------|-------------|---------|
| **build** | Changes to build system or dependencies | `build(npm): upgrade webpack to v5` |
| **chore** | Maintenance tasks, no production code change | `chore: update .gitignore` |
| **ci** | CI configuration and scripts | `ci(github): add automated tests` |
| **docs** | Documentation only | `docs: update README installation` |
| **perf** | Performance improvement | `perf(db): optimize query caching` |
| **refactor** | Code change (no bug fix, no feature) | `refactor(utils): simplify date parsing` |
| **revert** | Revert a previous commit | `revert: rollback database migration` |
| **style** | Code style/formatting (no logic change) | `style: fix indentation in auth.js` |
| **test** | Adding or updating tests | `test(api): add integration tests` |

## Breaking Changes

| Indicator | Usage | Example |
|-----------|-------|---------|
| **!** | After type/scope, before `:` | `feat(api)!: redesign auth endpoint` |
| **BREAKING CHANGE:** | In footer | `BREAKING CHANGE: remove deprecated API` |
| **Both** | Can be used together | Both `!` and footer for emphasis |

**SemVer Impact:** Any type with breaking change → **MAJOR** version bump

## Scopes (Optional)

Add context about which part of codebase changed:

| Format | Example |
|--------|---------|
| `type(scope):` | `feat(auth): add login` |
| `type(scope1,scope2):` | `fix(api,db): sync issues` |
| `type(scope/nested):` | `docs(api/auth): update guide` |

**Common Scopes:**

- `api`, `ui`, `db`, `auth`, `config`, `deps`, `test`, `ci`, `build`
- Project-specific: `parser`, `compiler`, `renderer`, etc.

## Message Format


```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Description Rules

- ✅ Imperative mood: "add" not "added" or "adds"
- ✅ Lowercase first letter
- ✅ No period at end
- ✅ Max 72 characters
- ✅ Focus on "what" not "how"

### Body Rules

- Blank line after description
- Explain "why" not "what"
- Wrap at 72 characters
- Can have multiple paragraphs

### Footer Rules

- Blank line after body
- Format: `Token: value` or `Token #value`
- Common tokens:
  - `BREAKING CHANGE:` - Breaking changes
  - `Refs:` - Reference issues
  - `Closes:` - Close issues
  - `Reviewed-by:` - Reviewers
  - `Acked-by:` - Acknowledgments


## Quick Decision Tree

```text
Is it a new feature? → feat
Is it a bug fix? → fix
Is it ONLY docs? → docs
Is it ONLY formatting? → style
Is it refactoring (no new feature, no fix)? → refactor
Is it performance related? → perf
Is it adding/updating tests? → test
Is it build system/dependencies? → build
Is it CI configuration? → ci
Is it something else (maintenance)? → chore
Are you reverting a commit? → revert
```

## Examples by Type

### feat

```text
feat: add user authentication
feat(api): implement GraphQL endpoint
feat(ui)!: redesign navigation menu
```

### fix

```text
fix: prevent memory leak in cache
fix(parser): handle edge case for arrays
fix(deps): resolve lodash vulnerability
```

### docs

```text
docs: update installation guide
docs(api): add examples for auth endpoints
docs: fix typo in README
```

### style

```text
style: format code with prettier
style(css): fix indentation
style: remove trailing whitespace
```

### refactor

```text
refactor: simplify authentication logic
refactor(db): extract query builder
refactor: use async/await instead of promises
```

### perf

```text
perf: optimize image loading
perf(api): add response caching
perf(db): index frequently queried fields
```

### test

```text
test: add unit tests for auth service
test(api): increase coverage to 90%
test: fix flaky integration test
```

### build

```text
build: upgrade to webpack 5
build(npm): update dependencies
build: configure production optimizations
```

### ci

```text
ci: add GitHub Actions workflow
ci(travis): enable parallel builds
ci: fix deployment script
```

### chore

```text
chore: update .gitignore
chore(deps): bump eslint version
chore: regenerate lock file
```

### revert

```text
revert: rollback authentication changes

Refs: a1b2c3d
```


## Tips

1. **Keep it simple**: Start with just type + description
2. **Add scope** when project has clear modules/components
3. **Use body** for complex changes needing explanation
4. **Mark breaking changes** with `!` or footer
5. **Reference issues** in footer when applicable
6. **Be consistent** with your team's conventions
7. **Think SemVer** - helps with automatic versioning

## Anti-Patterns

❌ `feat: various improvements` → Too vague

✅ `feat(ui): add dark mode toggle`

❌ `fix: fixed the bug` → Redundant, no detail

✅ `fix(parser): handle null input values`

❌ `update README.md` → Missing type

✅ `docs: update installation instructions`

❌ `FEAT: Add new feature` → Wrong case

✅ `feat: add new feature`

❌ `feat: Added user login.` → Wrong tense, period

✅ `feat: add user login`

## Resources

- Spec: <https://www.conventionalcommits.org/>
- Commitlint: <https://commitlint.js.org/>
- Commitizen: <https://github.com/commitizen/cz-cli>

