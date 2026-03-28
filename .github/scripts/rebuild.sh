#!/usr/bin/env bash
set -euo pipefail

# Rebuild script for facebook/create-react-app
# Runs on existing source tree (no clone). Installs deps and builds.
# Current directory must be the docusaurus root (docusaurus/website).

# --- Dependencies ---
echo "=== Installing dependencies ==="
npm install --legacy-peer-deps

# --- Build ---
echo "=== Building ==="
npm run build

echo "[DONE] Build complete."
