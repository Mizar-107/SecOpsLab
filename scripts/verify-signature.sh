#!/bin/bash
# verify-signature.sh - Verify container image signatures
set -euo pipefail

echo "=== Image Signature Verification Demo ==="
echo ""

# Check if cosign is installed
if ! command -v cosign &> /dev/null; then
    echo "❌ Cosign is not installed"
    echo "Install with: brew install cosign (macOS) or go install github.com/sigstore/cosign/v2/cmd/cosign@latest"
    exit 1
fi

# Default image for demo
IMAGE="${1:-ghcr.io/sigstore/cosign/cosign:v2.0.0}"

echo "Verifying image: ${IMAGE}"
echo ""

echo "[1/3] Checking for signature..."
if cosign verify --certificate-identity-regexp=".*" --certificate-oidc-issuer-regexp=".*" "${IMAGE}" 2>/dev/null; then
    echo "✅ Image signature verified!"
else
    echo "❌ No valid signature found or verification failed"
fi

echo ""
echo "[2/3] Checking for attestations..."
if cosign verify-attestation --certificate-identity-regexp=".*" --certificate-oidc-issuer-regexp=".*" "${IMAGE}" 2>/dev/null; then
    echo "✅ Attestations verified!"
else
    echo "ℹ️  No attestations found (this is expected for many images)"
fi

echo ""
echo "[3/3] Inspecting SBOM attestation (if exists)..."
cosign verify-attestation --type spdx --certificate-identity-regexp=".*" --certificate-oidc-issuer-regexp=".*" "${IMAGE}" 2>/dev/null || echo "ℹ️  No SBOM attestation found"

echo ""
echo "=== Verification Complete ==="
echo ""
echo "Usage: ./verify-signature.sh <image-ref>"
echo "Example: ./verify-signature.sh ghcr.io/yourorg/app:v1.0.0"
