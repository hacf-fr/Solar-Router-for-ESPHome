#!/usr/bin/env bats

setup() {
  export FIXTURE="$(mktemp -d)"
  cd "$FIXTURE"
  git init -q -b fixture
  git config user.email test@example.invalid
  git config user.name "Check Module Version Tests"
  mkdir -p solar_router
}

teardown() { rm -rf "$FIXTURE"; }

commit_fixture() {
  git add -A
  git commit -qm "fixture"
  git rev-parse HEAD
}

check_versions() {
  bash "$BATS_TEST_DIRNAME/../../tools/check_module_version.sh"
}

# make_module <basename> [version] [id] [name]
#
# Writes solar_router/<basename>.yaml. `id` and `name` default to the
# convention the script enforces; pass them to build a broken module.
make_module() {
  local base="$1"
  local version="${2:-1.0.0}"
  local id="${3:-version_${1//-/_}}"
  local name="${4:-$1}"

  cat > "solar_router/${base}.yaml" <<EOF
text_sensor:
  - platform: template
    id: ${id}
    name: "${name}"
    icon: mdi:tag-outline
    entity_category: diagnostic
    lambda: |-
      static bool published = false;
      if (published) return {};
      published = true;
      return {"${version}"};
    disabled_by_default: false
EOF
}

tag_release() { git tag "v$1"; }

# The script prefers origin/main over the last tag. Fixtures have no
# remote, so point the ref at a commit directly.
set_origin_main() { git update-ref refs/remotes/origin/main "${1:-HEAD}"; }

# ============================================================
# Step 1 - structural checks, run on every module
# ============================================================

@test "valid module passes every check" {
  make_module test-module
  commit_fixture >/dev/null
  run check_versions
  [ "$status" -eq 0 ]
  [[ "$output" == *"Version checks passed"* ]]
}

@test "missing version text_sensor fails" {
  cat > solar_router/test-module.yaml <<'EOF'
text_sensor:
  - platform: template
    id: something_else
    name: "test-module"
    lambda: |-
      return {"1.0.0"};
EOF
  commit_fixture >/dev/null
  run check_versions
  [ "$status" -ne 0 ]
  [[ "$output" == *"missing version text_sensor"* ]]
  [[ "$output" == *"expected id 'version_test_module'"* ]]
}

@test "version id mismatch fails" {
  make_module test-module 1.0.0 version_wrong_module
  commit_fixture >/dev/null
  run check_versions
  [ "$status" -ne 0 ]
  [[ "$output" == *"id is 'version_wrong_module', expected 'version_test_module'"* ]]
}

@test "version name mismatch fails" {
  make_module test-module 1.0.0 version_test_module wrong-module
  commit_fixture >/dev/null
  run check_versions
  [ "$status" -ne 0 ]
  [[ "$output" == *"name is 'wrong-module', expected 'test-module'"* ]]
}

@test "hyphens in the file name map to underscores in the id" {
  make_module jsy-mk-194t_common
  commit_fixture >/dev/null
  run check_versions
  [ "$status" -eq 0 ]
}

@test "multi-instance substitution suffix is accepted on id and name" {
  make_module regulator 1.0.0 'version_regulator_${relay_unique_id}' 'regulator_${relay_unique_id}'
  commit_fixture >/dev/null
  run check_versions
  [ "$status" -eq 0 ]
}

@test "version sensor is found when it is not the first list item" {
  cat > solar_router/debug_sensors.yaml <<'EOF'
text_sensor:
  - platform: debug
    device:
      name: "Device Info"
    reset_reason:
      name: "Reset Reason"
  - platform: template
    id: version_debug_sensors
    name: "debug_sensors"
    lambda: |-
      return {"1.0.0"};

sensor:
  - platform: debug
    free:
      name: "Heap Free"
EOF
  commit_fixture >/dev/null
  run check_versions
  [ "$status" -eq 0 ]
  [[ "$output" == *"debug_sensors.yaml: version 1.0.0"* ]]
}

@test "non semantic version fails" {
  cat > solar_router/test-module.yaml <<'EOF'
text_sensor:
  - platform: template
    id: version_test_module
    name: "test-module"
    lambda: |-
      return {"1.0"};
EOF
  commit_fixture >/dev/null
  run check_versions
  [ "$status" -ne 0 ]
  [[ "$output" == *"could not extract module version"* ]]
}

@test "missing version value fails" {
  cat > solar_router/test-module.yaml <<'EOF'
text_sensor:
  - platform: template
    id: version_test_module
    name: "test-module"
    lambda: |-
      return {};
EOF
  commit_fixture >/dev/null
  run check_versions
  [ "$status" -ne 0 ]
  [[ "$output" == *"could not extract module version"* ]]
}

@test "an untouched but broken module still fails" {
  make_module broken-module 1.0.0 version_wrong_id
  make_module touched-module 1.0.1
  commit_fixture >/dev/null
  tag_release 1.0.0

  make_module touched-module 1.0.1
  echo '# changed' >> solar_router/touched-module.yaml

  run check_versions
  [ "$status" -ne 0 ]
  [[ "$output" == *"broken-module.yaml: id is 'version_wrong_id'"* ]]
}

# ============================================================
# Step 2 - release version rule, run on modified modules
# ============================================================

@test "modified module above the last release passes" {
  make_module test-module 1.0.0
  commit_fixture >/dev/null
  tag_release 1.0.0

  make_module test-module 1.0.1
  commit_fixture >/dev/null

  run check_versions
  [ "$status" -eq 0 ]
  [[ "$output" == *"test-module.yaml: version 1.0.1 > 1.0.0"* ]]
}

@test "modified module still at the last release version fails" {
  make_module test-module 1.0.0
  commit_fixture >/dev/null
  tag_release 1.0.0

  echo '# changed' >> solar_router/test-module.yaml
  commit_fixture >/dev/null

  run check_versions
  [ "$status" -ne 0 ]
  [[ "$output" == *"version 1.0.0 must be greater than last release 1.0.0"* ]]
}

@test "modified module below the last release fails" {
  make_module test-module 1.0.0
  commit_fixture >/dev/null
  tag_release 1.1.0

  echo '# changed' >> solar_router/test-module.yaml
  commit_fixture >/dev/null

  run check_versions
  [ "$status" -ne 0 ]
  [[ "$output" == *"version 1.0.0 must be greater than last release 1.1.0"* ]]
}

@test "modified modules with different versions fail" {
  make_module module-a 1.0.0
  make_module module-b 1.0.0
  commit_fixture >/dev/null
  tag_release 1.0.0

  make_module module-a 1.0.1
  make_module module-b 1.0.2
  commit_fixture >/dev/null

  run check_versions
  [ "$status" -ne 0 ]
  [[ "$output" == *"Modified modules do not share the same version"* ]]
}

@test "modified modules sharing one version pass" {
  make_module module-a 1.0.0
  make_module module-b 1.0.0
  commit_fixture >/dev/null
  tag_release 1.0.0

  make_module module-a 1.0.1
  make_module module-b 1.0.1
  commit_fixture >/dev/null

  run check_versions
  [ "$status" -eq 0 ]
  [[ "$output" == *"All modified modules use version 1.0.1"* ]]
}

@test "uncommitted change without a version bump fails" {
  make_module test-module 1.0.0
  commit_fixture >/dev/null
  tag_release 1.0.0

  echo '# changed' >> solar_router/test-module.yaml

  run check_versions
  [ "$status" -ne 0 ]
  [[ "$output" == *"version 1.0.0 must be greater than last release 1.0.0"* ]]
}

@test "untracked new module is checked against the last release" {
  make_module existing 1.0.0
  commit_fixture >/dev/null
  tag_release 1.0.0

  make_module brand-new 0.9.0

  run check_versions
  [ "$status" -ne 0 ]
  [[ "$output" == *"brand-new.yaml: version 0.9.0 must be greater than last release 1.0.0"* ]]
}

@test "nothing modified since the last release passes" {
  make_module test-module 1.0.0
  commit_fixture >/dev/null
  tag_release 1.0.0

  run check_versions
  [ "$status" -eq 0 ]
  [[ "$output" == *"No modules modified"* ]]
}

@test "deleting a module does not fail the check" {
  make_module doomed 1.0.0
  make_module survivor 1.0.0
  commit_fixture >/dev/null
  tag_release 1.0.0

  git rm -q solar_router/doomed.yaml
  commit_fixture >/dev/null

  run check_versions
  [ "$status" -eq 0 ]
  [[ "$output" == *"No modules modified"* ]]
}

@test "a modified module removed from the working tree is skipped" {
  make_module test-module 1.0.0
  local base
  base=$(commit_fixture)
  tag_release 1.0.0

  make_module test-module 1.0.1
  commit_fixture >/dev/null

  rm solar_router/test-module.yaml

  BASE_SHA="$base" run check_versions
  [ "$status" -eq 0 ]
  [[ "$output" == *"file no longer exists, skipped"* ]]
  [[ "$output" == *"nothing to compare"* ]]
}

@test "no tag at all skips the release comparison" {
  make_module test-module 0.0.1
  commit_fixture >/dev/null

  run check_versions
  [ "$status" -eq 0 ]
  [[ "$output" == *"No git tags found"* ]]
}

@test "a non semantic tag fails" {
  make_module test-module 1.0.0
  commit_fixture >/dev/null
  git tag nightly

  run check_versions
  [ "$status" -ne 0 ]
  [[ "$output" == *"does not contain a valid semantic version"* ]]
}

@test "BASE_SHA takes priority over the last tag" {
  make_module test-module 1.0.0
  local base
  base=$(commit_fixture)
  tag_release 2.0.0

  make_module test-module 2.0.1
  commit_fixture >/dev/null

  # Against the tag nothing changed after it, so only BASE_SHA can see
  # the module as modified.
  BASE_SHA="$base" run check_versions
  [ "$status" -eq 0 ]
  [[ "$output" == *"Comparing against BASE_SHA: $base"* ]]
  [[ "$output" == *"test-module.yaml: version 2.0.1 > 2.0.0"* ]]
}

@test "origin/main is used when BASE_SHA is absent" {
  make_module test-module 1.0.0
  commit_fixture >/dev/null
  tag_release 1.0.0
  set_origin_main

  echo '# changed' >> solar_router/test-module.yaml

  run check_versions
  [ "$status" -ne 0 ]
  [[ "$output" == *"Comparing against origin/main"* ]]
  [[ "$output" == *"version 1.0.0 must be greater than last release 1.0.0"* ]]
}

@test "no git reference at all still runs the structural checks" {
  make_module test-module 1.0.0 version_wrong_id
  commit_fixture >/dev/null
  git update-ref -d refs/heads/fixture 2>/dev/null || true

  run check_versions
  [ "$status" -ne 0 ]
  [[ "$output" == *"id is 'version_wrong_id'"* ]]
}
