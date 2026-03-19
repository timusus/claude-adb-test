---
description: "ADB input commands: touch, text, gestures, key events"
allowed-tools: ["Bash(adb:*)", "Bash(~/.claude/scripts/adb/*:*)"]
---

# ADB Input Commands

## Touch Interactions

```bash
# Tap (use helper — validates coordinates)
~/.claude/scripts/adb/tap.sh X Y

# Tap by element id or text (recommended — finds coords automatically)
~/.claude/scripts/adb/tap-by-id.sh submitButton
~/.claude/scripts/adb/tap-by-text.sh "Settings"

# Long press (stationary swipe, default 1000ms)
~/.claude/scripts/adb/long-press.sh X Y
~/.claude/scripts/adb/long-press.sh X Y 2000   # custom duration

# Double tap
~/.claude/scripts/adb/tap.sh X Y && sleep 0.1 && ~/.claude/scripts/adb/tap.sh X Y

# Swipe by direction (auto-detects screen size)
~/.claude/scripts/adb/swipe.sh down    # scroll down
~/.claude/scripts/adb/swipe.sh up      # scroll up
~/.claude/scripts/adb/swipe.sh left    # swipe left
~/.claude/scripts/adb/swipe.sh right   # swipe right

# Swipe with explicit coordinates
~/.claude/scripts/adb/swipe.sh 540 1500 540 500 300
```

## Text Input

```bash
# Type text (handles spaces and special chars)
~/.claude/scripts/adb/type-text.sh "hello world"

# Clear field first, then type
~/.claude/scripts/adb/type-text.sh --clear "new text"

# Raw adb (if needed — spaces use %s)
adb shell input text "hello%sworld"
```

## Key Events

```bash
# Using helper (friendly names)
~/.claude/scripts/adb/key.sh back
~/.claude/scripts/adb/key.sh home
~/.claude/scripts/adb/key.sh enter
~/.claude/scripts/adb/key.sh menu
~/.claude/scripts/adb/key.sh delete
~/.claude/scripts/adb/key.sh tab
~/.claude/scripts/adb/key.sh escape
```

### Media Controls
```bash
~/.claude/scripts/adb/key.sh play_pause
~/.claude/scripts/adb/key.sh next
~/.claude/scripts/adb/key.sh previous
~/.claude/scripts/adb/key.sh volume_up
~/.claude/scripts/adb/key.sh volume_down
```

### Raw Keycodes (when helper doesn't cover it)
```bash
adb shell input keyevent KEYCODE_DEL          # Backspace
adb shell input keyevent KEYCODE_FORWARD_DEL  # Delete
adb shell input keyevent KEYCODE_MOVE_HOME    # Start of line
adb shell input keyevent KEYCODE_MOVE_END     # End of line
adb shell input keyevent KEYCODE_AT           # @
adb shell input keyevent KEYCODE_POUND        # #
```
