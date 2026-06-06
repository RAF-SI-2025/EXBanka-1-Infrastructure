#!/usr/bin/env bash
set -euo pipefail

INSTANCE=${1:-}

usage() {
  echo "Usage: $0 <instance|all|frontend>"
  echo "  $0 instance1       uninstall all releases for instance1"
  echo "  $0 instance2       uninstall all releases for instance2"
  echo "  $0 instance3       uninstall all releases for instance3"
  echo "  $0 all             uninstall everything"
  echo "  $0 frontend        uninstall only the frontend"
  exit 1
}

[ -z "$INSTANCE" ] && usage

uninstall_frontend() {
  echo "==> Uninstalling frontend"
  helm uninstall frontend -n frontend || true
}

uninstall_instance() {
  local name="$1"
  local ns="project-exbanka-$name"

  echo "==> Uninstalling instance: $name (namespace: $ns)"

  for release in backend infrastructure db; do
    helm uninstall "$release" -n "$ns" || true
  done

  echo "==> Done: $name"
}

case "$INSTANCE" in
  frontend)
    uninstall_frontend
    ;;
  all)
    for i in instance1 instance2 instance3; do
      uninstall_instance "$i"
    done
    uninstall_frontend
    ;;
  instance1|instance2|instance3)
    uninstall_instance "$INSTANCE"
    ;;
  *)
    usage
    ;;
esac
