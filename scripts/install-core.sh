#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=== Installing Core Infrastructure ==="

source "$REPO_ROOT/.env"

echo "1. Creating namespaces..."
kubectl apply -f "$REPO_ROOT/infrastructure/00-namespaces.yaml"

echo "2. Adding Helm repositories..."
helm repo add metallb https://metallb.github.io/metallb || true
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx || true
helm repo add jetstack https://charts.jetstack.io || true
helm repo add openebs https://openebs.github.io/dynamic-localpv-provisioner || true
helm repo add argo https://argoproj.github.io/argo-helm || true
helm repo update

echo "3. Installing MetalLB..."
helm upgrade --install metallb metallb/metallb \
  --namespace metallb-system \
  --create-namespace \
  --values "$REPO_ROOT/infrastructure/metallb/values.yaml" \
  --wait --timeout 5m

echo "4. Waiting for MetalLB to be ready..."
kubectl rollout status deployment/metallb-controller -n metallb-system --timeout=120s

echo "5. Installing Ingress-Nginx..."
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --values "$REPO_ROOT/infrastructure/ingress-nginx/values.yaml" \
  --wait --timeout 5m

echo "6. Waiting for Ingress-Nginx to be ready..."
kubectl rollout status deployment/ingress-nginx-controller -n ingress-nginx --timeout=120s

echo "7. Installing Cert-Manager..."
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --values "$REPO_ROOT/infrastructure/cert-manager/values.yaml" \
  --set installCRDs=true \
  --wait --timeout 5m

echo "8. Waiting for Cert-Manager to be ready..."
kubectl rollout status deployment/cert-manager -n cert-manager --timeout=120s

echo "9. Creating Cluster Issuers..."
kubectl apply -f "$REPO_ROOT/infrastructure/cert-manager/cluster-issuers.yaml"

echo "10. Installing OpenEBS..."
helm upgrade --install openebs openebs/openebs \
  --namespace openebs \
  --create-namespace \
  --values "$REPO_ROOT/infrastructure/openebs/values.yaml" \
  --wait --timeout 5m

echo "11. Waiting for OpenEBS to be ready..."
kubectl rollout status deployment/openebs-provisioner -n openebs --timeout=120s || true

echo "12. Installing ArgoCD..."
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --values "$REPO_ROOT/infrastructure/argocd/values.yaml" \
  --wait --timeout 5m

echo "13. Waiting for ArgoCD to be ready..."
kubectl rollout status deployment/argocd-server -n argocd --timeout=120s

echo ""
echo "=== Core Infrastructure Installation Complete ==="
echo ""
echo "Next steps:"
echo "1. Get ArgoCD admin password:"
echo "   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
echo ""
echo "2. Access ArgoCD UI:"
echo "   https://argocd.$GLOBAL_DOMAIN"
echo ""
echo "3. Login with admin user and the password from step 1"
echo ""
echo "4. Apply ArgoCD Applications:"
echo "   kubectl apply -f $REPO_ROOT/argocd/projects/"
echo "   kubectl apply -f $REPO_ROOT/argocd/apps/core/"
echo ""
