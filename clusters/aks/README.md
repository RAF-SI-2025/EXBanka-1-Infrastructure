# Flux GitOps — AKS cluster (instance1 + frontend)

This folder holds the [Flux](https://fluxcd.io) manifests that keep the AKS cluster
in sync with the Helm charts in this repo.

## How it works

- `git-repository.yaml` — a `GitRepository` source that **polls `main` every 1 minute**.
- `hr-*.yaml` — one `HelmRelease` per release, each rendering a chart from
  `project-exbanka/` and deploying it to its namespace:

  | HelmRelease     | Chart path                          | Namespace                   |
  |-----------------|-------------------------------------|-----------------------------|
  | `db`            | `project-exbanka/db`                | `project-exbanka-instance1` |
  | `infrastructure`| `project-exbanka/infrastructure`    | `project-exbanka-instance1` |
  | `backend`       | `project-exbanka/backend-instance1` | `project-exbanka-instance1` |
  | `frontend`      | `project-exbanka/frontend`          | `frontend`                  |

When a chart or its values change on `main`, Flux re-renders and runs `helm upgrade`
automatically — usually within ~1 minute of the push.

## Scope

Only **instance1** and the shared **frontend** are managed by Flux. instance2/instance3
are intentionally left out.

## Coexistence with keel

`keel` still auto-updates container images (polls GHCR for new `:latest` digests and
forces a redeploy). Flux drift correction is left **off** (the default), so Flux only
acts on git changes and does not revert keel's image updates. The two do not conflict.

## Install / bootstrap

```bash
# 1. Install the two controllers we use (once per cluster):
flux install --components=source-controller,helm-controller

# 2. Apply the source + releases:
kubectl apply -f clusters/aks/

# 3. Watch:
flux get sources git
flux get helmreleases -A
```
