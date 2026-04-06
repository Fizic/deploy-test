#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=== Updating ArgoCD Applications ==="

echo "Refreshing all applications..."
for app in $(kubectl get applications -n argocd -o jsonpath='{.items[*].metadata.name}'); do
    echo "Refreshing: $app"
    argocd app refresh "$app" --quiet || echo "  (argocd CLI not available, skipping refresh)"
done

echo ""
echo "Syncing all applications..."
kubectl apply -f "$REPO_ROOT/argocd/apps/core/infrastructure.yaml"
kubectl apply -f "$REPO_ROOT/argocd/apps/core/monitoring.yaml"
kubectl apply -f "$REPO_ROOT/argocd/apps/core/services.yaml"

echo ""
echo "Done. Check ArgoCD UI for sync status."
