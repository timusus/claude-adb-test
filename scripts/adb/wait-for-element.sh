#!/bin/bash
# Wait for an element to appear in the UI hierarchy
# Usage: wait-for-element.sh <resource-id|text> [timeout_seconds]
# Example: wait-for-element.sh submitButton 10
#          wait-for-element.sh "Loading complete" 30

set -e
source "$(dirname "${BASH_SOURCE[0]}")/_dump.sh"
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

if [ -z "$1" ]; then
    echo "Usage: wait-for-element.sh <resource-id|text> [timeout_seconds]" >&2
    echo "Example: wait-for-element.sh submitButton 10" >&2
    exit 1
fi

QUERY="$1"
TIMEOUT="${2:-10}"
TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

echo "Waiting for '$QUERY' (timeout: ${TIMEOUT}s)..."

for ((i=1; i<=TIMEOUT; i++)); do
    if do_dump "$TMPFILE" 2>/dev/null; then
        RESULT=$(python3 "$SCRIPT_DIR/_xml_query.py" "$TMPFILE" any "$QUERY" 2>/dev/null | head -1)
        if [ -n "$RESULT" ]; then
            FOUND_TEXT=$(echo "$RESULT" | cut -f2)
            echo "FOUND: '$FOUND_TEXT' after ${i}s"
            exit 0
        fi
    fi

    sleep 1
done

echo "TIMEOUT: '$QUERY' not found after ${TIMEOUT}s" >&2
exit 1
