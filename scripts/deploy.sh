#!/usr/bin/env bash
set -euo pipefail

INSTANCE=${1:-}

usage() {
  echo "Usage: $0 <instance|all|frontend>"
  echo "  $0 instance1       deploy all releases for instance1"
  echo "  $0 instance2       deploy all releases for instance2"
  echo "  $0 instance3       deploy all releases for instance3"
  echo "  $0 all             deploy frontend + all three instances"
  echo "  $0 frontend        deploy only the frontend (namespace: frontend)"
  exit 1
}

[ -z "$INSTANCE" ] && usage

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/.."

deploy_frontend() {
  echo "==> Deploying frontend (namespace: frontend)"
  kubectl create namespace frontend --dry-run=client -o yaml | kubectl apply -f -
  helm upgrade --install frontend "$ROOT/project-exbanka/frontend" \
    -n frontend --wait
}

deploy_instance() {
  local name="$1"
  local ns="project-exbanka-$name"

  echo "==> Deploying instance: $name (namespace: $ns)"

  kubectl create namespace "$ns" --dry-run=client -o yaml | kubectl apply -f -

  helm upgrade --install db             "$ROOT/project-exbanka/db"              -n "$ns"
  helm upgrade --install infrastructure "$ROOT/project-exbanka/infrastructure"  -n "$ns"
  helm upgrade --install backend        "$ROOT/project-exbanka/backend-$name"   -n "$ns" --wait

  echo "==> Done: $name"
}

case "$INSTANCE" in
  frontend)
    deploy_frontend
    ;;
  all)
    deploy_frontend
    for i in instance1 instance2 instance3; do
      deploy_instance "$i"
    done
    ;;
  instance1|instance2|instance3)
    deploy_instance "$INSTANCE"
    ;;
  *)
    usage
    ;;
esac
