#!/bin/bash
# Tap an element by its resource-id
# Usage: tap-by-id.sh <resource-id-suffix>
# Example: tap-by-id.sh submitButton
#          tap-by-id.sh com.app:id/submitButton

set -e
source "$(dirname "${BASH_SOURCE[0]}")/_dump.sh"
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

if [ -z "$1" ]; then
    echo "Usage: tap-by-id.sh <resource-id>" >&2
    echo "Example: tap-by-id.sh submitButton" >&2
    exit 1
fi

RESOURCE_ID="$1"
TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

# Dump UI hierarchy with retry
if ! do_dump "$TMPFILE"; then
    exit 1
fi

# Find element by resource-id
RESULT=$(python3 "$SCRIPT_DIR/_xml_query.py" "$TMPFILE" resource-id "$RESOURCE_ID" | head -1)

if [ -z "$RESULT" ]; then
    echo "ERROR: Element with resource-id '$RESOURCE_ID' not found" >&2
    exit 1
fi

# Parse tab-separated result
BOUNDS=$(echo "$RESULT" | cut -f1)

# Parse bounds [LEFT,TOP][RIGHT,BOTTOM]
LEFT=$(echo "$BOUNDS" | sed -E 's/\[([0-9]+),.*/\1/')
TOP=$(echo "$BOUNDS" | sed -E 's/\[[0-9]+,([0-9]+)\].*/\1/')
RIGHT=$(echo "$BOUNDS" | sed -E 's/.*\[([0-9]+),[0-9]+\]/\1/')
BOTTOM=$(echo "$BOUNDS" | sed -E 's/.*\[[0-9]+,([0-9]+)\]/\1/')

# Calculate center
X=$(( (LEFT + RIGHT) / 2 ))
Y=$(( (TOP + BOTTOM) / 2 ))

echo "Found: $RESOURCE_ID at bounds [$LEFT,$TOP][$RIGHT,$BOTTOM]"
echo "Tapping at ($X, $Y)"

adb shell input tap "$X" "$Y"
