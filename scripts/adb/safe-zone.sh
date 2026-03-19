#!/bin/bash
# Detect system bar insets (status bar, navigation bar) on connected device
# Usage: safe-zone.sh
#
# Outputs safe zone bounds as: SAFE_TOP SAFE_BOTTOM SCREEN_WIDTH SCREEN_HEIGHT
# Example: 83 2148 1080 2280
#   meaning: safe tapping area is Y=83 to Y=2148 on a 1080x2280 screen

# Get screen size
SIZE_OUTPUT=$(adb shell wm size 2>/dev/null | grep -oE '[0-9]+x[0-9]+' | tail -1)
if [ -z "$SIZE_OUTPUT" ]; then
    echo "Error: Could not determine screen size" >&2
    exit 1
fi
SCREEN_W=$(echo "$SIZE_OUTPUT" | cut -dx -f1)
SCREEN_H=$(echo "$SIZE_OUTPUT" | cut -dx -f2)

# Strategy 1: Use mStable from dumpsys window (most reliable, works on API 28+)
STABLE=$(adb shell dumpsys window 2>/dev/null | grep -oE 'mStable=\[([0-9]+),([0-9]+)\]\[([0-9]+),([0-9]+)\]' | head -1)
if [ -n "$STABLE" ]; then
    SAFE_TOP=$(echo "$STABLE" | sed -E 's/mStable=\[[0-9]+,([0-9]+)\]\[[0-9]+,[0-9]+\]/\1/')
    SAFE_BOTTOM=$(echo "$STABLE" | sed -E 's/mStable=\[[0-9]+,[0-9]+\]\[[0-9]+,([0-9]+)\]/\1/')
    echo "$SAFE_TOP $SAFE_BOTTOM $SCREEN_W $SCREEN_H"
    exit 0
fi

# Strategy 2: Parse individual bar frames (fallback)
STATUS_BOTTOM=0
STATUS_FRAME=$(adb shell dumpsys window StatusBar 2>/dev/null | grep -oE 'mFrame=\[([0-9]+),([0-9]+)\]\[([0-9]+),([0-9]+)\]' | head -1)
if [ -n "$STATUS_FRAME" ]; then
    STATUS_BOTTOM=$(echo "$STATUS_FRAME" | sed -E 's/mFrame=\[[0-9]+,[0-9]+\]\[[0-9]+,([0-9]+)\]/\1/')
fi

NAV_TOP=$SCREEN_H
NAV_FRAME=$(adb shell dumpsys window NavigationBar 2>/dev/null | grep -oE 'mFrame=\[([0-9]+),([0-9]+)\]\[([0-9]+),([0-9]+)\]' | head -1)
if [ -n "$NAV_FRAME" ]; then
    NAV_TOP=$(echo "$NAV_FRAME" | sed -E 's/mFrame=\[[0-9]+,([0-9]+)\]\[[0-9]+,[0-9]+\]/\1/')
fi

echo "$STATUS_BOTTOM $NAV_TOP $SCREEN_W $SCREEN_H"
