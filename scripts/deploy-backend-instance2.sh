#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
helm upgrade --install backend "$SCRIPT_DIR/../project-exbanka/backend-instance2" \
  -n project-exbanka-instance2 --wait
