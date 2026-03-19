#!/bin/bash
# Tap at coordinates
# Usage: tap.sh <x> <y>

if [ $# -lt 2 ]; then
    echo "Usage: tap.sh <x> <y>" >&2
    exit 1
fi

X="$1"
Y="$2"

# Validate coordinates are numbers
if ! [[ "$X" =~ ^[0-9]+$ ]] || ! [[ "$Y" =~ ^[0-9]+$ ]]; then
    echo "Error: Coordinates must be positive integers" >&2
    exit 1
fi

adb shell input tap "$X" "$Y"

if [ $? -eq 0 ]; then
    echo "Tapped ($X, $Y)"
else
    echo "Error: Tap failed" >&2
    exit 1
fi
