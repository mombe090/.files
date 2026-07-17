---
name: fluxtmp-validator
description: >
  Validate all Flux CD templating in the k8s/flux directory using kustomize and
  flux-operator CLI. Runs kustomize build on every kustomization and
  flux-operator build rset on every ResourceSet with matching InputProviders.
  Trigger: /fluxtmp-validate, validate flux templates, check flux manifests,
  flux validation.
---

# Flux Template Validator

Use this skill when the user wants to validate Flux CD manifests, check
templating correctness, or verify that kustomize builds and ResourceSet
renders succeed.

## What it validates

1. **Kustomize build** — runs `kustomize build` on every `kustomization.yaml`
   in `iac/k8s/flux/` to catch broken references, invalid YAML, and
   kustomize-specific errors.

2. **ResourceSet build** — runs `flux-operator build rset` on every
   `*.rset.yaml` (and `*.resourceset.yaml`) file. When a matching
   `*rsetinputprovider.yaml` exists (linked via the
   `craftarc.io/resourceset` label), it passes `--inputs-from-provider` so
   the render includes env-specific values. This catches CEL expression
   errors, missing keys, and schema violations.

## How to run

From the repo root:

```bash
cd iac/k8s/flux && just validate
```

Or invoke the underlying Python script directly:

```bash
# Kustomize only
PYTHONPATH=scripts/src uv run --project . python scripts/.just/src/flux_validate.py kustomize

# ResourceSet only
PYTHONPATH=scripts/src uv run --project . python scripts/.just/src/flux_validate.py rset

# Both (all)
PYTHONPATH=scripts/src uv run --project . python scripts/.just/src/flux_validate.py all
```

## Requirements

- `kustomize` on PATH
- `flux-operator` on PATH
- `uv` for running the validator script

## Output

The validator prints a Rich table with Type / Target / Status / Detail
columns. A failure immediately halts and prints the failing command plus
stderr. Exit code 0 means all checks passed.
