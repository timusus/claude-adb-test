#!/bin/bash
# Find an element and display its properties
# Usage: find-element.sh <resource-id|text>
# Example: find-element.sh submitButton
#          find-element.sh "Settings"
#          find-element.sh "Import"    # partial match finds "Import & Export"

set -e
source "$(dirname "${BASH_SOURCE[0]}")/_dump.sh"
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

if [ -z "$1" ]; then
    echo "Usage: find-element.sh <resource-id|text>" >&2
    exit 1
fi

QUERY="$1"
TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

# Dump UI hierarchy with retry
if ! do_dump "$TMPFILE"; then
    exit 1
fi

# Use the Python XML query to find the element (tries id, text, desc)
RESULT=$(python3 "$SCRIPT_DIR/_xml_query.py" "$TMPFILE" any "$QUERY" | head -1)

if [ -z "$RESULT" ]; then
    echo "NOT FOUND: '$QUERY'" >&2
    exit 1
fi

# Parse tab-separated: bounds, text, content-desc, resource-id, class, clickable, enabled, checked, focused
BOUNDS=$(echo "$RESULT" | cut -f1)
TEXT=$(echo "$RESULT" | cut -f2)
CONTENT_DESC=$(echo "$RESULT" | cut -f3)
RESOURCE_ID=$(echo "$RESULT" | cut -f4)
CLASS=$(echo "$RESULT" | cut -f5)
CLICKABLE=$(echo "$RESULT" | cut -f6)
ENABLED=$(echo "$RESULT" | cut -f7)
CHECKED=$(echo "$RESULT" | cut -f8)
FOCUSED=$(echo "$RESULT" | cut -f9)

echo "=== Element Found ==="
echo ""

[ -n "$RESOURCE_ID" ] && echo "resource-id: $RESOURCE_ID"
[ -n "$TEXT" ] && echo "text: $TEXT"
[ -n "$CONTENT_DESC" ] && echo "content-desc: $CONTENT_DESC"
[ -n "$CLASS" ] && echo "class: $CLASS"
[ -n "$BOUNDS" ] && echo "bounds: $BOUNDS"
[ -n "$CLICKABLE" ] && echo "clickable: $CLICKABLE"
[ -n "$ENABLED" ] && echo "enabled: $ENABLED"
[ -n "$CHECKED" ] && echo "checked: $CHECKED"
[ -n "$FOCUSED" ] && echo "focused: $FOCUSED"

# Calculate tap coordinates
if [ -n "$BOUNDS" ]; then
    LEFT=$(echo "$BOUNDS" | sed -E 's/\[([0-9]+),.*/\1/')
    TOP=$(echo "$BOUNDS" | sed -E 's/\[[0-9]+,([0-9]+)\].*/\1/')
    RIGHT=$(echo "$BOUNDS" | sed -E 's/.*\[([0-9]+),[0-9]+\]/\1/')
    BOTTOM=$(echo "$BOUNDS" | sed -E 's/.*\[[0-9]+,([0-9]+)\]/\1/')
    X=$(( (LEFT + RIGHT) / 2 ))
    Y=$(( (TOP + BOTTOM) / 2 ))
    echo ""
    echo "tap coordinates: ($X, $Y)"
fi
