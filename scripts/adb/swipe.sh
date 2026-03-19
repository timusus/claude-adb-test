#!/bin/bash
# Swipe gesture on device
# Usage:
#   swipe.sh <direction>                        — direction: up, down, left, right
#   swipe.sh <x1> <y1> <x2> <y2> [duration_ms] — explicit coordinates
#
# Direction-based swipes auto-detect screen size and swipe from 75% to 25%
# along the swipe axis, centered on the perpendicular axis.
# Default duration: 800ms

DURATION=800

# Check if first arg is a direction
case "$1" in
    up|down|left|right)
        DIRECTION="$1"

        # Get screen size
        SIZE_OUTPUT=$(adb shell wm size 2>/dev/null | grep -oE '[0-9]+x[0-9]+' | tail -1)
        if [ -z "$SIZE_OUTPUT" ]; then
            echo "Error: Could not determine screen size" >&2
            exit 1
        fi

        SCREEN_W=$(echo "$SIZE_OUTPUT" | cut -dx -f1)
        SCREEN_H=$(echo "$SIZE_OUTPUT" | cut -dx -f2)

        CENTER_X=$((SCREEN_W / 2))
        CENTER_Y=$((SCREEN_H / 2))

        case "$DIRECTION" in
            up)
                X1=$CENTER_X; Y1=$((SCREEN_H * 75 / 100))
                X2=$CENTER_X; Y2=$((SCREEN_H * 25 / 100))
                ;;
            down)
                X1=$CENTER_X; Y1=$((SCREEN_H * 25 / 100))
                X2=$CENTER_X; Y2=$((SCREEN_H * 75 / 100))
                ;;
            left)
                X1=$((SCREEN_W * 75 / 100)); Y1=$CENTER_Y
                X2=$((SCREEN_W * 25 / 100)); Y2=$CENTER_Y
                ;;
            right)
                X1=$((SCREEN_W * 25 / 100)); Y1=$CENTER_Y
                X2=$((SCREEN_W * 75 / 100)); Y2=$CENTER_Y
                ;;
        esac

        adb shell input swipe "$X1" "$Y1" "$X2" "$Y2" "$DURATION"

        if [ $? -eq 0 ]; then
            echo "Swiped $DIRECTION (${X1},${Y1}) -> (${X2},${Y2}) on ${SCREEN_W}x${SCREEN_H} screen"
        else
            echo "Error: Swipe failed" >&2
            exit 1
        fi
        ;;

    *)
        # Explicit coordinates mode
        if [ $# -lt 4 ]; then
            echo "Usage: swipe.sh <direction>  (up/down/left/right)" >&2
            echo "       swipe.sh <x1> <y1> <x2> <y2> [duration_ms]" >&2
            exit 1
        fi

        X1="$1"; Y1="$2"; X2="$3"; Y2="$4"
        [ -n "$5" ] && DURATION="$5"

        for val in "$X1" "$Y1" "$X2" "$Y2" "$DURATION"; do
            if ! [[ "$val" =~ ^[0-9]+$ ]]; then
                echo "Error: All coordinates and duration must be positive integers" >&2
                exit 1
            fi
        done

        adb shell input swipe "$X1" "$Y1" "$X2" "$Y2" "$DURATION"

        if [ $? -eq 0 ]; then
            echo "Swiped (${X1},${Y1}) -> (${X2},${Y2}) ${DURATION}ms"
        else
            echo "Error: Swipe failed" >&2
            exit 1
        fi
        ;;
esac
