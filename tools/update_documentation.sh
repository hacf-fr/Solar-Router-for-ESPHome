#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
pushd "${SCRIPT_DIR}/.." > /dev/null
git cliff  | sed "s/#74 //" > docs/en/changelog.md
code docs/en/changelog.md

read -r -p "Ready to publish? [y/N]: " response

cp docs/en/changelog.md docs/fr/changelog.md

if [[ "$response" =~ ^[Yy]$ ]]; then
    mkdocs gh-deploy
fi
git restore docs/en/changelog.md
git restore docs/fr/changelog.md

popd > /dev/null
