# Conventional Commits v1.0.0 - Full Specification

Source: <https://www.conventionalcommits.org/en/v1.0.0/>

## Summary

The Conventional Commits specification is a lightweight convention on top of commit messages. It provides an easy set of rules for creating an explicit commit history; which makes it easier to write automated tools on top of. This convention dovetails with SemVer, by describing the features, fixes, and breaking changes made in commit messages.

## Commit Message Structure

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Required Elements

1. **type**: A noun describing the change category
   - `fix:` - patches a bug (correlates with PATCH in SemVer)
   - `feat:` - introduces a new feature (correlates with MINOR in SemVer)

2. **description**: A short summary immediately following the colon and space

### Optional Elements

1. **scope**: A noun describing a section of the codebase in parentheses
   - Example: `fix(parser):`

2. **body**: Additional contextual information about changes
   - Must begin one blank line after description
   - Free-form, may consist of multiple newline-separated paragraphs

3. **footer(s)**: Metadata about the commit
   - Must begin one blank line after body
   - Format: `token: value` or `token #value`
   - Use `-` instead of spaces in token (e.g., `Acked-by`)
   - Exception: `BREAKING CHANGE` may be used as-is

4. **!**: Breaking change indicator
   - Placed immediately before `:` in type/scope prefix
   - Example: `feat!:` or `feat(api)!:`

5. **BREAKING CHANGE**: Breaking change footer
   - Must use uppercase text `BREAKING CHANGE:`
   - Followed by description of the breaking change
   - Can be used with or without `!` in prefix

## Additional Types


Beyond `feat` and `fix`, other types are allowed based on Angular convention:

- `build:` - Changes to build system or dependencies
- `chore:` - Maintenance tasks, no production code change
- `ci:` - Changes to CI configuration files and scripts
- `docs:` - Documentation only changes
- `style:` - Code style changes (formatting, no logic change)
- `refactor:` - Code change that neither fixes bug nor adds feature
- `perf:` - Performance improvement
- `test:` - Adding or correcting tests
- `revert:` - Reverting a previous commit

Additional types have no implicit effect in SemVer unless they include BREAKING CHANGE.

## Specification Rules

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" are per RFC 2119.

1. Commits MUST be prefixed with a type (noun: `feat`, `fix`, etc.)
2. Type `feat` MUST be used when adding a new feature
3. Type `fix` MUST be used when representing a bug fix
4. Scope MAY be provided after type (noun in parentheses)
5. Description MUST immediately follow the type/scope prefix
6. Body MAY be provided after description (one blank line after)
7. Body is free-form and MAY consist of multiple paragraphs
8. Footer(s) MAY be provided (one blank line after body)
9. Footer tokens MUST use `-` instead of whitespace (except `BREAKING CHANGE`)
10. Footer values MAY contain spaces and newlines
11. Breaking changes MUST be indicated in type/scope prefix or footer
12. Breaking change footer MUST use uppercase `BREAKING CHANGE:` followed by description
13. Breaking change prefix MUST use `!` immediately before `:`
14. If `!` is used, `BREAKING CHANGE:` MAY be omitted from footer
15. Types other than `feat` and `fix` MAY be used
16. Information units MUST NOT be case sensitive (except `BREAKING CHANGE` must be uppercase)
17. `BREAKING-CHANGE` MUST be synonymous with `BREAKING CHANGE`

## Examples

### Commit with description and breaking change footer

```text
feat: allow provided config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

### Commit with ! to draw attention to breaking change

```text
feat!: send an email to the customer when a product is shipped
```

### Commit with scope and exclamation mark

```text
feat(api)!: send an email to the customer when a product is shipped
```


### Commit with both ! and BREAKING CHANGE footer

```text
chore!: drop support for Node 6

BREAKING CHANGE: use JavaScript features not available in Node 6.
```

### Commit with no body

```text
docs: correct spelling of CHANGELOG
```

### Commit with scope

```text
feat(lang): add Polish language
```

### Commit with multi-paragraph body and multiple footers

```text
fix: prevent racing of requests

Introduce a request id and a reference to latest request. Dismiss
incoming responses other than from latest request.

Remove timeouts which were used to mitigate the racing issue but are
obsolete now.

Reviewed-by: Z
Refs: #123
```

### Revert commit

```text
revert: let us never again speak of the noodle incident

Refs: 676104e, a215868
```


## Why Use Conventional Commits

- Automatically generate CHANGELOGs
- Automatically determine semantic version bumps
- Communicate nature of changes to teammates and stakeholders
- Trigger build and publish processes
- Make it easier for people to contribute

## FAQ

### Initial development phase

Proceed as if you've already released. Someone is using your software and needs to know what changed.

### Types uppercase or lowercase

Any casing may be used, but be consistent.

### Commit conforms to multiple types

Make multiple commits whenever possible. This drives more organized commits and PRs.

### Rapid development conflict

Conventional Commits doesn't discourage rapid development - it discourages moving fast in a disorganized way. It helps you move fast long-term.

### Limit commit types

The specification encourages more of certain types (fixes, features) while allowing flexibility to define custom types.

### Relation to SemVer

- `fix` type → PATCH release
- `feat` type → MINOR release
- `BREAKING CHANGE` (any type) → MAJOR release

### Wrong commit type used

**Before merging/releasing:**
Use `git rebase -i` to edit commit history.

**After release:**
Cleanup depends on tools and processes used. In worst case, a non-conforming commit just won't be recognized by automated tools.

### All contributors need to use it

No. With squash-based workflow, lead maintainers can clean up messages during merge. No workload added to casual committers.

### Revert commits

Conventional Commits doesn't define explicit revert behavior. Recommendation: use `revert` type with footer referencing reverted commit SHAs.

```text
revert: let us never again speak of the noodle incident

Refs: 676104e, a215868
```

