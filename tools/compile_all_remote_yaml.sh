#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
GIT_BRANCH=$(git -C "$PROJECT_ROOT" branch --show-current)

pushd "$PROJECT_ROOT/examples"
  mapfile -t configs < <(ls *.yaml | grep -v secrets | grep -v local)

  for iloop in "${configs[@]}"; do
     echo
     echo "#########################################"
     echo Verifying $iloop
     esphome -s github_branch ${GIT_BRANCH} config $iloop || exit 1
  done

  for iloop in "${configs[@]}"; do
     echo
     echo "#########################################"
     echo Compiling $iloop
     esphome -s github_branch ${GIT_BRANCH} compile $iloop || exit 1
  done
popd
