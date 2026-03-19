---
description: "ADB troubleshooting: common errors and solutions"
allowed-tools: ["Bash(adb:*)", "Bash(~/.claude/scripts/adb/*:*)"]
---

# ADB Troubleshooting

## uiautomator dump fails

### "null root node"

`ui-dump.sh` retries automatically (5 attempts, 500ms between). If still failing:
1. Wait for animations: `sleep 1` before dump
2. Dismiss system dialogs (permissions, updates)
3. App may be loading — wait longer

### "ERROR: could not get idle state"

1. Wait for animations: `sleep 1` before dump
2. Dismiss system dialogs
3. App may be loading

### Dump returns minimal/empty XML

**Causes:**
- WebView content not exposed to accessibility
- App uses FLAG_SECURE (blocks dumps)
- Custom views without accessibility

**Workaround:** Use `screenshot.sh` for visual verification, combine with partial hierarchy info.

## Tap does nothing

**Checklist:**
1. Fresh `ui-dump.sh` — UI may have changed since last dump
2. Element is `clickable=true`
3. Coordinates within screen bounds: `adb shell wm size`
4. Element not covered by another view
5. App is ready: add `sleep 0.5` before tap

## Text input issues

### Special characters don't work

Use `type-text.sh` which handles escaping automatically:
```bash
~/.claude/scripts/adb/type-text.sh "hello@world.com"
```

For individual special chars, use `key.sh`:
```bash
~/.claude/scripts/adb/key.sh space
```

Or raw keycodes:
```bash
adb shell input keyevent KEYCODE_AT      # @
adb shell input keyevent KEYCODE_POUND   # #
```

## App won't launch

### "Activity not found"

```bash
# Find correct activity name
adb shell dumpsys package com.example.app | grep -A5 "Activity"

# Use monkey launcher instead
adb shell monkey -p com.example.app -c android.intent.category.LAUNCHER 1
```

## Multiple devices connected

### "more than one device/emulator"

```bash
adb devices                              # List devices
adb -s emulator-5554 shell input tap ... # Use specific device
adb -d shell ...                         # USB device only
adb -e shell ...                         # Emulator only
```

## Device not authorized

```bash
adb kill-server
adb start-server
# Accept prompt on device
```

## Logcat debugging

```bash
# Quick: recent errors for a package
~/.claude/scripts/adb/logcat.sh com.example.app --errors

# More lines
~/.claude/scripts/adb/logcat.sh com.example.app --lines 200

# Clear then capture fresh
adb logcat -c
# ... reproduce issue ...
~/.claude/scripts/adb/logcat.sh com.example.app
```
