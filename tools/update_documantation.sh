#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
pushd "${SCRIPT_DIR}/.." > /dev/null
git cliff > docs/en/changelog.md
code docs/en/changelog.md

read -r -p "Ready to publish? [y/N]: " response

if [[ "$response" =~ ^[Yy]$ ]]; then
    mkdocs gh-deploy
fi
git restore docs/en/changelog.md

popd > /dev/null