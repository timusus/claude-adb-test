#!/bin/bash
# Scroll through a list to find an element
# Usage: scroll-to-find.sh <resource-id|text> [max_scrolls] [direction]
# Example: scroll-to-find.sh "Settings" 10 down
#          scroll-to-find.sh myElement 5 up

set -e
source "$(dirname "${BASH_SOURCE[0]}")/_dump.sh"
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

if [ -z "$1" ]; then
    echo "Usage: scroll-to-find.sh <resource-id|text> [max_scrolls] [direction]" >&2
    echo "  direction: down (default), up" >&2
    exit 1
fi

QUERY="$1"
MAX_SCROLLS="${2:-10}"
DIRECTION="${3:-down}"
TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

# Get screen dimensions
SCREEN_SIZE=$(adb shell wm size | grep -oE '[0-9]+x[0-9]+')
WIDTH=$(echo "$SCREEN_SIZE" | cut -d'x' -f1)
HEIGHT=$(echo "$SCREEN_SIZE" | cut -d'x' -f2)

# Calculate scroll coordinates (center of screen, 1/3 scroll distance)
CENTER_X=$((WIDTH / 2))
if [ "$DIRECTION" = "down" ]; then
    START_Y=$((HEIGHT * 2 / 3))
    END_Y=$((HEIGHT / 3))
else
    START_Y=$((HEIGHT / 3))
    END_Y=$((HEIGHT * 2 / 3))
fi

echo "Searching for '$QUERY' (max ${MAX_SCROLLS} scrolls ${DIRECTION})..."

check_element() {
    if ! do_dump "$TMPFILE" 2>/dev/null; then
        return 1
    fi
    python3 "$SCRIPT_DIR/_xml_query.py" "$TMPFILE" any "$QUERY" >/dev/null 2>&1
}

# Check if already visible
if check_element; then
    echo "FOUND: '$QUERY' (already visible)"
    exit 0
fi

# Scroll and search
for ((i=1; i<=MAX_SCROLLS; i++)); do
    echo "Scroll $i/$MAX_SCROLLS..."
    adb shell input swipe "$CENTER_X" "$START_Y" "$CENTER_X" "$END_Y" 800
    sleep 0.5

    if check_element; then
        echo "FOUND: '$QUERY' after $i scroll(s)"
        exit 0
    fi
done

echo "NOT FOUND: '$QUERY' after $MAX_SCROLLS scrolls" >&2
exit 1
