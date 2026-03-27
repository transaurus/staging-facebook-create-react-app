#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/facebook/create-react-app"
BRANCH="main"
REPO_DIR="source-repo"
DOCUSAURUS_PATH="docusaurus/website"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Clone (skip if already exists) ---
if [ ! -d "$REPO_DIR" ]; then
    echo "=== Cloning $REPO_URL ==="
    git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$REPO_DIR"
else
    echo "=== Skipping clone, $REPO_DIR already exists ==="
fi

cd "$REPO_DIR/$DOCUSAURUS_PATH"

# --- Dependencies ---
echo "=== Installing dependencies ==="
# Install standalone (not as workspace) to avoid root postinstall issues
npm install --legacy-peer-deps

# --- Apply fixes.json if present ---
FIXES_JSON="$SCRIPT_DIR/fixes.json"
if [ -f "$FIXES_JSON" ]; then
    echo "[INFO] Applying content fixes..."
    node -e "
    const fs = require('fs');
    const path = require('path');
    const fixes = JSON.parse(fs.readFileSync('$FIXES_JSON', 'utf8'));
    for (const [file, ops] of Object.entries(fixes.fixes || {})) {
        if (!fs.existsSync(file)) { console.log('  skip (not found):', file); continue; }
        let content = fs.readFileSync(file, 'utf8');
        for (const op of ops) {
            if (op.type === 'replace' && content.includes(op.find)) {
                content = content.split(op.find).join(op.replace || '');
                console.log('  fixed:', file, '-', op.comment || '');
            }
        }
        fs.writeFileSync(file, content);
    }
    for (const [file, cfg] of Object.entries(fixes.newFiles || {})) {
        const c = typeof cfg === 'string' ? cfg : cfg.content;
        fs.mkdirSync(path.dirname(file), {recursive: true});
        fs.writeFileSync(file, c);
        console.log('  created:', file);
    }
    "
fi

echo "[DONE] Repository is ready for docusaurus commands."
