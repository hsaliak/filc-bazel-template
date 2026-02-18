#!/bin/bash
# filcc_wrapper.sh
set -e

FILCC=""
for candidate in "external/filc/build/bin/filcc" "external/+filc_ext+filc/build/bin/filcc"; do
    if [ -f "$candidate" ]; then
        FILCC="$candidate"
        break
    fi
done

if [ -z "$FILCC" ]; then
    FILCC=$(find external -name filcc -path "*/build/bin/filcc" -print -quit 2>/dev/null)
fi

if [ -z "$FILCC" ]; then
    echo "Error: filcc_wrapper.sh could not find the filcc binary." >&2
    exit 1
fi

REPO_DIR=$(echo "$FILCC" | sed 's|/build/bin/filcc||')

# Flags for Fil-C
# We use relative paths for Bazel hermeticity.
exec "$FILCC" \
    "--filc-resource-dir=$REPO_DIR/pizfix" \
    "-I$REPO_DIR/pizfix/include" \
    "-I$REPO_DIR/pizfix/stdfil-include" \
    "-I$REPO_DIR/pizfix/os-include" \
    -static \
    "$@"
