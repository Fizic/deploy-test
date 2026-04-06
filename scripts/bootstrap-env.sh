#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=== GitOps Repository Bootstrap ==="
echo "Repository root: $REPO_ROOT"

if [ ! -f "$REPO_ROOT/.env" ]; then
    echo "Creating .env from .env.example..."
    cp "$REPO_ROOT/.env.example" "$REPO_ROOT/.env"
    echo "Please edit $REPO_ROOT/.env and fill in the required values."
    exit 1
fi

source "$REPO_ROOT/.env"

echo "Validating required environment variables..."
REQUIRED_VARS=(
    "GLOBAL_DOMAIN"
    "METALLB_LB_RANGE"
    "CERT_MANAGER_EMAIL"
)

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "ERROR: $var is not set"
        exit 1
    fi
done

echo "All required variables are set."
echo ""
echo "Next steps:"
echo "1. Deploy core infrastructure: kubectl apply -k $REPO_ROOT/infrastructure/bootstrap/"
echo "2. Wait for ArgoCD to be ready: kubectl -n argocd get pods"
echo "3. Get ArgoCD admin password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
echo "4. Access ArgoCD UI: https://argocd.$GLOBAL_DOMAIN"
