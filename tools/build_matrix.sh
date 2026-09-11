#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --all | <base-ref> <head-ref>" >&2
  exit 2
}

repo_file() {
  local ref="$1" path="$2"
  if git cat-file -e "${ref}:${path}" 2>/dev/null; then
    git show --format= --no-ext-diff "${ref}:${path}"
  fi
}

root_files() {
  local ref="$1"
  git ls-tree -r --name-only "$ref" \
    | awk -F/ 'NF == 1 && $0 ~ /\.yaml$/ && $0 != "secrets.yaml" && $0 !~ /^local_/ { print }' \
    | sort
}

extract_deps() {
  local ref="$1" source="$2" content dir dep
  content=$(repo_file "$ref" "$source")
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

  # Package paths are repository-relative, even when declared by a root file.
  while IFS= read -r dep; do
    dep=${dep#"${dep%%[![:space:]]*}"}
    dep=${dep%"${dep##*[![:space:]]}"}
    dep=${dep#"'"}; dep=${dep%"'"}
    dep=${dep#'"'}; dep=${dep%'"'}
    [[ "$dep" == *.yaml || "$dep" == *.yml ]] || continue
    printf '%s\n' "$dep"
  done < <(printf '%s\n' "$content" | sed -nE 's/^[[:space:]]*path:[[:space:]]*([^[:space:]#]+).*/\1/p')
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

if [[ "${1:-}" == "--all" ]]; then
  root_files HEAD
  exit 0
fi

[[ $# -eq 2 ]] || usage
base=$1
head=$2

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
