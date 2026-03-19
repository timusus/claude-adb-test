#!/bin/bash
# Long press at coordinates
# Usage: long-press.sh <x> <y> [duration_ms]
#
# Implements long press via stationary swipe (swipe from point to same point).
# Default duration: 1000ms

if [ $# -lt 2 ]; then
    echo "Usage: long-press.sh <x> <y> [duration_ms]" >&2
    exit 1
fi

X="$1"
Y="$2"
DURATION="${3:-1000}"

# Validate coordinates are numbers
if ! [[ "$X" =~ ^[0-9]+$ ]] || ! [[ "$Y" =~ ^[0-9]+$ ]]; then
    echo "Error: Coordinates must be positive integers" >&2
    exit 1
fi

if ! [[ "$DURATION" =~ ^[0-9]+$ ]]; then
    echo "Error: Duration must be a positive integer (ms)" >&2
    exit 1
fi

adb shell input swipe "$X" "$Y" "$X" "$Y" "$DURATION"

if [ $? -eq 0 ]; then
    echo "Long press at ($X, $Y) for ${DURATION}ms"
else
    echo "Error: Long press failed" >&2
    exit 1
fi
