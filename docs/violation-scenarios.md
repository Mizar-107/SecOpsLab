# Violation Scenarios

This document describes how to demonstrate security controls by triggering violations.

---

## Admission Control Violations (Kyverno)

### Privileged Container Blocked

**Scenario:** Deploy a privileged container

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-privileged
  labels:
    app: test
    env: demo
    team: security
spec:
  containers:
  - name: nginx
    image: docker.io/library/nginx
    securityContext:
      privileged: true
EOF
```

**Expected:** Blocked with message "Privileged containers are not allowed"

---

### Missing Labels Blocked

**Scenario:** Deploy pod without required labels

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-no-labels
spec:
  containers:
  - name: nginx
    image: docker.io/library/nginx
EOF
```

**Expected:** Blocked with message "Label 'app' is required"

---

### No Resource Limits Blocked

**Scenario:** Deploy pod without resource limits

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-no-limits
  labels:
    app: test
    env: demo
    team: security
spec:
  containers:
  - name: nginx
    image: docker.io/library/nginx
EOF
```

**Expected:** Blocked with message "CPU and memory limits are required"

---

## Runtime Detection (Falco)

### Shell Spawned Alert

**Scenario:** Execute shell in running container

```bash
# Create test pod
kubectl run test --image=alpine --command -- sleep 3600

# Wait for pod
kubectl wait --for=condition=ready pod/test

# Trigger shell alert
kubectl exec -it test -- /bin/sh

# Check Falco logs
kubectl logs -n falco -l app.kubernetes.io/name=falco --tail=20
```

**Expected Alert:** "Shell spawned in container"

---

### Sensitive File Access Alert

**Scenario:** Read /etc/passwd in container

```bash
kubectl exec test -- cat /etc/passwd
```

**Expected Alert:** "Sensitive file read"

---

### Package Manager Alert

**Scenario:** Run package manager in container

```bash
kubectl exec test -- apk --help
```

**Expected Alert:** "Package manager executed in container"

---

## Demo Scripts

Use the included demo scripts for automated demonstrations:

```bash
# Kyverno policy violations
./scripts/demo-violation.sh

# Falco runtime alerts
./scripts/demo-runtime-alert.sh

# Image signature verification
./scripts/verify-signature.sh ghcr.io/yourorg/image:tag
```

---

## Viewing Results

### Kyverno Policy Reports
```bash
kubectl get policyreport -A
kubectl get policyreport -A -o yaml | grep -A5 "results:"
```

### Falco Events
```bash
kubectl logs -n falco -l app.kubernetes.io/name=falco -f
```

### Falco UI (if enabled)
```bash
kubectl port-forward -n falco svc/falco-falcosidekick-ui 2802:2802
# Open http://localhost:2802
```
