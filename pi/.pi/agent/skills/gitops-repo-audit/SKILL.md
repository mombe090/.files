---
name: gitops-repo-audit
description: >
  Audit and validate Flux CD GitOps repositories by scanning local repo files (not live clusters) —
  runs Kubernetes schema validation, detects deprecated Flux APIs, reviews RBAC/multi-tenancy/secrets
  management, and produces a prioritized GitOps report. Use when users ask to audit, analyze,
  validate, review, or security-check a GitOps repo.
license: Apache-2.0
compatibility: Requires awk, git, kustomize, kubeconform, flux, yq
---

# Gitops Repo Audit

Load the full skill instructions from `~/.skills/gitops-repo-audit/SKILL.md`.
