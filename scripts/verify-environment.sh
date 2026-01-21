#!/bin/bash
# verify-environment.sh - Verify SecOpsLab environment is ready
set -euo pipefail

echo "=== SecOpsLab Environment Verification ==="
echo ""

ERRORS=0

check_component() {
    local name="$1"
    local namespace="$2"
    local selector="$3"
    
    echo -n "Checking ${name}... "
    if kubectl get pods -n "${namespace}" -l "${selector}" --no-headers 2>/dev/null | grep -q "Running"; then
        echo "✅ Running"
    else
        echo "❌ Not ready"
        ERRORS=$((ERRORS + 1))
    fi
}

# Check cluster connectivity
echo "[1/7] Checking cluster connectivity..."
if kubectl cluster-info &>/dev/null; then
    echo "✅ Cluster is accessible"
    CONTEXT=$(kubectl config current-context)
    echo "   Context: ${CONTEXT}"
else
    echo "❌ Cannot connect to cluster"
    echo "   Run: ./infrastructure/scripts/01-create-cluster.sh"
    exit 1
fi
echo ""

# Check Ingress Controller
echo "[2/7] Checking Ingress Controller..."
check_component "NGINX Ingress" "ingress-nginx" "app.kubernetes.io/component=controller"
echo ""

# Check Argo CD
echo "[3/7] Checking Argo CD..."
check_component "Argo CD Server" "argocd" "app.kubernetes.io/name=argocd-server"
if kubectl get pods -n argocd -l "app.kubernetes.io/name=argocd-server" --no-headers 2>/dev/null | grep -q "Running"; then
    echo "   Access: https://localhost:30080"
fi
echo ""

# Check Kyverno
echo "[4/7] Checking Kyverno..."
check_component "Kyverno" "kyverno" "app.kubernetes.io/component=admission-controller"
if kubectl get clusterpolicies &>/dev/null; then
    POLICY_COUNT=$(kubectl get clusterpolicies --no-headers 2>/dev/null | wc -l)
    echo "   Policies installed: ${POLICY_COUNT}"
fi
echo ""

# Check Falco
echo "[5/7] Checking Falco..."
check_component "Falco" "falco" "app.kubernetes.io/name=falco"
echo ""

# Check Prometheus/Grafana
echo "[6/7] Checking Observability Stack..."
check_component "Prometheus" "monitoring" "app.kubernetes.io/name=prometheus"
check_component "Grafana" "monitoring" "app.kubernetes.io/name=grafana"
if kubectl get pods -n monitoring -l "app.kubernetes.io/name=grafana" --no-headers 2>/dev/null | grep -q "Running"; then
    echo "   Grafana: http://localhost:30300"
fi
echo ""

# Check Sealed Secrets
echo "[7/7] Checking Sealed Secrets..."
check_component "Sealed Secrets" "kube-system" "app.kubernetes.io/name=sealed-secrets"
echo ""

# Summary
echo "=== Verification Summary ==="
if [ ${ERRORS} -eq 0 ]; then
    echo "✅ All components are running!"
    echo ""
    echo "Quick Start:"
    echo "  # Apply Kyverno policies"
    echo "  kubectl apply -f security/kyverno/policies/"
    echo ""
    echo "  # Demo policy violations"
    echo "  ./scripts/demo-violation.sh"
    echo ""
    echo "  # Demo runtime alerts"
    echo "  ./scripts/demo-runtime-alert.sh"
else
    echo "❌ ${ERRORS} component(s) not ready"
    echo ""
    echo "Run the following scripts to install missing components:"
    echo "  ./infrastructure/scripts/01-create-cluster.sh"
    echo "  ./infrastructure/scripts/02-install-argocd.sh"
    echo "  ./infrastructure/scripts/03-install-kyverno.sh"
    echo "  ./infrastructure/scripts/04-install-falco.sh"
    echo "  ./infrastructure/scripts/05-install-observability.sh"
    exit 1
fi
