#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=== Verifying Infrastructure ==="

echo ""
echo "=== Checking Namespaces ==="
kubectl get namespaces | grep -E 'metallb|ingress-nginx|cert-manager|openebs|argocd|services|monitoring'

echo ""
echo "=== Checking Pods ==="
kubectl get pods -A | grep -v Running | grep -v Completed || echo "All pods running!"

echo ""
echo "=== Checking Storage Classes ==="
kubectl get storageclass

echo ""
echo "=== Checking Ingress Controllers ==="
kubectl get pods -n ingress-nginx
kubectl get ingressclass

echo ""
echo "=== Checking Cert-Manager ==="
kubectl get pods -n cert-manager
kubectl get clusterissuer

echo ""
echo "=== Checking ArgoCD ==="
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server
kubectl get applications -n argocd || echo "No applications yet"

echo ""
echo "=== Checking MetalLB ==="
kubectl get pods -n metallb-system
kubectl get ipaddresspool -n metallb-system || true
kubectl get l2advertisement -n metallb-system || true

echo ""
echo "=== Checking LoadBalancer ==="
kubectl get svc -A | grep LoadBalancer || echo "No LoadBalancer services configured"

echo ""
echo "=== Verifying DNS Configuration ==="
echo "Checking if MetalLB is assigning IPs..."
kubectl get svc -A --field-status.type=LoadBalancer || true

echo ""
echo "=== Summary ==="
echo "If all checks passed, your infrastructure is ready."
echo ""
echo "To check individual services:"
echo "  kubectl get pods -n <namespace>"
echo "  kubectl describe pods -n <namespace>"
echo "  kubectl logs -n <namespace> -l <app-label>"
