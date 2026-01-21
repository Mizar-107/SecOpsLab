# Security Controls Catalog

## Overview

SecOpsLab implements security controls across the software delivery lifecycle:

| Phase | Controls |
|-------|----------|
| **Build** | Trivy scanning, secret detection |
| **Supply Chain** | Cosign signing, SBOM generation |
| **Admission** | Kyverno policies (7 policies) |
| **Runtime** | Falco detection rules (7 rules) |
| **Secrets** | Sealed Secrets |

---

## Admission Control - Kyverno Policies

### 1. Disallow Privileged Containers
**File:** `security/kyverno/policies/disallow-privileged.yaml`

Prevents containers from running in privileged mode, which bypasses most security mechanisms.

```yaml
# Blocked:
securityContext:
  privileged: true

# Allowed:
securityContext:
  privileged: false
```

### 2. Require Labels
**File:** `security/kyverno/policies/require-labels.yaml`

Enforces mandatory labels for resource management:
- `app`: Application identifier
- `env`: Environment (dev, staging, prod)
- `team`: Owning team

### 3. Require Resource Limits
**File:** `security/kyverno/policies/require-resources.yaml`

Prevents resource exhaustion by requiring CPU and memory limits.

### 4. Require Health Probes
**File:** `security/kyverno/policies/require-probes.yaml`

Ensures reliable deployments by requiring liveness and readiness probes.

### 5. Restrict Image Registries
**File:** `security/kyverno/policies/restrict-registries.yaml`

Only allows images from trusted registries:
- `ghcr.io/*`
- `gcr.io/*`
- `docker.io/library/*`
- `registry.k8s.io/*`

### 6. Require Read-Only Root Filesystem
**File:** `security/kyverno/policies/require-ro-rootfs.yaml`

Prevents malicious file modifications by requiring read-only root filesystem.

### 7. Disallow Root User
**File:** `security/kyverno/policies/disallow-root-user.yaml`

Requires containers to run as non-root user.

---

## Runtime Security - Falco Rules

### 1. Shell Spawned in Container
Detects shell execution (bash, sh, zsh) inside containers.

**Priority:** WARNING

### 2. Network Recon Tool Executed
Detects network reconnaissance tools (nmap, netcat, wget in suspicious context).

**Priority:** WARNING

### 3. Crypto Mining Detected
Detects cryptocurrency mining processes and connections.

**Priority:** CRITICAL

### 4. Sensitive File Read
Detects access to sensitive files (/etc/shadow, /etc/passwd, SSH keys).

**Priority:** ERROR

### 5. Package Manager Executed
Detects package manager usage in production containers.

**Priority:** WARNING

### 6. K8s or Cloud CLI in Container
Detects kubectl, aws, gcloud, az usage inside containers.

**Priority:** ERROR

### 7. Container Escape Attempt
Detects potential container escape techniques.

**Priority:** CRITICAL

---

## CI/CD Security Controls

### Pre-Commit
- Secret detection (Trivy)
- Dockerfile linting

### Pull Request
- Filesystem vulnerability scan
- Kubernetes manifest misconfig scan
- Secret scan

### Build
- Image vulnerability scan
- SBOM generation (Syft)
- Image signing (Cosign)
- SBOM attestation

---

## Verification Commands

```bash
# View Kyverno policies
kubectl get clusterpolicies

# View policy reports
kubectl get policyreport -A

# Check Falco logs
kubectl logs -n falco -l app.kubernetes.io/name=falco -f

# Verify image signature
cosign verify --certificate-identity-regexp=".*" \
  --certificate-oidc-issuer-regexp=".*" \
  ghcr.io/yourorg/image:tag
```
