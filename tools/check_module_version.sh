#!/bin/bash
set -euo pipefail

# Colors
GREEN=$(tput setaf 2 2>/dev/null || echo "")
RED=$(tput setaf 1 2>/dev/null || echo "")
YELLOW=$(tput setaf 3 2>/dev/null || echo "")
RESET=$(tput sgr0 2>/dev/null || echo "")

EXIT_STATUS=0

# Read the `id:` of a module's version text_sensor.
version_id() {
    grep -oP '^\s+id:\s+\Kversion_\S+' "$1" 2>/dev/null | head -1
}

# Read the `name:` that follows it. Home Assistant exposes this string as
# `original_name`, and the Lovelace card keys its module detection on it, so a
# typo here is a broken public API rather than a cosmetic slip.
version_name() {
    grep -A1 -P '^\s+id:\s+version_' "$1" 2>/dev/null \
        | grep -oP '^\s+name:\s+"?\K[^"]+' | head -1
}

version_value() {
    grep -oP 'return \{"\K[0-9]+\.[0-9]+\.[0-9]+' "$1" 2>/dev/null | head -1
}

# 1. Every module announces a version
echo "=== Checking version presence in all modules ==="
for yaml_file in solar_router/*.yaml; do
    if ! grep -q "id: version_" "$yaml_file"; then
        echo "${RED}❌ Missing version text_sensor in $yaml_file${RESET}"
        EXIT_STATUS=1
    else
        echo "${GREEN}✓ Version text_sensor found in $yaml_file${RESET}"
    fi
done

# 2. The id and the name match the file name
#
# `name:` is the file name verbatim; `id:` is `version_` plus that name with
# every `-` turned into `_`, because a hyphen is not valid in an ESPHome id.
# Multi-instance packages append their `_${*_unique_id}` to both.
echo ""
echo "=== Checking version id and name against the file name ==="
for yaml_file in solar_router/*.yaml; do
    base_name=$(basename "$yaml_file" .yaml)
    expected_id="version_${base_name//-/_}"

    actual_id=$(version_id "$yaml_file")
    actual_name=$(version_name "$yaml_file")

    case "$actual_id" in
        "$expected_id" | "$expected_id"_'${'*'}') ;;
        *)
            echo "${RED}❌ $yaml_file: id is '$actual_id', expected '$expected_id'${RESET}"
            EXIT_STATUS=1
            ;;
    esac

    case "$actual_name" in
        "$base_name" | "$base_name"_'${'*'}') ;;
        *)
            echo "${RED}❌ $yaml_file: name is '$actual_name', expected '$base_name'${RESET}"
            EXIT_STATUS=1
            ;;
    esac
done
if [ $EXIT_STATUS -eq 0 ]; then
    echo "${GREEN}✓ Every id and name matches its file name${RESET}"
fi

# 3. A module that changed announces a higher version than it did at the last
#    release.
#
#    The comparison is against the module's OWN version at the tag, not against
#    the tag number: a release only bumps the modules it touched, so versions
#    are legitimately uneven across modules (common sits at 1.1.1 while
#    temperature_fan_control is at 1.6.7). Comparing every module to the tag
#    number would demand a pointless bump of all twenty-six.
echo ""
echo "=== Getting last release version ==="
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$LAST_TAG" ]; then
    echo "${YELLOW}⚠ No git tags found, skipping version comparison${RESET}"
    exit $EXIT_STATUS
fi
echo "Last release: $LAST_TAG"

echo ""
echo "=== Checking modified modules ==="
MODIFIED_FILES=$(git diff "$LAST_TAG" --name-only -- 'solar_router/*.yaml' 2>/dev/null || true)

if [ -z "$MODIFIED_FILES" ]; then
    echo "${GREEN}No modules modified since $LAST_TAG${RESET}"
    exit $EXIT_STATUS
fi

echo "Modified modules since $LAST_TAG:"
for f in $MODIFIED_FILES; do
    echo "  - $f"
done
echo ""

for yaml_file in $MODIFIED_FILES; do
    # Deleted in the working tree: nothing to check.
    [ -f "$yaml_file" ] || continue

    echo "Checking $yaml_file..."

    MODULE_VERSION=$(version_value "$yaml_file")
    if [ -z "$MODULE_VERSION" ]; then
        echo "${RED}❌ Could not extract version from $yaml_file${RESET}"
        EXIT_STATUS=1
        continue
    fi

    TAG_MODULE_VERSION=$(git show "$LAST_TAG:$yaml_file" 2>/dev/null \
        | grep -oP 'return \{"\K[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)

    if [ -z "$TAG_MODULE_VERSION" ]; then
        echo "${GREEN}✓ New module or new version sensor ($MODULE_VERSION), nothing to compare${RESET}"
        continue
    fi

    echo "  Now at $LAST_TAG: $TAG_MODULE_VERSION -> $MODULE_VERSION"

    # `sort -V -C` succeeds when the list is already sorted, i.e. when
    # MODULE_VERSION <= TAG_MODULE_VERSION.
    if printf '%s\n%s\n' "$MODULE_VERSION" "$TAG_MODULE_VERSION" | sort -V -C; then
        echo "${RED}❌ Version not raised: $yaml_file changed but is still at $MODULE_VERSION (was $TAG_MODULE_VERSION at $LAST_TAG)${RESET}"
        EXIT_STATUS=1
    else
        echo "${GREEN}✓ Version raised: $TAG_MODULE_VERSION -> $MODULE_VERSION${RESET}"
    fi
done

exit $EXIT_STATUS
