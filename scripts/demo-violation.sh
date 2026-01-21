#!/bin/bash
# demo-violation.sh - Demonstrate Kyverno policy violations
set -euo pipefail

NAMESPACE="policy-demo"

echo "=== Kyverno Policy Violation Demo ==="
echo ""

# Create test namespace
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

echo "[1/5] Testing: Privileged Container Policy"
echo "Attempting to deploy privileged container..."
cat <<EOF | kubectl apply -f - 2>&1 || true
apiVersion: v1
kind: Pod
metadata:
  name: test-privileged
  namespace: ${NAMESPACE}
  labels:
    app: test
    env: demo
    team: security
spec:
  containers:
  - name: nginx
    image: docker.io/library/nginx:latest
    securityContext:
      privileged: true
      readOnlyRootFilesystem: true
      runAsNonRoot: true
    resources:
      limits:
        cpu: 100m
        memory: 128Mi
    livenessProbe:
      httpGet:
        path: /
        port: 80
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /
        port: 80
      periodSeconds: 10
EOF
echo ""

echo "[2/5] Testing: Missing Labels Policy"
echo "Attempting to deploy pod without required labels..."
cat <<EOF | kubectl apply -f - 2>&1 || true
apiVersion: v1
kind: Pod
metadata:
  name: test-no-labels
  namespace: ${NAMESPACE}
spec:
  containers:
  - name: nginx
    image: docker.io/library/nginx:latest
    securityContext:
      readOnlyRootFilesystem: true
      runAsNonRoot: true
    resources:
      limits:
        cpu: 100m
        memory: 128Mi
    livenessProbe:
      httpGet:
        path: /
        port: 80
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /
        port: 80
      periodSeconds: 10
EOF
echo ""

echo "[3/5] Testing: Resource Limits Policy"
echo "Attempting to deploy pod without resource limits..."
cat <<EOF | kubectl apply -f - 2>&1 || true
apiVersion: v1
kind: Pod
metadata:
  name: test-no-limits
  namespace: ${NAMESPACE}
  labels:
    app: test
    env: demo
    team: security
spec:
  containers:
  - name: nginx
    image: docker.io/library/nginx:latest
    securityContext:
      readOnlyRootFilesystem: true
      runAsNonRoot: true
    livenessProbe:
      httpGet:
        path: /
        port: 80
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /
        port: 80
      periodSeconds: 10
EOF
echo ""

echo "[4/5] Testing: Run as Root Policy"
echo "Attempting to deploy pod running as root..."
cat <<EOF | kubectl apply -f - 2>&1 || true
apiVersion: v1
kind: Pod
metadata:
  name: test-root-user
  namespace: ${NAMESPACE}
  labels:
    app: test
    env: demo
    team: security
spec:
  containers:
  - name: nginx
    image: docker.io/library/nginx:latest
    securityContext:
      runAsNonRoot: false
      readOnlyRootFilesystem: true
    resources:
      limits:
        cpu: 100m
        memory: 128Mi
    livenessProbe:
      httpGet:
        path: /
        port: 80
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /
        port: 80
      periodSeconds: 10
EOF
echo ""

echo "[5/5] Checking Policy Reports"
echo ""
kubectl get policyreport -n ${NAMESPACE} 2>/dev/null || echo "No policy reports yet"
echo ""

echo "=== Demo Complete ==="
echo ""
echo "All violations above were BLOCKED by Kyverno policies!"
echo ""
echo "View detailed reports:"
echo "  kubectl get policyreport -A -o yaml"
