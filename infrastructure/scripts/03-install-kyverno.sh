#!/bin/bash
# 03-install-kyverno.sh - Install Kyverno for admission control
set -euo pipefail

NAMESPACE="kyverno"

echo "=== Installing Kyverno ==="

# Add Helm repo
echo "[1/4] Adding Kyverno Helm repo..."
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

# Install Kyverno
echo "[2/4] Installing Kyverno..."
helm upgrade --install kyverno kyverno/kyverno \
    --namespace ${NAMESPACE} \
    --create-namespace \
    --set replicaCount=1 \
    --set admissionController.replicas=1 \
    --wait

# Install Policy Reporter for visibility
echo "[3/4] Installing Policy Reporter..."
helm repo add policy-reporter https://kyverno.github.io/policy-reporter
helm upgrade --install policy-reporter policy-reporter/policy-reporter \
    --namespace ${NAMESPACE} \
    --set ui.enabled=true \
    --set kyvernoPlugin.enabled=true \
    --wait

# Verify installation
echo "[4/4] Verifying installation..."
kubectl get pods -n ${NAMESPACE}

echo ""
echo "✅ Kyverno installed!"
echo ""
echo "Apply policies with:"
echo "  kubectl apply -f security/kyverno/policies/"
echo ""
echo "View policy reports:"
echo "  kubectl get policyreport -A"
