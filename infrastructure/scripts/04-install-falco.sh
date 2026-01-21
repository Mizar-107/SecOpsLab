#!/bin/bash
# 04-install-falco.sh - Install Falco for runtime security
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAMESPACE="falco"

echo "=== Installing Falco ==="

# Add Helm repo
echo "[1/4] Adding Falco Helm repo..."
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

# Install Falco
echo "[2/4] Installing Falco..."
helm upgrade --install falco falcosecurity/falco \
    --namespace ${NAMESPACE} \
    --create-namespace \
    --set falcosidekick.enabled=true \
    --set falcosidekick.webui.enabled=true \
    --set driver.kind=modern_ebpf \
    --set collectors.docker.enabled=false \
    --set collectors.containerd.enabled=true \
    --set collectors.containerd.socket=/run/containerd/containerd.sock \
    --wait --timeout 300s

# Wait for Falco to be ready
echo "[3/4] Waiting for Falco pods..."
kubectl wait --namespace ${NAMESPACE} \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/name=falco \
    --timeout=180s || echo "⚠️  Falco may take longer to initialize"

# Verify installation
echo "[4/4] Verifying installation..."
kubectl get pods -n ${NAMESPACE}

echo ""
echo "✅ Falco installed!"
echo ""
echo "View Falco logs:"
echo "  kubectl logs -n ${NAMESPACE} -l app.kubernetes.io/name=falco -f"
echo ""
echo "Apply custom rules:"
echo "  kubectl apply -f security/falco/custom-rules.yaml"
