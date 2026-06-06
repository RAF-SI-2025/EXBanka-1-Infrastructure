# EXBanka Kubernetes Deployment Guide

This folder contains the Helm charts for deploying EXBanka on a standard Kubernetes cluster
using the **nginx Ingress controller**. No Cloudflare tunnel or custom nginx edge-router is required.

---

## Prerequisites

| Tool | Purpose |
|------|---------|
| `kubectl` | Kubernetes CLI, configured against your cluster |
| `helm` >= 3 | Helm package manager |
| nginx Ingress controller | Routes external traffic into the cluster |
| VPA (optional) | Vertical Pod Autoscaler for automatic resource tuning |

### Install nginx Ingress controller

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```

### Install VPA (optional but recommended)

```bash
git clone https://github.com/kubernetes/autoscaler.git
cd autoscaler/vertical-pod-autoscaler
./hack/vpa-up.sh
```

---

## Container registry secret

All images are pulled from GitHub Container Registry (ghcr.io). Create the pull secret in
**each namespace** before deploying:

```bash
# Replace <USER> and <TOKEN> with your GitHub username and a PAT with read:packages scope
for ns in frontend project-exbanka-instance1 project-exbanka-instance2 project-exbanka-instance3; do
  kubectl create namespace "$ns" --dry-run=client -o yaml | kubectl apply -f -
  kubectl create secret docker-registry ghcr-secret \
    --docker-server=ghcr.io \
    --docker-username=<USER> \
    --docker-password=<TOKEN> \
    -n "$ns"
done
```

---

## Architecture overview

```
Internet
   │
   ▼
nginx Ingress (cluster entrypoint)
   ├── /               ──► frontend namespace  (frontend pod)
   ├── /instance1/...  ──► project-exbanka-instance1 (api-gateway)
   ├── /instance2/...  ──► project-exbanka-instance2 (api-gateway)
   └── /instance3/...  ──► project-exbanka-instance3 (api-gateway)
```

Each bank instance is fully isolated in its own namespace with its own databases,
Kafka, Redis, and microservices.

---

## Deploy

### All at once

```bash
./scripts/deploy.sh all
```

### Individual components

```bash
./scripts/deploy.sh frontend     # frontend only
./scripts/deploy.sh instance1    # bank instance 1 only
./scripts/deploy.sh instance2    # bank instance 2 only
./scripts/deploy.sh instance3    # bank instance 3 only
```

### Backend only (e.g. after a code change)

```bash
./scripts/deploy-backend-instance1.sh
./scripts/deploy-backend-instance2.sh
./scripts/deploy-backend-instance3.sh
```

---

## Configuration

### Setting a hostname

By default the Ingress matches all hosts. To restrict to a specific domain, edit
`project-exbanka/backend-instanceX/values.yaml` and `project-exbanka/frontend/values.yaml`:

```yaml
ingress:
  host: mybank.example.com   # set your domain here
```

### TLS / HTTPS

Add a TLS block to the ingress values. Using cert-manager as an example:

```yaml
ingress:
  host: mybank.example.com
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  tls:
    - hosts:
        - mybank.example.com
      secretName: mybank-tls
```

### Changing the path prefix

The default prefixes are `/instance1`, `/instance2`, `/instance3`.
To change them, edit `ingress.pathPrefix` in the corresponding `backend-instanceX/values.yaml`.

### Image tag / force re-pull

```yaml
global:
  imageTag: "1.2.3"         # pin to a specific tag
  forceRollout: "1715000000" # set to current unix timestamp to force re-pull of latest
```

---

## Uninstall

```bash
./scripts/uninstall.sh all       # remove everything
./scripts/uninstall.sh instance1 # remove one instance
./scripts/uninstall.sh frontend  # remove only frontend
```

---

## Namespace layout

| Namespace | Contents |
|-----------|---------|
| `frontend` | React/Vite frontend SPA |
| `project-exbanka-instance1` | Bank 111 — full microservices stack |
| `project-exbanka-instance2` | Bank 222 — full microservices stack |
| `project-exbanka-instance3` | Bank 333 — full microservices stack |
| `ingress-nginx` | nginx Ingress controller |

---

## Helm chart layout

```
project-exbanka/
├── frontend/            Frontend deployment + service + ingress
├── db/                  PostgreSQL databases (one per microservice)
├── infrastructure/      Kafka, Redis, InfluxDB, Prometheus/Grafana
├── backend/             Generic backend chart (base values)
├── backend-instance1/   Bank 111 overrides (OWN_BANK_CODE=111, pathPrefix=/instance1)
├── backend-instance2/   Bank 222 overrides (OWN_BANK_CODE=222, pathPrefix=/instance2)
└── backend-instance3/   Bank 333 overrides (OWN_BANK_CODE=333, pathPrefix=/instance3)
```
