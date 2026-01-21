#!/bin/bash
# 01-create-cluster.sh - Create Kind cluster for SecOpsLab
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLUSTER_NAME="secopslab"

echo "=== SecOpsLab Cluster Setup ==="

# Check prerequisites
echo "[1/4] Checking prerequisites..."
command -v docker >/dev/null 2>&1 || { echo "❌ Docker is required"; exit 1; }
command -v kind >/dev/null 2>&1 || { echo "❌ Kind is required"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "❌ Helm is required"; exit 1; }
echo "✅ All prerequisites installed"

# Check if cluster exists
echo "[2/4] Checking existing cluster..."
if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
    echo "⚠️  Cluster '${CLUSTER_NAME}' already exists"
    read -p "Delete and recreate? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        kind delete cluster --name "${CLUSTER_NAME}"
    else
        echo "Using existing cluster"
        kubectl cluster-info --context "kind-${CLUSTER_NAME}"
        exit 0
    fi
fi

# Create cluster
echo "[3/4] Creating Kind cluster..."
kind create cluster --config "${SCRIPT_DIR}/../kind/cluster-config.yaml"

# Install ingress controller
echo "[4/4] Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "Waiting for ingress controller to be ready..."
kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=120s

echo ""
echo "✅ SecOpsLab cluster is ready!"
echo ""
echo "Next steps:"
echo "  ./02-install-argocd.sh"
echo "  ./03-install-kyverno.sh"
echo "  ./04-install-falco.sh"
