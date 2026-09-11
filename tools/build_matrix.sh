#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 [--all]" >&2
  exit 2
}

repo_file() {
  local ref="$1" path="$2"
  if git cat-file -e "${ref}:${path}" 2>/dev/null; then
    git show --format= --no-ext-diff "${ref}:${path}"
  fi
}

worktree_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    cat "$path"
  elif git cat-file -e "HEAD:${path}" 2>/dev/null; then
    git show --format= --no-ext-diff "HEAD:${path}"
  fi
}

root_files() {
  local ref="$1"
  git ls-tree -r --name-only "$ref" | awk -F/ 'NF == 1 && $0 ~ /\.yaml$/ && $0 != "secrets.yaml" && $0 !~ /^local_/ { print }' | sort
}

root_files_worktree() {
  find . -maxdepth 1 -type f -name '*.yaml' -printf '%f\n' | awk '$0 != "secrets.yaml" && $0 !~ /^local_/' | sort
}

extract_deps_from_content() {
  local source="$1" content="$2" dir dep
  dir=$(dirname "$source")

  while IFS= read -r dep; do
    dep=${dep#"${dep%%[![:space:]]*}"}; dep=${dep%"${dep##*[![:space:]]}"}
    dep=${dep#"'"}; dep=${dep%"'"}; dep=${dep#'"'}; dep=${dep%'"'}
    [[ "$dep" == *.yaml || "$dep" == *.yml ]] || continue
    if [[ "$dep" == /* ]]; then dep=${dep#/}; else dep="$dir/$dep"; fi
    dep=$(realpath -m --relative-to=. "$dep")
    [[ "$dep" != ../* ]] || continue
    printf '%s\n' "$dep"
  done < <(printf '%s\n' "$content" | sed -nE 's/.*!include[[:space:]]+([^[:space:]#]+).*/\1/p')

  while IFS= read -r dep; do
    dep=${dep#"${dep%%[![:space:]]*}"}; dep=${dep%"${dep##*[![:space:]]}"}
    dep=${dep#"'"}; dep=${dep%"'"}; dep=${dep#'"'}; dep=${dep%'"'}
    [[ "$dep" == *.yaml || "$dep" == *.yml ]] || continue
    printf '%s\n' "$dep"
  done < <(printf '%s\n' "$content" | sed -nE 's/^[[:space:]]*(-[[:space:]]*)?path:[[:space:]]*([^[:space:]#]+).*/\2/p')
}

build_graph() {
  local mode="$1" ref="${2:-}" file dep content
  local -a queue=()
  declare -A visited=()
  declare -gA reverse_deps=()

  if [[ "$mode" == worktree ]]; then mapfile -t queue < <(root_files_worktree); else mapfile -t queue < <(root_files "$ref"); fi

  while ((${#queue[@]})); do
    file=${queue[0]}; queue=("${queue[@]:1}")
    [[ -n "${visited[$file]+x}" ]] && continue
    visited["$file"]=1
    if [[ "$mode" == worktree ]]; then content=$(worktree_file "$file"); else content=$(repo_file "$ref" "$file"); fi
    while IFS= read -r dep; do
      [[ -n "$dep" ]] || continue
      reverse_deps["$dep"]+=" $file"
      [[ -n "${visited[$dep]+x}" ]] || queue+=("$dep")
    done < <(extract_deps_from_content "$file" "$content")
  done
}

impacted_roots_from_graph() {
  local current root parent
  local -a queue=("$@")
  declare -A seen=() roots_set=()
  while ((${#queue[@]})); do
    current=${queue[0]}; queue=("${queue[@]:1}")
    [[ -n "${seen[$current]+x}" ]] && continue
    seen["$current"]=1
    if [[ "$current" == *.yaml && "$current" != */* && "$current" != "secrets.yaml" && "$current" != local_* ]]; then roots_set["$current"]=1; fi
    for parent in ${reverse_deps[$current]-}; do [[ -n "${seen[$parent]+x}" ]] || queue+=("$parent"); done
  done
  for root in "${!roots_set[@]}"; do printf '%s\n' "$root"; done | sort
}

local_changes() {
  { git diff --name-only HEAD; git ls-files --others --exclude-standard; } | sort -u
}

local_base_ref() {
  local ref
  for ref in origin/main main; do
    if git rev-parse --verify "$ref" >/dev/null 2>&1; then
      git merge-base HEAD "$ref"
      return 0
    fi
  done

  if git rev-parse --verify HEAD^ >/dev/null 2>&1; then
    git rev-parse HEAD^
    return 0
  fi

  return 1
}

build_from_worktree() {
  local path root
  local -a changed=("$@")
  declare -A impacted=()
  build_graph worktree
  for path in "${changed[@]}"; do
    while IFS= read -r root; do
      if [[ -n "$root" ]]; then impacted["$root"]=1; fi
    done < <(impacted_roots_from_graph "$path")
  done
  for path in "${!impacted[@]}"; do printf '%s\n' "$path"; done | sort
}

build_from_refs() {
  local base="$1" head="$2" path root
  local -a changed=()
  declare -A impacted=()
  mapfile -t changed < <(git diff --name-only "$base...$head")
  ((${#changed[@]})) || return 0

  build_graph ref "$head"
  for path in "${changed[@]}"; do
    while IFS= read -r root; do
      if [[ -n "$root" ]]; then impacted["$root"]=1; fi
    done < <(impacted_roots_from_graph "$path")
  done

  build_graph ref "$base"
  for path in "${changed[@]}"; do
    while IFS= read -r root; do
      if [[ -n "$root" ]]; then impacted["$root"]=1; fi
    done < <(impacted_roots_from_graph "$path")
  done

  mapfile -t roots < <(root_files "$head")
  for root in "${roots[@]}"; do
    if [[ -n "${impacted[$root]+x}" ]]; then
      printf '%s\n' "$root"
    fi
  done
}

if [[ "${1:-}" == "--all" ]]; then
  [[ $# -eq 1 ]] || usage
  root_files HEAD
  exit 0
fi
[[ $# -eq 0 ]] || usage

mapfile -t changed < <(local_changes)
if ((${#changed[@]})); then
  build_from_worktree "${changed[@]}"
  exit 0
fi

if [[ -n "${BUILD_MATRIX_BASE:-}" || -n "${BUILD_MATRIX_HEAD:-}" ]]; then
  [[ -n "${BUILD_MATRIX_BASE:-}" && -n "${BUILD_MATRIX_HEAD:-}" ]] || { echo "BUILD_MATRIX_BASE and BUILD_MATRIX_HEAD must be set together" >&2; exit 2; }
  base="$BUILD_MATRIX_BASE"; head="$BUILD_MATRIX_HEAD"
else
  head=HEAD
  if ! base=$(local_base_ref); then
    exit 0
  fi
fi

build_from_refs "$base" "$head"
