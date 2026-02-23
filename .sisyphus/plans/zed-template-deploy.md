# Zed Template Deploy System

## TL;DR

> **Quick Summary**: Add a `templates/zed/settings.json` template file with
> `#{TOKEN}#` placeholders, and a `just deploy_zed` recipe that backs up
> `~/.config/zed/settings.json` to `~/.dotfiles-backup-TIMESTAMP/zed/` then
> deploys the template via `npx replacetokens`, reading token values from env vars
> (loaded from `~/.private.envrc`).
>
> **Deliverables**:
> - `templates/zed/settings.json` — template file with `#{TOKEN}#` placeholders
> - `.just/templates.just` — new Just module with `deploy_zed` recipe
> - `justfile` — updated to import `templates.just`
>
> **Estimated Effort**: Quick (< 20 min)
> **Parallel Execution**: NO — sequential (3 tasks, each depends on prior)
> **Critical Path**: Task 1 → Task 2 → Task 3 → Task 4

---

## Context

### Original Request

User wants:

1. A `templates/zed/` folder at the repo root containing `settings.json`
   with `#{TOKEN}#` placeholders (same as existing pattern)
2. A Just recipe named after the folder (`deploy_zed`) in a new
   `.just/templates.just` module that:
   - Backs up `~/.config/zed/settings.json` to
     `~/.dotfiles-backup-TIMESTAMP/zed/`
   - Uses `npx replacetokens` to replace `#{GITHUB_TOKEN}#` and
     `#{CONTEXT7_API_KEY}#` with values from env, writing to
     `~/.config/zed/settings.json`

### Research Findings

- **Token format**: Repo uses `#{TOKEN}#` convention (see `git/.gitconfig.template`)
- **Backup convention**: `~/.dotfiles-backup-TIMESTAMP/` dir (see `maintenance.just` `backup_create`)
- **Just patterns**: All recipes use `[unix]` tag, `#!/usr/bin/env bash` shebang,
  `_log_*` helpers from `_helpers.just`, `color_*` variables
- **Import pattern**: Main `justfile` imports all `.just/*.just` modules via `import` directives
- **`npx replacetokens`**: The `@qetza/replacetokens` npm package supports `#{TOKEN}#`
  via `--token-pattern default` (which is actually `#{VAR}#` — this is the ADO pattern).
  Correct flag: `--token-prefix '#{'` `--token-suffix '}#'` OR use `--token-pattern default`
  (replacetokens default IS `#{VAR}#`)
- **Existing `zed/.config/zed/settings.json`**: Already has `#{GITHUB_TOKEN}#` and
  `#{CONTEXT7_API_KEY}#` — this is the **deployed** (stow-symlinked) file. The
  `templates/zed/settings.json` is the **source** template (same content).
- **Token values come from**: `~/.private.envrc` sourced in shell — so they are
  available as env vars when the user runs `just deploy_zed` from their shell.

### Key Design Decision

The `zed/.config/zed/settings.json` (stow package) keeps `#{TOKEN}#` placeholders
as committed — it is the **live symlink target** but Zed will receive the placeholder
text until deployed. The `just deploy_zed` recipe **overwrites the symlink target**
(i.e., `~/.config/zed/settings.json` which points to
`~/.files/zed/.config/zed/settings.json`) with token-replaced content.

Wait — this would overwrite the tracked git file with secrets. **Correct approach**:

- `templates/zed/settings.json` = source of truth with placeholders (tracked in git)
- `just deploy_zed` reads FROM `templates/zed/settings.json`, writes TO
  `~/.config/zed/settings.json` directly (NOT through the stow symlink path)
- The stow symlink (`~/.config/zed/settings.json → ~/.files/zed/.config/zed/settings.json`)
  must be **broken first** (or never created for settings.json), OR the recipe writes
  directly to `~/.config/zed/settings.json` after removing the symlink

**Simplest safe approach**: The recipe checks if `~/.config/zed/settings.json` is a
symlink, unlinks it (leaving the repo file intact with placeholders), backs up any
existing real file, then writes the token-replaced output directly to
`~/.config/zed/settings.json` as a real file. This is identical to how `deploy_gitconfig`
works (`~/.gitconfig` is a real file, not a symlink).

---

## Work Objectives

### Core Objective

Create a token-replacement deploy system for Zed settings that mirrors the
`deploy_gitconfig` pattern: template in repo → real deployed file with secrets.

### Concrete Deliverables

- `templates/zed/settings.json` — tracked template with `#{TOKEN}#` placeholders
- `.just/templates.just` — `deploy_zed` recipe
- `justfile` — one new `import` line

### Definition of Done

- [ ] `just deploy_zed` runs without error when `GITHUB_TOKEN` and
      `CONTEXT7_API_KEY` env vars are set
- [ ] `~/.config/zed/settings.json` contains real token values after deploy
- [ ] `~/.dotfiles-backup-TIMESTAMP/zed/settings.json` exists after deploy
- [ ] The repo file `zed/.config/zed/settings.json` still contains `#{TOKEN}#`
      placeholders (not overwritten)
- [ ] `just --list` shows `deploy_zed`

### Must Have

- Backup step before any write
- Clear error if `GITHUB_TOKEN` or `CONTEXT7_API_KEY` env vars are missing
- `npx replacetokens` used (not sed) for token replacement
- Recipe named `deploy_zed` (matches folder name `templates/zed`)
- Module in `.just/templates.just`

### Must NOT Have

- Secrets committed to any tracked file
- Overwriting `zed/.config/zed/settings.json` (the stow package file) with real secrets
- Breaking the stow setup for other zed config files (keymap.json stays symlinked)

---

## Verification Strategy

### Test Decision

- **Infrastructure exists**: NO (no test framework needed for shell scripts)
- **Automated tests**: None — shell recipe verified by agent-executed QA
- **Agent-Executed QA**: YES (mandatory)

---

## Execution Strategy

All tasks are sequential (each depends on the prior).

```
Task 1: Create templates/zed/settings.json
Task 2: Create .just/templates.just with deploy_zed recipe
Task 3: Add import to justfile
Task 4: Commit
```

---

## TODOs

+ [x] 1. Create `templates/zed/settings.json`

  **What to do**:
  - Create directory `templates/zed/` at repo root
  - Create `templates/zed/settings.json` with **identical content** to
    `zed/.config/zed/settings.json` (which already has `#{GITHUB_TOKEN}#`
    and `#{CONTEXT7_API_KEY}#` placeholders)
  - This file is the source template — never deployed directly, only read by
    the `deploy_zed` recipe

  **Must NOT do**:
  - Do not put real token values in this file
  - Do not modify `zed/.config/zed/settings.json`

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential step 1
  - **Blocks**: Task 2
  - **Blocked By**: None

  **References**:
  - `zed/.config/zed/settings.json` — copy this content exactly
  - `git/.gitconfig.template` — same pattern (template with `#{TOKEN}#`)

  **Acceptance Criteria**:
  - [ ] File exists: `templates/zed/settings.json`
  - [ ] File contains `#{GITHUB_TOKEN}#` (not a real token)
  - [ ] File contains `#{CONTEXT7_API_KEY}#` (not a real key)
  - [ ] `cat templates/zed/settings.json | grep '#{GITHUB_TOKEN}#'` → match

  **QA Scenarios**:

  ```
  Scenario: Template file has correct placeholders
    Tool: Bash
    Steps:
      1. grep '#{GITHUB_TOKEN}#' templates/zed/settings.json
      2. grep '#{CONTEXT7_API_KEY}#' templates/zed/settings.json
    Expected Result: both greps exit 0 with matching lines
    Evidence: terminal output
  ```

  **Commit**: NO (group with Task 3)

---

+ [x] 2. Create `.just/templates.just`

  **What to do**:

  Create `/Users/mombe090/.files/.just/templates.just` with the following recipe.
  Follow the **exact coding conventions** of other `.just/*.just` files:
  - Header comment block
  - `[unix]` tag
  - `#!/usr/bin/env bash` + `set -euo pipefail`
  - Use `{{color_*}}` and `_log_*` helpers from `_helpers.just`
  - Use `{{dotfiles_root}}` variable for repo-relative paths
  - Use `{{home}}` variable for `$HOME`

  **Recipe logic** (`deploy_zed`):

  ```
  1. Source ~/.private.envrc if it exists (to load GITHUB_TOKEN, CONTEXT7_API_KEY)
  2. Validate env vars — exit 1 with clear message if either is missing
  3. Create backup dir: BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)/zed"
     mkdir -p "$BACKUP_DIR"
  4. If ~/.config/zed/settings.json exists (real file or symlink):
       cp (dereference) the current effective content to "$BACKUP_DIR/settings.json"
       If it is a symlink: unlink ~/.config/zed/settings.json
         (so we don't overwrite the stow package source)
  5. Ensure ~/.config/zed/ directory exists
  6. Run: npx --yes @qetza/replacetokens \
         --sources "templates/zed/settings.json => $HOME/.config/zed/settings.json" \
         --token-prefix '#{' \
         --token-suffix '}#'
     (replacetokens reads from template, writes to target, replacing #{VAR}# with env var VAR)
  7. Log success with backup path
  ```

  **npx replacetokens exact syntax** (verify with docs if unsure):
  The `@qetza/replacetokens` CLI v2+ syntax is:

  ```bash
  npx --yes @qetza/replacetokens \
    --sources 'templates/zed/settings.json => ~/.config/zed/settings.json' \
    --token-prefix '#{' \
    --token-suffix '}#'
  ```

  Token values are read from environment variables automatically.
  The `--sources` flag uses `input => output` syntax.
  Run from `{{dotfiles_root}}` so relative path `templates/zed/settings.json` resolves correctly.

  **Must NOT do**:
  - Do not use `sed` for replacement (user explicitly wants `npx replacetokens`)
  - Do not write to `zed/.config/zed/settings.json` (stow source)
  - Do not skip the backup step

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential step 2
  - **Blocks**: Task 3
  - **Blocked By**: Task 1

  **References**:
  - `.just/_helpers.just` — all variables (`dotfiles_root`, `home`, `color_*`, `_log_*`)
  - `.just/install.just` — recipe structure pattern with `#!/usr/bin/env bash`
  - `.just/maintenance.just` — backup dir pattern (`~/.dotfiles-backup-*`)
  - `_scripts/unix/tools/deploy-gitconfig.sh` — exact same deploy pattern (env var
    validation, backup, replace, copy to target)
  - `git/.gitconfig.template` — shows `#{TOKEN}#` convention

  **Acceptance Criteria**:
  - [ ] File exists: `.just/templates.just`
  - [ ] Recipe `deploy_zed` is defined with `[unix]` tag
  - [ ] `just --list` (after import in Task 3) shows `deploy_zed`

  **QA Scenarios**:

  ```
  Scenario: Recipe is syntactically valid
    Tool: Bash
    Preconditions: import added to justfile (Task 3 complete)
    Steps:
      1. just --list 2>&1 | grep deploy_zed
    Expected Result: line containing "deploy_zed" printed
    Evidence: terminal output

  Scenario: deploy_zed fails clearly when env vars missing
    Tool: Bash
    Preconditions: GITHUB_TOKEN and CONTEXT7_API_KEY unset
    Steps:
      1. env -u GITHUB_TOKEN -u CONTEXT7_API_KEY just deploy_zed 2>&1 || true
    Expected Result: exit non-zero, error message mentions missing variable
    Evidence: terminal output

  Scenario: deploy_zed succeeds and writes real values
    Tool: Bash
    Preconditions: GITHUB_TOKEN=test_gh_token CONTEXT7_API_KEY=test_ctx7_key set
    Steps:
      1. GITHUB_TOKEN=test_gh_token CONTEXT7_API_KEY=test_ctx7_key just deploy_zed
      2. cat ~/.config/zed/settings.json | grep 'test_gh_token'
      3. cat ~/.config/zed/settings.json | grep 'test_ctx7_key'
      4. ls ~/.dotfiles-backup-*/zed/settings.json
    Expected Result:
      - Step 1 exits 0
      - Steps 2 & 3 find their respective test values
      - Step 4 finds backup file
    Failure Indicators:
      - #{GITHUB_TOKEN}# still present in deployed file (replacement failed)
      - No backup directory created
    Evidence: .sisyphus/evidence/task-2-deploy-zed-success.txt
  ```

  **Commit**: NO (group with Task 3)

---

+ [x] 3. Import `templates.just` in `justfile`

  **What to do**:
  - Open `justfile`
  - Add `import '.just/templates.just'` after the last existing `import` line
    (currently the last import is `import '.just/dev.just'`)
  - No other changes

  **Must NOT do**:
  - Do not reorder or remove existing imports
  - Do not modify any existing recipes

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential step 3
  - **Blocks**: Task 4
  - **Blocked By**: Task 2

  **References**:
  - `justfile` lines 1-11 — existing import block to append to

  **Acceptance Criteria**:
  - [ ] `justfile` contains `import '.just/templates.just'`
  - [ ] `just --list` shows `deploy_zed` without errors

  **QA Scenarios**:

  ```
  Scenario: justfile parses without errors after import
    Tool: Bash
    Steps:
      1. just --list 2>&1
    Expected Result: exit 0, no parse errors, deploy_zed listed
    Evidence: terminal output
  ```

  **Commit**: YES (commits Tasks 1+2+3 together)
  - Message: `feat(templates): add Zed settings deploy system with replacetokens`
  - Body:
    ```
    - Add templates/zed/settings.json as source template with #{TOKEN}# placeholders
    - Add .just/templates.just with deploy_zed recipe:
        1. sources ~/.private.envrc for token env vars
        2. backs up ~/.config/zed/settings.json to ~/.dotfiles-backup-TIMESTAMP/zed/
        3. deploys via npx @qetza/replacetokens to ~/.config/zed/settings.json
    - Import templates.just in main justfile
    ```
  - Files: `templates/zed/settings.json`, `.just/templates.just`, `justfile`
  - Pre-commit: `just --list` (verify parse)

---

## Final Verification Wave

- [ ] F1. **Smoke test** — `quick`

  Run `just --list` and confirm `deploy_zed` appears. Run a dry deploy with dummy
  env vars and confirm backup dir is created and output file contains the dummy values.
  Confirm repo file `zed/.config/zed/settings.json` still has `#{TOKEN}#` placeholders.

---

## Success Criteria

### Verification Commands

```bash
just --list | grep deploy_zed          # Expected: deploy_zed line shown
cat templates/zed/settings.json | grep '#{GITHUB_TOKEN}#'   # Expected: match
cat zed/.config/zed/settings.json | grep '#{GITHUB_TOKEN}#' # Expected: match (stow src unchanged)
GITHUB_TOKEN=x CONTEXT7_API_KEY=y just deploy_zed && cat ~/.config/zed/settings.json | grep '"x"'
# Expected: deployed file contains literal "x" value
```

### Final Checklist

- [ ] `templates/zed/settings.json` exists with `#{TOKEN}#` placeholders
- [ ] `.just/templates.just` exists with `deploy_zed` recipe
- [ ] `justfile` imports `templates.just`
- [ ] `zed/.config/zed/settings.json` (stow source) unchanged — still has placeholders
- [ ] Backup created at `~/.dotfiles-backup-TIMESTAMP/zed/settings.json`
- [ ] Deployed `~/.config/zed/settings.json` has real token values
