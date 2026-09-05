---
name: flux-oci-publish
description: >
  Guides the agent through publishing Flux manifests as an OCI artifact and
  rolling prod onto it. Invoked by /flux-oci-publish, 'publish artifact',
  'push artifact', 'bump flux version', 'update oci source'.
---

# Flux OCI Publish

Run everything from `iac/k8s/flux`. Never commit or push.

## Steps

1. `cd iac/k8s/flux`.
2. Bump the patch version in `.version` (semver, e.g. `1.1.2-beta.18` → `1.1.2-beta.19`).
3. Set the same version in `../plain/flux-operator/flux-instance.prod.yaml` under `spec.sync.ref`.
4. Publish the artifact (validates first): `just push-artifact`.
5. Apply the FluxInstance, or the cluster keeps the old tag:
   `kubectl apply -f ../plain/flux-operator/flux-instance.prod.yaml`.
6. Roll the cluster: `flux reconcile source oci flux-system -n flux-system`.
7. Reconcile the affected ResourceSet(s): `flux-operator -n flux-system reconcile resourceset <nameOfRsetConcerned>`.
8. Verify: `flux get source oci flux-system -n flux-system` shows the new tag Ready; all Kustomizations Ready.

## Troubleshooting

- Reconcile fetched the old tag → re-apply the FluxInstance (step 5).
- Registry auth failure on push → `flux login registry git.prod.home.mombesoft.com --username <user>`.
