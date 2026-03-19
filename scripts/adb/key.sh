#!/bin/bash
# Send key event to device
# Usage: key.sh <key_name|keycode>
#
# Friendly names: back, home, enter, menu, recents, power, delete,
#   volume_up, volume_down, mute, play_pause, next, previous, stop,
#   tab, escape, space, dpad_up, dpad_down, dpad_left, dpad_right, dpad_center
#
# Also accepts raw keycode numbers (e.g., key.sh 66)

if [ $# -lt 1 ]; then
    echo "Usage: key.sh <key_name|keycode>" >&2
    echo "Names: back, home, enter, menu, recents, power, delete," >&2
    echo "  volume_up, volume_down, mute, play_pause, next, previous, stop," >&2
    echo "  tab, escape, space, dpad_up, dpad_down, dpad_left, dpad_right, dpad_center" >&2
    exit 1
fi

KEY=$(echo "$1" | tr '[:upper:]' '[:lower:]')

# Map friendly names to keycodes
case "$KEY" in
    back)         KEYCODE="KEYCODE_BACK" ;;
    home)         KEYCODE="KEYCODE_HOME" ;;
    enter|return) KEYCODE="KEYCODE_ENTER" ;;
    menu)         KEYCODE="KEYCODE_MENU" ;;
    recents)      KEYCODE="KEYCODE_APP_SWITCH" ;;
    power)        KEYCODE="KEYCODE_POWER" ;;
    delete|del)   KEYCODE="KEYCODE_DEL" ;;
    volume_up)    KEYCODE="KEYCODE_VOLUME_UP" ;;
    volume_down)  KEYCODE="KEYCODE_VOLUME_DOWN" ;;
    mute)         KEYCODE="KEYCODE_VOLUME_MUTE" ;;
    play_pause)   KEYCODE="KEYCODE_MEDIA_PLAY_PAUSE" ;;
    play)         KEYCODE="KEYCODE_MEDIA_PLAY" ;;
    pause)        KEYCODE="KEYCODE_MEDIA_PAUSE" ;;
    next)         KEYCODE="KEYCODE_MEDIA_NEXT" ;;
    previous)     KEYCODE="KEYCODE_MEDIA_PREVIOUS" ;;
    stop)         KEYCODE="KEYCODE_MEDIA_STOP" ;;
    tab)          KEYCODE="KEYCODE_TAB" ;;
    escape|esc)   KEYCODE="KEYCODE_ESCAPE" ;;
    space)        KEYCODE="KEYCODE_SPACE" ;;
    dpad_up)      KEYCODE="KEYCODE_DPAD_UP" ;;
    dpad_down)    KEYCODE="KEYCODE_DPAD_DOWN" ;;
    dpad_left)    KEYCODE="KEYCODE_DPAD_LEFT" ;;
    dpad_right)   KEYCODE="KEYCODE_DPAD_RIGHT" ;;
    dpad_center)  KEYCODE="KEYCODE_DPAD_CENTER" ;;
    *)
        # Check if it's a raw keycode number
        if [[ "$KEY" =~ ^[0-9]+$ ]]; then
            KEYCODE="$KEY"
        else
            echo "Error: Unknown key '$KEY'" >&2
            echo "Use a friendly name or raw keycode number" >&2
            exit 1
        fi
        ;;
esac

adb shell input keyevent "$KEYCODE"

if [ $? -eq 0 ]; then
    echo "Key: $KEYCODE"
else
    echo "Error: Key event failed" >&2
    exit 1
fi
