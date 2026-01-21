#!/bin/bash
# 05-install-observability.sh - Install Prometheus + Grafana
set -euo pipefail

NAMESPACE="monitoring"

echo "=== Installing Observability Stack ==="

# Add Helm repos
echo "[1/4] Adding Helm repos..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack
echo "[2/4] Installing Prometheus + Grafana..."
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
    --namespace ${NAMESPACE} \
    --create-namespace \
    --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
    --set grafana.adminPassword=secopslab \
    --set grafana.service.type=NodePort \
    --set grafana.service.nodePort=30300 \
    --wait --timeout 300s

# Wait for pods
echo "[3/4] Waiting for pods to be ready..."
kubectl wait --namespace ${NAMESPACE} \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/name=grafana \
    --timeout=180s

# Verify installation
echo "[4/4] Verifying installation..."
kubectl get pods -n ${NAMESPACE}

echo ""
echo "✅ Observability stack installed!"
echo ""
echo "Grafana Access:"
echo "  URL:      http://localhost:30300"
echo "  Username: admin"
echo "  Password: secopslab"
echo ""
echo "Prometheus:"
echo "  kubectl port-forward -n ${NAMESPACE} svc/prometheus-kube-prometheus-prometheus 9090:9090"
