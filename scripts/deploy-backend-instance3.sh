#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
helm upgrade --install backend "$SCRIPT_DIR/../project-exbanka/backend-instance3" \
  -n project-exbanka-instance3 --wait
