#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=== Applying ArgoCD Applications ==="

source "$REPO_ROOT/.env"

echo "1. Creating ArgoCD Projects..."
kubectl apply -f "$REPO_ROOT/argocd/projects/"

echo "2. Waiting for projects to be created..."
sleep 5

echo "3. Applying Core Infrastructure Applications..."
kubectl apply -f "$REPO_ROOT/argocd/apps/core/infrastructure.yaml"

echo "4. Applying Monitoring Applications..."
kubectl apply -f "$REPO_ROOT/argocd/apps/core/monitoring.yaml"

echo "5. Applying Services Applications..."
kubectl apply -f "$REPO_ROOT/argocd/apps/core/services.yaml"

echo ""
echo "=== ArgoCD Applications Applied ==="
echo ""
echo "To check status:"
echo "  kubectl get applications -n argocd"
echo ""
echo "To access ArgoCD UI:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "  Open http://localhost:8080"
echo ""
echo "Default credentials:"
echo "  Username: admin"
echo "  Password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)"
