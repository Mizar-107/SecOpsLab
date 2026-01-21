#!/bin/bash
# 02-install-argocd.sh - Install and configure Argo CD
set -euo pipefail

NAMESPACE="argocd"

echo "=== Installing Argo CD ==="

# Create namespace
echo "[1/4] Creating namespace..."
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

# Install Argo CD
echo "[2/4] Installing Argo CD..."
kubectl apply -n ${NAMESPACE} -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD to be ready
echo "[3/4] Waiting for Argo CD to be ready..."
kubectl wait --namespace ${NAMESPACE} \
    --for=condition=available deployment/argocd-server \
    --timeout=300s

# Patch service to NodePort for local access
echo "[4/4] Configuring access..."
kubectl patch svc argocd-server -n ${NAMESPACE} -p '{"spec": {"type": "NodePort", "ports": [{"port": 443, "nodePort": 30080}]}}'

# Get initial admin password
ARGO_PASSWORD=$(kubectl -n ${NAMESPACE} get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "✅ Argo CD installed!"
echo ""
echo "Access:"
echo "  URL:      https://localhost:30080"
echo "  Username: admin"
echo "  Password: ${ARGO_PASSWORD}"
echo ""
echo "CLI login:"
echo "  argocd login localhost:30080 --username admin --password '${ARGO_PASSWORD}' --insecure"
