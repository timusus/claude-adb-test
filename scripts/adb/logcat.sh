#!/bin/bash
# View logcat output with optional filtering
# Usage: logcat.sh [package] [--errors] [--lines N]
#
# package    Filter by app package name (finds PID automatically)
# --errors   Show only error-level messages (*:E)
# --lines N  Number of recent lines (default: 50)

PACKAGE=""
ERRORS_ONLY=false
LINES=50

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --errors|-e)
            ERRORS_ONLY=true
            shift
            ;;
        --lines|-n)
            LINES="$2"
            shift 2
            ;;
        *)
            PACKAGE="$1"
            shift
            ;;
    esac
done

# Build logcat command as array (avoids eval)
CMD=(adb logcat -d -t "$LINES")

if [ -n "$PACKAGE" ]; then
    # Get PID for package
    PID=$(adb shell pidof "$PACKAGE" 2>/dev/null | tr -d '\r')

    if [ -n "$PID" ]; then
        CMD+=(--pid="$PID")
        echo "Filtering by package: $PACKAGE (PID: $PID)" >&2
    else
        echo "Warning: Package '$PACKAGE' not running, showing unfiltered logcat" >&2
    fi
fi

if $ERRORS_ONLY; then
    CMD+=("*:E")
fi

"${CMD[@]}"
