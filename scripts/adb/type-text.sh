#!/bin/bash
# Type text into focused field
# Usage: type-text.sh [--clear] <text>
#
# --clear  Clear the field first (Ctrl+A, Delete) before typing
#
# Handles spaces (replaced with %s) and escapes shell-special characters.

CLEAR=false

if [ "$1" = "--clear" ]; then
    CLEAR=true
    shift
fi

if [ $# -lt 1 ]; then
    echo "Usage: type-text.sh [--clear] <text>" >&2
    exit 1
fi

TEXT="$*"

# Clear field first if requested
if $CLEAR; then
    # Select all (Ctrl+A) then delete
    adb shell input keyevent KEYCODE_MOVE_HOME
    adb shell input keyevent --longpress KEYCODE_SHIFT_LEFT KEYCODE_MOVE_END
    adb shell input keyevent KEYCODE_DEL
fi

# Escape special characters for adb shell input text
# Backslash must be escaped FIRST to avoid double-escaping.
# Replace spaces with %s (adb convention).
# Escape shell metacharacters: \ ( ) < > | ; & * " ' ` ~ # $ { } [ ] ! ?
ESCAPED=$(printf '%s' "$TEXT" | sed -e 's/[\\]/\\\\/g' \
    -e 's/ /%s/g' \
    -e 's/[&]/\\&/g' \
    -e 's/[<]/\\</g' \
    -e 's/[>]/\\>/g' \
    -e 's/[(]/\\(/g' \
    -e 's/[)]/\\)/g' \
    -e 's/[|]/\\|/g' \
    -e 's/[;]/\\;/g' \
    -e "s/[']/\\\\'/g" \
    -e 's/["]/\\"/g' \
    -e 's/[`]/\\`/g' \
    -e 's/[~]/\\~/g' \
    -e 's/[#]/\\#/g' \
    -e 's/[$]/\\$/g' \
    -e 's/[{]/\\{/g' \
    -e 's/[}]/\\}/g' \
    -e 's/[*]/\\*/g')

adb shell input text "$ESCAPED"

if [ $? -eq 0 ]; then
    echo "Typed: $TEXT"
else
    echo "Error: Failed to type text" >&2
    exit 1
fi
