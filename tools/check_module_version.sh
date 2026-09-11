#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Solar Router - Version validation
#
# Two independent checks:
#
#   1. Structure   - every module in solar_router/ declares a
#                    version text_sensor whose id and name match
#                    the file name, with a semantic version.
#
#   2. Release     - every module modified since the last release
#                    carries the same version, strictly greater
#                    than the last release tag.
# ============================================================

MODULE_DIR="solar_router"

# Colors
GREEN=$(tput setaf 2 2>/dev/null || true)
RED=$(tput setaf 1 2>/dev/null || true)
YELLOW=$(tput setaf 3 2>/dev/null || true)
RESET=$(tput sgr0 2>/dev/null || true)

EXIT_STATUS=0

fail() {
    echo "${RED}❌ $*${RESET}"
    EXIT_STATUS=1
}

warn() {
    echo "${YELLOW}⚠ $*${RESET}"
}

ok() {
    echo "${GREEN}✓ $*${RESET}"
}

# ============================================================
# Extract version text_sensor information
#
# Output:
#   id=version_xxx
#   name=xxx
#   version=1.2.3
#
# If no version_* text_sensor exists:
#   returns nothing
# ============================================================

version_sensor_info() {
    local file="$1"

    awk '
    function reset_sensor() {
        id = ""
        name = ""
        version = ""
    }

    function output_sensor() {
        if (id ~ /^version_/) {
            print "id=" id
            print "name=" name
            print "version=" version
            found = 1
            exit
        }

        reset_sensor()
    }

    # --------------------------------------------------------
    # Start of text_sensor section
    # --------------------------------------------------------

    /^[[:space:]]*text_sensor:[[:space:]]*$/ {
        in_text_sensor = 1
        reset_sensor()
        next
    }

    # --------------------------------------------------------
    # A new top-level section ends text_sensor
    # --------------------------------------------------------

    in_text_sensor &&
    /^[^[:space:]#]/ {
        output_sensor()
        in_text_sensor = 0
        next
    }

    !in_text_sensor {
        next
    }

    # --------------------------------------------------------
    # New list item = new text_sensor
    # --------------------------------------------------------

    /^[[:space:]]*-[[:space:]]/ {
        if (id != "") {
            output_sensor()
        }

        reset_sensor()
        next
    }

    # --------------------------------------------------------
    # id: version_xxx
    # --------------------------------------------------------

    /^[[:space:]]+id:[[:space:]]*"?version_[^"]*"?[[:space:]]*$/ {
        id = $0
        sub(/^[[:space:]]+id:[[:space:]]*"?/, "", id)
        sub(/"?[[:space:]]*$/, "", id)
        next
    }

    # --------------------------------------------------------
    # name: xxx
    # --------------------------------------------------------

    /^[[:space:]]+name:[[:space:]]*"?[^"]+"?[[:space:]]*$/ {
        name = $0
        sub(/^[[:space:]]+name:[[:space:]]*"?/, "", name)
        sub(/"?[[:space:]]*$/, "", name)
        next
    }

    # --------------------------------------------------------
    # return {"1.2.3"};
    # --------------------------------------------------------

    /return[[:space:]]*\{[[:space:]]*"([0-9]+\.[0-9]+\.[0-9]+)"/ {
        version = $0
        sub(/.*return[[:space:]]*\{[[:space:]]*"/, "", version)
        sub(/".*/, "", version)
        next
    }

    # --------------------------------------------------------
    # End of file
    # --------------------------------------------------------

    END {
        if (!found && in_text_sensor) {
            output_sensor()
        }
    }
    ' "$file"
}

# ============================================================
# Read one field out of version_sensor_info() output
# ============================================================

sensor_field() {
    local info="$1"
    local field="$2"

    printf '%s\n' "$info" |
        sed -n "s/^${field}=//p" |
        head -n1
}

# ============================================================
# Compare semantic versions
#
# Returns:
#   0 => version > reference
#   1 => version <= reference
# ============================================================

version_greater_than() {
    local version="$1"
    local reference="$2"

    # Both versions must be X.Y.Z
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 1
    fi

    if [[ ! "$reference" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 1
    fi

    # Equal versions are not allowed
    if [[ "$version" == "$reference" ]]; then
        return 1
    fi

    # Sort using version-aware sort
    local highest

    highest=$(
        printf '%s\n%s\n' "$reference" "$version" |
            sort -V |
            tail -n1
    )

    [[ "$highest" == "$version" ]]
}

# ============================================================
# Expected id / name for a module file
#
# Convert:
#
#   solar_router/my-module.yaml
#
# to:
#
#   id:   version_my_module
#   name: my-module
#
# Multi-instance packages append their own _${*_unique_id} to
# both, which is accepted as well.
# ============================================================

expected_id_for() {
    local base_name
    base_name=$(basename "$1" .yaml)

    echo "version_${base_name//-/_}"
}

expected_name_for() {
    basename "$1" .yaml
}

# ============================================================
# Structural check of a single module
#
# Verifies:
#   - a version text_sensor exists
#   - its id matches the file name
#   - its name matches the file name
#   - its version is a valid X.Y.Z
#
# Sets MODULE_VERSION to the module version when it is valid.
# Returns 1 when anything is wrong.
#
# Must be called directly, never in a command substitution:
# fail() updates EXIT_STATUS and a subshell would discard it.
# ============================================================

MODULE_VERSION=""

check_module_structure() {
    local yaml_file="$1"

    MODULE_VERSION=""

    local expected_id expected_name
    expected_id=$(expected_id_for "$yaml_file")
    expected_name=$(expected_name_for "$yaml_file")

    local sensor_info
    sensor_info=$(version_sensor_info "$yaml_file" || true)

    local actual_id actual_name module_version
    actual_id=$(sensor_field "$sensor_info" id)
    actual_name=$(sensor_field "$sensor_info" name)
    module_version=$(sensor_field "$sensor_info" version)

    local module_ok=0

    # --------------------------------------------------------
    # Version text_sensor is MANDATORY
    # --------------------------------------------------------

    if [[ -z "$actual_id" ]]; then
        fail "$yaml_file: missing version text_sensor (expected id '$expected_id')"
        return 1
    fi

    # --------------------------------------------------------
    # Check id
    #
    # Accepted:
    #
    #   version_activate_button
    #   version_activate_button_${something}
    # --------------------------------------------------------

    case "$actual_id" in
        "$expected_id") ;;
        "$expected_id"_\$\{*\}) ;;
        *)
            fail "$yaml_file: id is '$actual_id', expected '$expected_id'"
            module_ok=1
            ;;
    esac

    # --------------------------------------------------------
    # Check name
    # --------------------------------------------------------

    case "$actual_name" in
        "$expected_name") ;;
        "$expected_name"_\$\{*\}) ;;
        *)
            fail "$yaml_file: name is '${actual_name:-<missing>}', expected '$expected_name'"
            module_ok=1
            ;;
    esac

    # --------------------------------------------------------
    # Version must exist and be X.Y.Z
    # --------------------------------------------------------

    if [[ -z "$module_version" ]]; then
        fail "$yaml_file: could not extract module version"
        return 1
    fi

    if [[ ! "$module_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        fail "$yaml_file: invalid semantic version '$module_version' (expected X.Y.Z)"
        return 1
    fi

    MODULE_VERSION="$module_version"

    return "$module_ok"
}

# ============================================================
# 0. Release information
# ============================================================

echo "=== Release information ==="

LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)

if [[ -z "$LAST_TAG" ]]; then
    warn "No git tags found."
    LAST_VERSION="0.0.0"
else
    echo "Last release: $LAST_TAG"

    LAST_VERSION="${LAST_TAG#v}"

    if [[ ! "$LAST_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        fail "Last tag '$LAST_TAG' does not contain a valid semantic version."
        echo ""
        echo "============================================================"
        echo "${RED}❌ Validation failed${RESET}"
        echo "============================================================"
        exit "$EXIT_STATUS"
    fi

    echo "Last version: $LAST_VERSION"
fi

# ============================================================
# 1. Every module announces a well-formed version
#
# This runs on every module, not only the modified ones: a
# refactoring that breaks an untouched module must be caught
# too.
# ============================================================

echo ""
echo "=== Checking module structure ==="

STRUCTURE_OK=1

shopt -s nullglob

MODULE_FILES=("$MODULE_DIR"/*.yaml)

shopt -u nullglob

if [[ "${#MODULE_FILES[@]}" -eq 0 ]]; then
    warn "No module found in $MODULE_DIR/."
fi

for yaml_file in "${MODULE_FILES[@]}"; do
    if check_module_structure "$yaml_file"; then
        ok "$yaml_file: version $MODULE_VERSION"
    else
        STRUCTURE_OK=0
    fi
done

if [[ "$STRUCTURE_OK" -eq 1 && "${#MODULE_FILES[@]}" -gt 0 ]]; then
    ok "Every module declares a valid version text_sensor"
fi

# ============================================================
# 2. Find modified YAML files
# ============================================================

echo ""
echo "=== Detecting modified modules ==="

DIFF_BASE=""
COMPARE_WORKTREE=0

# ------------------------------------------------------------
# GitHub Actions / CI:
# BASE_SHA contains the commit of the base branch. HEAD is the
# pull request merge commit, so the diff is exactly the PR.
# ------------------------------------------------------------

if [[ -n "${BASE_SHA:-}" ]]; then

    echo "Comparing against BASE_SHA: $BASE_SHA"
    DIFF_BASE="$BASE_SHA"

# ------------------------------------------------------------
# Local checkout with origin/main available.
#
# The working tree is compared too, so a module can be checked
# before it is committed.
# ------------------------------------------------------------

elif git show-ref --verify --quiet refs/remotes/origin/main; then

    echo "Comparing against origin/main (including working tree)"
    DIFF_BASE=$(git merge-base origin/main HEAD 2>/dev/null || true)
    COMPARE_WORKTREE=1

# ------------------------------------------------------------
# Fallback: compare against last tag, working tree included.
# ------------------------------------------------------------

elif [[ -n "$LAST_TAG" ]]; then

    warn "origin/main is not available."
    warn "Falling back to changes since $LAST_TAG (including working tree)."

    DIFF_BASE="$LAST_TAG"
    COMPARE_WORKTREE=1

fi

# ------------------------------------------------------------
# No git history at all: the structural check above already
# covered every module, there is nothing more to do.
# ------------------------------------------------------------

if [[ -z "$DIFF_BASE" ]]; then

    warn "No comparison reference available."
    warn "Skipping the release version check."

    echo ""
    echo "============================================================"

    if [[ "$EXIT_STATUS" -eq 0 ]]; then
        echo "${GREEN}✓ Version checks passed${RESET}"
    else
        echo "${RED}❌ Validation failed${RESET}"
    fi

    echo "============================================================"

    exit "$EXIT_STATUS"
fi

if [[ "$COMPARE_WORKTREE" -eq 1 ]]; then
    MODIFIED_FILES=$(
        git diff \
            --name-only \
            --diff-filter=ACMR \
            "$DIFF_BASE" \
            -- "$MODULE_DIR/*.yaml" \
        2>/dev/null || true
    )

    # A brand new module is not tracked yet, so git diff ignores it.
    UNTRACKED_FILES=$(
        git ls-files \
            --others \
            --exclude-standard \
            -- "$MODULE_DIR/*.yaml" \
        2>/dev/null || true
    )

    MODIFIED_FILES=$(
        printf '%s\n%s\n' "$MODIFIED_FILES" "$UNTRACKED_FILES" |
            sed '/^$/d' |
            sort -u
    )
else
    MODIFIED_FILES=$(
        git diff \
            --name-only \
            --diff-filter=ACMR \
            "$DIFF_BASE" HEAD \
            -- "$MODULE_DIR/*.yaml" \
        2>/dev/null || true
    )
fi

# ============================================================
# No modified files
# ============================================================

if [[ -z "$MODIFIED_FILES" ]]; then
    echo ""
    ok "No modules modified"

    echo ""
    echo "============================================================"

    if [[ "$EXIT_STATUS" -eq 0 ]]; then
        echo "${GREEN}✓ Version checks passed${RESET}"
    else
        echo "${RED}❌ Validation failed${RESET}"
    fi

    echo "============================================================"

    exit "$EXIT_STATUS"
fi

echo ""
echo "Modified YAML files:"

while IFS= read -r yaml_file; do
    [[ -n "$yaml_file" ]] || continue
    echo "  - $yaml_file"
done <<< "$MODIFIED_FILES"

# ============================================================
# 3. Every modified module is above the last release
# ============================================================

echo ""
echo "=== Checking modified modules ==="

declare -A VERSION_MODULES=()

CHECKED_MODULES=0

while IFS= read -r yaml_file; do

    [[ -n "$yaml_file" ]] || continue

    # File may have been deleted.
    if [[ ! -f "$yaml_file" ]]; then
        warn "$yaml_file: file no longer exists, skipped"
        continue
    fi

    CHECKED_MODULES=$((CHECKED_MODULES + 1))

    # The structural check already reported anything wrong with
    # this file; re-read the version without reporting twice.
    module_version=$(sensor_field "$(version_sensor_info "$yaml_file" || true)" version)

    if [[ ! "$module_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # Already reported by the structural check.
        continue
    fi

    # --------------------------------------------------------
    # Version must be greater than last release
    # --------------------------------------------------------

    if version_greater_than "$module_version" "$LAST_VERSION"; then
        ok "$yaml_file: version $module_version > $LAST_VERSION"
    else
        fail "$yaml_file: version $module_version must be greater than last release $LAST_VERSION"
    fi

    # --------------------------------------------------------
    # Group modules by version
    # --------------------------------------------------------

    if [[ -n "${VERSION_MODULES[$module_version]:-}" ]]; then
        VERSION_MODULES["$module_version"]+=" $yaml_file"
    else
        VERSION_MODULES["$module_version"]="$yaml_file"
    fi

done <<< "$MODIFIED_FILES"

# ============================================================
# 4. All modified modules must use exactly the same version
# ============================================================

echo ""
echo "=== Checking version consistency ==="

if [[ "$CHECKED_MODULES" -eq 0 ]]; then

    ok "Modified modules were all deleted, nothing to compare"

elif [[ "${#VERSION_MODULES[@]}" -eq 0 ]]; then

    # Every modified module failed the structural check; it has
    # already been reported.
    warn "No valid versioned module among the modified files"

elif [[ "${#VERSION_MODULES[@]}" -gt 1 ]]; then

    fail "Modified modules do not share the same version"

    echo ""

    for version in "${!VERSION_MODULES[@]}"; do

        echo "  Version $version:"

        # shellcheck disable=SC2086
        for file in ${VERSION_MODULES[$version]}; do
            echo "    - $file"
        done

    done

else

    for version in "${!VERSION_MODULES[@]}"; do
        ok "All modified modules use version $version"
    done

fi

# ============================================================
# 5. Final result
# ============================================================

echo ""
echo "============================================================"

if [[ "$EXIT_STATUS" -eq 0 ]]; then
    echo "${GREEN}✓ Version checks passed${RESET}"
else
    echo "${RED}❌ Validation failed${RESET}"
fi

echo "============================================================"

exit "$EXIT_STATUS"
