#!/bin/bash
# generate-repokey.sh
# Run this ONCE on your local machine to create your signing keypair.
# Never commit the private key. Add the output values as GitHub Actions secrets.
set -euo pipefail

if ! command -v openssl &>/dev/null; then
  echo "ERROR: openssl is required"; exit 1
fi

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

echo "==> Generating 4096-bit RSA keypair..."
openssl genrsa -out "$TMPDIR/repokey.pem" 4096 2>/dev/null
openssl rsa -in "$TMPDIR/repokey.pem" -pubout -out "$TMPDIR/repokey.pub" 2>/dev/null

FINGERPRINT=$(openssl rsa -in "$TMPDIR/repokey.pem" -pubout 2>/dev/null \
  | openssl pkey -pubin -outform DER 2>/dev/null \
  | openssl dgst -md5 -c \
  | awk '{print $2}')

echo ""
echo "============================================================"
echo " Add these three secrets to your GitHub repo:"
echo " Settings → Secrets and variables → Actions → New secret"
echo "============================================================"
echo ""
echo "--- Secret name: REPOKEY_PRIVATE ---"
base64 -w0 "$TMPDIR/repokey.pem"
echo ""
echo ""
echo "--- Secret name: REPOKEY_PUBLIC ---"
cat "$TMPDIR/repokey.pub"
echo ""
echo "--- Secret name: REPOKEY_SIGNEDBY ---"
echo "(Enter your display name, e.g.:  Your Name <you@example.com>)"
echo ""
echo "============================================================"
echo " Your repo fingerprint to put in README.md / index.html:"
echo " $FINGERPRINT"
echo "============================================================"
