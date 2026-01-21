# SecOpsLab

[![Security Pipeline](https://img.shields.io/badge/Security-Pipeline-blue)](docs/security-controls.md)
[![Kyverno](https://img.shields.io/badge/Admission-Kyverno-green)](security/kyverno/)
[![Falco](https://img.shields.io/badge/Runtime-Falco-orange)](security/falco/)

A DevSecOps demonstration project showcasing security integration across the software delivery lifecycle. Built for local execution on Kind with GitHub Actions CI/CD integration.

## 🎯 What This Demonstrates

| Category | Implementation |
|----------|---------------|
| **Shift-Left Security** | Trivy scanning, SAST in CI/CD |
| **Admission Control** | Kyverno policies (7 security policies) |
| **Runtime Security** | Falco with custom detection rules |
| **Supply Chain** | Cosign signing, SBOM generation |
| **GitOps** | Argo CD declarative deployment |
| **Secret Management** | Sealed Secrets |

## 🚀 Quick Start

```bash
# Prerequisites: Docker, kubectl, kind, helm

# 1. Create cluster and install tooling
./infrastructure/scripts/01-create-cluster.sh
./infrastructure/scripts/02-install-argocd.sh
./infrastructure/scripts/03-install-kyverno.sh
./infrastructure/scripts/04-install-falco.sh
./infrastructure/scripts/05-install-observability.sh

# 2. Deploy vulnerable demo app (some will be blocked by policies!)
kubectl apply -f apps/vulnerable-microshop/

# 3. Check policy violations
kubectl get policyreport -A

# 4. Trigger runtime detection
kubectl exec -it deploy/api -- /bin/sh
# Check: kubectl logs -n falco -l app.kubernetes.io/name=falco
```

## 📁 Project Structure

```
SecOpsLab/
├── infrastructure/          # Kind cluster + tooling setup
├── apps/                    # Vulnerable demo application
├── security/               # Kyverno policies + Falco rules
├── .github/workflows/      # CI/CD security pipeline
└── docs/                   # Architecture & security docs
```

## 📖 Documentation

- [Architecture Overview](docs/architecture.md)
- [Security Controls Catalog](docs/security-controls.md)
- [Violation Scenarios](docs/violation-scenarios.md)

## 🛡️ Security Controls

### Admission Control (Kyverno)
- Disallow privileged containers
- Require mandatory labels
- Require health probes
- Require resource limits
- Restrict image registries
- Require read-only root filesystem
- Verify image signatures

### Runtime Detection (Falco)
- Shell spawned in container
- Sensitive file access
- Crypto mining detection
- Network tool execution
- Package manager in production

## License

MIT
