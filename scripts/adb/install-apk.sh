#!/bin/bash
# Install APK on connected device
# Usage: install-apk.sh <path> [--grant-permissions]
#
# Always uses -r (reinstall) and -t (allow test packages).
# --grant-permissions adds -g to auto-grant runtime permissions.

if [ $# -lt 1 ]; then
    echo "Usage: install-apk.sh <path> [--grant-permissions]" >&2
    exit 1
fi

APK_PATH="$1"
GRANT=false

# Check for flags in remaining args
shift
for arg in "$@"; do
    case "$arg" in
        --grant-permissions|-g)
            GRANT=true
            ;;
    esac
done

# Validate APK exists
if [ ! -f "$APK_PATH" ]; then
    echo "Error: APK not found: $APK_PATH" >&2
    exit 1
fi

# Build install command
FLAGS="-r -t"
if $GRANT; then
    FLAGS="$FLAGS -g"
fi

echo "Installing: $(basename "$APK_PATH")"
echo "Flags: $FLAGS"

OUTPUT=$(adb install $FLAGS "$APK_PATH" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ] && echo "$OUTPUT" | grep -q "Success"; then
    echo "Success: $(basename "$APK_PATH") installed"
else
    echo "Error: Installation failed" >&2
    echo "$OUTPUT" >&2
    exit 1
fi
