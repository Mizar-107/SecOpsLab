#!/bin/bash
# 06-install-sealed-secrets.sh - Install Sealed Secrets controller
set -euo pipefail

NAMESPACE="kube-system"

echo "=== Installing Sealed Secrets ==="

# Add Helm repo
echo "[1/3] Adding Helm repo..."
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo update

# Install Sealed Secrets
echo "[2/3] Installing Sealed Secrets controller..."
helm upgrade --install sealed-secrets sealed-secrets/sealed-secrets \
    --namespace ${NAMESPACE} \
    --set fullnameOverride=sealed-secrets-controller \
    --wait

# Verify installation
echo "[3/3] Verifying installation..."
kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/name=sealed-secrets

echo ""
echo "✅ Sealed Secrets installed!"
echo ""
echo "Usage:"
echo "  # Install kubeseal CLI first"
echo "  # brew install kubeseal (macOS)"
echo "  # choco install kubeseal (Windows)"
echo ""
echo "  # Create sealed secret"
echo "  kubectl create secret generic my-secret --dry-run=client -o yaml | \\"
echo "    kubeseal --format yaml > sealed-secret.yaml"
