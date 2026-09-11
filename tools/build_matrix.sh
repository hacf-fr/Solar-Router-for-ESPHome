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
  git ls-tree -r --name-only "$ref" \
    | awk -F/ 'NF == 1 && $0 ~ /\.yaml$/ && $0 != "secrets.yaml" && $0 !~ /^local_/ { print }' \
    | sort
}

root_files_worktree() {
  find . -maxdepth 1 -type f -name '*.yaml' -printf '%f\n' \
    | awk '$0 != "secrets.yaml" && $0 !~ /^local_/' \
    | sort
}

extract_deps_from_content() {
  local source="$1" content="$2" dir dep
  dir=$(dirname "$source")

  # ESPHome !include paths are relative to the file containing the tag.
  while IFS= read -r dep; do
    dep=${dep#"${dep%%[![:space:]]*}"}
    dep=${dep%"${dep##*[![:space:]]}"}
    dep=${dep#"'"}; dep=${dep%"'"}
    dep=${dep#'"'}; dep=${dep%'"'}
    [[ "$dep" == *.yaml || "$dep" == *.yml ]] || continue
    if [[ "$dep" == /* ]]; then
      dep=${dep#/}
    else
      dep="$dir/$dep"
    fi
    dep=$(realpath -m --relative-to=. "$dep")
    [[ "$dep" != ../* ]] || continue
    printf '%s\n' "$dep"
  done < <(printf '%s\n' "$content" | sed -nE 's/.*!include[[:space:]]+([^[:space:]#]+).*/\1/p')

  # Package paths are repository-relative, including the common YAML list form:
  #   files:
  #     - path: solar_router/foo.yaml
  while IFS= read -r dep; do
    dep=${dep#"${dep%%[![:space:]]*}"}
    dep=${dep%"${dep##*[![:space:]]}"}
    dep=${dep#"'"}; dep=${dep%"'"}
    dep=${dep#'"'}; dep=${dep%'"'}
    [[ "$dep" == *.yaml || "$dep" == *.yml ]] || continue
    printf '%s\n' "$dep"
  done < <(printf '%s\n' "$content" | sed -nE 's/^[[:space:]]*(-[[:space:]]*)?path:[[:space:]]*([^[:space:]#]+).*/\2/p')
}

extract_deps() {
  local ref="$1" source="$2"
  extract_deps_from_content "$source" "$(repo_file "$ref" "$source")"
}

extract_deps_worktree() {
  local source="$1"
  extract_deps_from_content "$source" "$(worktree_file "$source")"
}

impacted_by_ref() {
  local ref="$1" root="$2" changed="$3"
  declare -A seen=()
  local queue=("$root") current dep

  while ((${#queue[@]})); do
    current=${queue[0]}
    queue=("${queue[@]:1}")
    [[ -n "${seen[$current]+x}" ]] && continue
    seen["$current"]=1

    [[ "$current" == "$changed" ]] && return 0

    while IFS= read -r dep; do
      [[ -n "$dep" ]] && [[ -z "${seen[$dep]+x}" ]] && queue+=("$dep")
    done < <(extract_deps "$ref" "$current")
  done

  return 1
}

impacted_by_worktree() {
  local root="$1" changed="$2"
  declare -A seen=()
  local queue=("$root") current dep

  while ((${#queue[@]})); do
    current=${queue[0]}
    queue=("${queue[@]:1}")
    [[ -n "${seen[$current]+x}" ]] && continue
    seen["$current"]=1

    [[ "$current" == "$changed" ]] && return 0

    while IFS= read -r dep; do
      [[ -n "$dep" ]] && [[ -z "${seen[$dep]+x}" ]] && queue+=("$dep")
    done < <(extract_deps_worktree "$current")
  done

  return 1
}

local_changes() {
  {
    git diff --name-only HEAD
    git ls-files --others --exclude-standard
  } | sort -u
}

build_from_worktree() {
  local root path hit
  local -a changed=("$@")
  local -a roots=()
  mapfile -t roots < <(root_files_worktree)

  for root in "${roots[@]}"; do
    hit=0
    for path in "${changed[@]}"; do
      if [[ "$path" == "$root" ]] || impacted_by_worktree "$root" "$path"; then
        hit=1
        break
      fi
    done
    if (( hit )); then
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
  [[ -n "${BUILD_MATRIX_BASE:-}" && -n "${BUILD_MATRIX_HEAD:-}" ]] || {
    echo "BUILD_MATRIX_BASE and BUILD_MATRIX_HEAD must be set together" >&2
    exit 2
  }
  base="$BUILD_MATRIX_BASE"
  head="$BUILD_MATRIX_HEAD"
else
  head=HEAD
  if git rev-parse --verify HEAD^ >/dev/null 2>&1; then
    base=HEAD^
  else
    exit 0
  fi
fi

mapfile -t changed < <(git diff --name-only "$base...$head")
mapfile -t roots < <(root_files "$head")

for root in "${roots[@]}"; do
  hit=0
  for path in "${changed[@]}"; do
    if [[ "$path" == "$root" ]] || \
       impacted_by_ref "$head" "$root" "$path" || \
       impacted_by_ref "$base" "$root" "$path"; then
      hit=1
      break
    fi
  done
  if (( hit )); then
    printf '%s\n' "$root"
  fi
done
