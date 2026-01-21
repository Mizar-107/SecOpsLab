#!/bin/bash
# demo-runtime-alert.sh - Trigger Falco runtime alerts
set -euo pipefail

NAMESPACE="runtime-demo"

echo "=== Falco Runtime Alert Demo ==="
echo ""

# Create test namespace and deployment
echo "[1/4] Setting up test environment..."
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-runtime
  namespace: ${NAMESPACE}
  labels:
    app: test-runtime
    env: demo
    team: security
spec:
  containers:
  - name: alpine
    image: docker.io/library/alpine:latest
    command: ["sleep", "3600"]
    securityContext:
      runAsNonRoot: false
    resources:
      limits:
        cpu: 100m
        memory: 128Mi
EOF

echo "Waiting for pod to be ready..."
kubectl wait --for=condition=ready pod/test-runtime -n ${NAMESPACE} --timeout=60s

echo ""
echo "[2/4] Triggering shell alert..."
echo "Executing shell in container (this will trigger Falco)..."
kubectl exec -n ${NAMESPACE} test-runtime -- /bin/sh -c "echo 'Shell executed for demo'"

echo ""
echo "[3/4] Triggering sensitive file read alert..."
kubectl exec -n ${NAMESPACE} test-runtime -- /bin/sh -c "cat /etc/passwd > /dev/null"

echo ""
echo "[4/4] Triggering package manager alert..."
kubectl exec -n ${NAMESPACE} test-runtime -- /bin/sh -c "apk --help > /dev/null 2>&1 || true"

echo ""
echo "=== Demo Complete ==="
echo ""
echo "Check Falco logs for alerts:"
echo "  kubectl logs -n falco -l app.kubernetes.io/name=falco --tail=50"
echo ""
echo "Expected alerts:"
echo "  - Shell Spawned in Container"
echo "  - Sensitive File Read"
echo "  - Package Manager Executed"
echo ""

# Cleanup
echo "Cleaning up..."
kubectl delete pod test-runtime -n ${NAMESPACE} --ignore-not-found
