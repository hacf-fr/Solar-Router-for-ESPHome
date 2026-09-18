#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

mapfile -t configs < <(cd "$PROJECT_ROOT" && bash ./tools/build_matrix.sh --all)

pushd $PROJECT_ROOT/examples
  for iloop in "${configs[@]}"; do
    echo
    echo "#########################################"
    # build_matrix.sh emits repository-relative paths; the converter runs inside examples/
    config=$(basename "$iloop")
    echo "Converting $config to local_$config"
    python "$PROJECT_ROOT/tools/convert_to_local_source.py" "$config" || exit 1
  done
  shopt -s nullglob
  local_files=(local_*.yaml)
  for iloop in "${local_files[@]}"; do
    echo
    echo "Verifying $iloop"
    esphome config "$iloop" || exit 1
  done
  for iloop in "${local_files[@]}"; do
    echo
    echo "Compiling $iloop"
    esphome compile "$iloop" || exit 1
  done
popd
