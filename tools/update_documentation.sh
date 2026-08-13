#!/bin/bash
set -e

SCRIPT_DIR=$(dirname "$0")
pushd "${SCRIPT_DIR}/.." > /dev/null

cleanup() {
    git restore docs/en/changelog.md docs/fr/changelog.md 2>/dev/null || true
    popd > /dev/null 2>&1 || true
}
trap cleanup EXIT

git cliff -l > docs/en/changelog.md

code docs/en/changelog.md

read -r -p "Ready to publish? [y/N]: " response

cp docs/en/changelog.md docs/fr/changelog.md

if [[ "$response" =~ ^[Yy]$ ]]; then
    mkdocs gh-deploy
fi

