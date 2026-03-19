#!/bin/bash
# Tap an element by its visible text
# Usage: tap-by-text.sh <text>
# Example: tap-by-text.sh "Submit"
#          tap-by-text.sh "Settings"
#          tap-by-text.sh "Import"    # partial match finds "Import & Export"
#
# When multiple elements match, prefers clickable elements over non-clickable ones.

set -e
source "$(dirname "${BASH_SOURCE[0]}")/_dump.sh"
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

if [ -z "$1" ]; then
    echo "Usage: tap-by-text.sh <text>" >&2
    echo "Example: tap-by-text.sh \"Submit\"" >&2
    exit 1
fi

TEXT="$1"
TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

# Dump UI hierarchy with retry
if ! do_dump "$TMPFILE"; then
    exit 1
fi

# Try exact match first, then partial
ALL_RESULTS=$(python3 "$SCRIPT_DIR/_xml_query.py" "$TMPFILE" text-exact "$TEXT" 2>/dev/null)
if [ -z "$ALL_RESULTS" ]; then
    ALL_RESULTS=$(python3 "$SCRIPT_DIR/_xml_query.py" "$TMPFILE" text "$TEXT" 2>/dev/null)
fi

if [ -z "$ALL_RESULTS" ]; then
    echo "ERROR: Element with text '$TEXT' not found" >&2
    exit 1
fi

# Prefer clickable elements when multiple matches exist
# Tab-separated fields: bounds, text, content-desc, resource-id, hint, class, clickable, ...
RESULT=$(echo "$ALL_RESULTS" | awk -F'\t' '$7 == "true"' | head -1)
if [ -z "$RESULT" ]; then
    # No clickable match — fall back to first result
    RESULT=$(echo "$ALL_RESULTS" | head -1)
fi

# Parse tab-separated result: bounds, text, content-desc, resource-id, ...
BOUNDS=$(echo "$RESULT" | cut -f1)
FOUND_TEXT=$(echo "$RESULT" | cut -f2)

# Parse bounds [LEFT,TOP][RIGHT,BOTTOM]
LEFT=$(echo "$BOUNDS" | sed -E 's/\[([0-9]+),.*/\1/')
TOP=$(echo "$BOUNDS" | sed -E 's/\[[0-9]+,([0-9]+)\].*/\1/')
RIGHT=$(echo "$BOUNDS" | sed -E 's/.*\[([0-9]+),[0-9]+\]/\1/')
BOTTOM=$(echo "$BOUNDS" | sed -E 's/.*\[[0-9]+,([0-9]+)\]/\1/')

# Calculate center
X=$(( (LEFT + RIGHT) / 2 ))
Y=$(( (TOP + BOTTOM) / 2 ))

echo "Found: '$FOUND_TEXT' at bounds [$LEFT,$TOP][$RIGHT,$BOTTOM]"
echo "Tapping at ($X, $Y)"

adb shell input tap "$X" "$Y"
