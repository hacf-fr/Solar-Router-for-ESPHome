#!/usr/bin/env bats

setup() {
  export FIXTURE="$(mktemp -d)"
  cd "$FIXTURE"
  git init -q -b fixture
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
  bash "$BATS_TEST_DIRNAME/../../tools/build_matrix.sh"
}

@test "direct root change selects only that root" {
  printf 'name: a\n' > a.yaml
  printf 'name: b\n' > b.yaml
  commit_fixture >/dev/null
  echo '# changed' >> a.yaml
  commit_fixture >/dev/null
  run build_matrix
  [ "$status" -eq 0 ]
  [ "$output" = "a.yaml" ]
}

@test "package change selects all directly dependent roots" {
  printf 'packages:\n  p:\n    files:\n      - path: solar_router/shared.yaml\n' > a.yaml
  printf 'packages:\n  p:\n    files:\n      - path: solar_router/shared.yaml\n' > b.yaml
  printf 'value: 1\n' > solar_router/shared.yaml
  commit_fixture >/dev/null
  echo 'value: 2' > solar_router/shared.yaml
  commit_fixture >/dev/null
  run build_matrix
  [ "$status" -eq 0 ]
  [ "$output" = $'a.yaml\nb.yaml' ]
}

@test "include package syntax selects dependent root" {
  printf 'packages:\n  p: !include solar_router/shared.yaml\n' > a.yaml
  printf 'value: 1\n' > solar_router/shared.yaml
  commit_fixture >/dev/null
  echo 'value: 2' > solar_router/shared.yaml
  commit_fixture >/dev/null
  run build_matrix
  [ "$status" -eq 0 ]
  [ "$output" = "a.yaml" ]
}

@test "transitive includes select the root" {
  printf 'packages:\n  p:\n    path: solar_router/entry.yaml\n' > a.yaml
  printf 'value: !include middle.yaml\n' > solar_router/entry.yaml
  printf 'value: !include leaf.yaml\n' > solar_router/middle.yaml
  printf 'value: 1\n' > solar_router/leaf.yaml
  commit_fixture >/dev/null
  echo 'value: 2' > solar_router/leaf.yaml
  commit_fixture >/dev/null
  run build_matrix
  [ "$status" -eq 0 ]
  [ "$output" = "a.yaml" ]
}

@test "multiple changed dependencies produce a sorted union without duplicates" {
  printf 'packages:\n  p:\n    path: solar_router/shared.yaml\n' > a.yaml
  printf 'packages:\n  p:\n    path: solar_router/shared.yaml\n' > b.yaml
  printf 'value: 1\n' > solar_router/shared.yaml
  commit_fixture >/dev/null
  echo 'value: 2' > solar_router/shared.yaml
  echo '# direct change' >> a.yaml
  commit_fixture >/dev/null
  run build_matrix
  [ "$status" -eq 0 ]
  [ "$output" = $'a.yaml\nb.yaml' ]
}

@test "unrelated changes produce an empty matrix" {
  printf 'name: a\n' > a.yaml
  printf 'name: b\n' > b.yaml
  printf 'docs\n' > README.md
  commit_fixture >/dev/null
  echo 'more docs' >> README.md
  commit_fixture >/dev/null
  run build_matrix
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "no changes produce an empty matrix" {
  printf 'name: a\n' > a.yaml
  commit_fixture >/dev/null
  run build_matrix
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "deleted dependency still selects the previous dependents" {
  printf 'packages:\n  p:\n    path: solar_router/shared.yaml\n' > a.yaml
  printf 'value: 1\n' > solar_router/shared.yaml
  commit_fixture >/dev/null
  rm solar_router/shared.yaml
  commit_fixture >/dev/null
  run build_matrix
  [ "$status" -eq 0 ]
  [ "$output" = "a.yaml" ]
}

@test "dependency cycles do not loop forever" {
  printf 'packages:\n  p:\n    path: solar_router/a.yaml\n' > root.yaml
  printf 'value: !include b.yaml\n' > solar_router/a.yaml
  printf 'value: !include a.yaml\n' > solar_router/b.yaml
  commit_fixture >/dev/null
  echo '# changed' >> solar_router/b.yaml
  commit_fixture >/dev/null
  run timeout 5 bash "$BATS_TEST_DIRNAME/../../tools/build_matrix.sh"
  [ "$status" -eq 0 ]
  [ "$output" = "root.yaml" ]
}

@test "new root is selected when added" {
  printf 'name: a\n' > a.yaml
  commit_fixture >/dev/null
  printf 'name: b\n' > b.yaml
  commit_fixture >/dev/null
  run build_matrix
  [ "$status" -eq 0 ]
  [ "$output" = "b.yaml" ]
}

@test "clean branch compares against main, not only HEAD^" {
  printf 'packages:\n  p:\n    path: solar_router/shared.yaml\n' > a.yaml
  printf 'value: 1\n' > solar_router/shared.yaml
  commit_fixture >/dev/null
  git branch -M main
  git checkout -qb feature
  echo 'value: 2' > solar_router/shared.yaml
  commit_fixture >/dev/null
  echo 'more docs' >> README.md
  commit_fixture >/dev/null
  run build_matrix
  [ "$status" -eq 0 ]
  [ "$output" = "a.yaml" ]
}

@test "uncommitted dependency change selects dependent root" {
  printf 'packages:\n  p:\n    files:\n      - path: solar_router/shared.yaml\n' > a.yaml
  printf 'value: 1\n' > solar_router/shared.yaml
  commit_fixture >/dev/null
  echo 'value: 2' > solar_router/shared.yaml
  run build_matrix
  [ "$status" -eq 0 ]
  [ "$output" = "a.yaml" ]
}

@test "uncommitted root change selects that root" {
  printf 'name: a\n' > a.yaml
  printf 'name: b\n' > b.yaml
  commit_fixture >/dev/null
  echo '# changed' >> a.yaml
  run build_matrix
  [ "$status" -eq 0 ]
  [ "$output" = "a.yaml" ]
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
