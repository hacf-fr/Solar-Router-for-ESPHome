#!/usr/bin/env bats

setup() {
  export FIXTURE="$(mktemp -d)"
  cd "$FIXTURE"
  git init -q
  git config user.email test@example.invalid
  git config user.name "Build Matrix Tests"
  mkdir -p solar_router
}

teardown() { rm -rf "$FIXTURE"; }

commit_fixture() {
  git add .
  git commit -qm "fixture"
  git rev-parse HEAD
}

build_matrix() {
  bash "$BATS_TEST_DIRNAME/../../tools/build_matrix.sh" "$1" "$2"
}

@test "direct root change selects only that root" {
  printf 'name: a\n' > a.yaml
  printf 'name: b\n' > b.yaml
  base=$(commit_fixture)
  echo '# changed' >> a.yaml
  head=$(commit_fixture)
  run build_matrix "$base" "$head"
  [ "$status" -eq 0 ]
  [ "$output" = "a.yaml" ]
}

@test "package change selects all directly dependent roots" {
  printf 'packages:\n  p:\n    path: solar_router/shared.yaml\n' > a.yaml
  printf 'packages:\n  p:\n    path: solar_router/shared.yaml\n' > b.yaml
  printf 'value: 1\n' > solar_router/shared.yaml
  base=$(commit_fixture)
  echo 'value: 2' > solar_router/shared.yaml
  head=$(commit_fixture)
  run build_matrix "$base" "$head"
  [ "$status" -eq 0 ]
  [ "$output" = $'a.yaml\nb.yaml' ]
}

@test "transitive includes select the root" {
  printf 'packages:\n  p:\n    path: solar_router/entry.yaml\n' > a.yaml
  printf 'value: !include middle.yaml\n' > solar_router/entry.yaml
  printf 'value: !include leaf.yaml\n' > solar_router/middle.yaml
  printf 'value: 1\n' > solar_router/leaf.yaml
  base=$(commit_fixture)
  echo 'value: 2' > solar_router/leaf.yaml
  head=$(commit_fixture)
  run build_matrix "$base" "$head"
  [ "$status" -eq 0 ]
  [ "$output" = "a.yaml" ]
}

@test "multiple changed dependencies produce a sorted union without duplicates" {
  printf 'packages:\n  p:\n    path: solar_router/shared.yaml\n' > a.yaml
  printf 'packages:\n  p:\n    path: solar_router/shared.yaml\n' > b.yaml
  printf 'value: 1\n' > solar_router/shared.yaml
  base=$(commit_fixture)
  echo 'value: 2' > solar_router/shared.yaml
  echo '# direct change' >> a.yaml
  head=$(commit_fixture)
  run build_matrix "$base" "$head"
  [ "$status" -eq 0 ]
  [ "$output" = $'a.yaml\nb.yaml' ]
}

@test "unrelated changes produce an empty matrix" {
  printf 'name: a\n' > a.yaml
  printf 'name: b\n' > b.yaml
  printf 'docs\n' > README.md
  base=$(commit_fixture)
  echo 'more docs' >> README.md
  head=$(commit_fixture)
  run build_matrix "$base" "$head"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "deleted dependency still selects the previous dependents" {
  printf 'packages:\n  p:\n    path: solar_router/shared.yaml\n' > a.yaml
  printf 'value: 1\n' > solar_router/shared.yaml
  base=$(commit_fixture)
  rm solar_router/shared.yaml
  head=$(commit_fixture)
  run build_matrix "$base" "$head"
  [ "$status" -eq 0 ]
  [ "$output" = "a.yaml" ]
}

@test "new root is selected when added" {
  printf 'name: a\n' > a.yaml
  base=$(commit_fixture)
  printf 'name: b\n' > b.yaml
  head=$(commit_fixture)
  run build_matrix "$base" "$head"
  [ "$status" -eq 0 ]
  [ "$output" = "b.yaml" ]
}

@test "all lists every eligible root and excludes secrets/local files" {
  printf 'name: a\n' > a.yaml
  printf 'name: b\n' > b.yaml
  printf 'secret: x\n' > secrets.yaml
  printf 'local: x\n' > local_test.yaml
  commit_fixture >/dev/null
  run bash "$BATS_TEST_DIRNAME/../../tools/build_matrix.sh" --all
  [ "$status" -eq 0 ]
  [ "$output" = $'a.yaml\nb.yaml' ]
}
