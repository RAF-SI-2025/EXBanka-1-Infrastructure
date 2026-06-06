#!/usr/bin/env bash
# Wipe all DBs in instance1 (emptyDir, so pod restart = fresh schema)
# and re-run the seeder. Use this when service migrations conflict with existing data.
set -euo pipefail

NS=project-exbanka-instance1
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Wiping all DBs in $NS"
kubectl delete pods -n "$NS" -l 'app in (account-db,auth-db,card-db,client-db,credit-db,exchange-db,notification-db,stock-db,transaction-db,user-db,verification-db)'

echo "==> Restarting all backend services so they reconnect to fresh DBs"
kubectl rollout restart deploy -n "$NS" -l 'app!=account-db,app!=auth-db,app!=card-db,app!=client-db,app!=credit-db,app!=exchange-db,app!=notification-db,app!=stock-db,app!=transaction-db,app!=user-db,app!=verification-db,app!=kafka,app!=redis,app!=influxdb'

echo "==> Re-running seeder via helm upgrade"
kubectl delete job seeder -n "$NS" --ignore-not-found
helm upgrade backend "$ROOT/project-exbanka/backend-instance1" -n "$NS" -f "$ROOT/tls-values.yaml" --force-conflicts

echo "==> Done. Tail seeder logs with:"
echo "    kubectl logs -n $NS job/seeder -f"
