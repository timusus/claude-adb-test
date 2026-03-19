---
description: "ADB app lifecycle: launch, stop, install, permissions"
allowed-tools: ["Bash(adb:*)", "Bash(~/.claude/scripts/adb/*:*)"]
---

# ADB App Lifecycle

## Installing

```bash
# Using helper (recommended — adds -r -t flags automatically)
~/.claude/scripts/adb/install-apk.sh path/to/app.apk
~/.claude/scripts/adb/install-apk.sh path/to/app.apk --grant-permissions

# Raw adb
adb install -r path/to/app.apk
adb -s emulator-5554 install path/to/app.apk   # specific device

# Uninstall
adb uninstall com.example.app
adb uninstall -k com.example.app   # keep data
```

## Launching Apps

```bash
# By package (default launcher activity)
adb shell monkey -p com.example.app -c android.intent.category.LAUNCHER 1

# Specific activity
adb shell am start -n com.example.app/.MainActivity

# Deep link
adb shell am start -a android.intent.action.VIEW -d "https://example.com/path"

# With extras
adb shell am start -n com.example.app/.MainActivity --es key "value" --ei count 123
```

## Stopping Apps

```bash
# Force stop (kills process)
adb shell am force-stop com.example.app

# Clear all data (like fresh install)
adb shell pm clear com.example.app
```

## Package Information

```bash
adb shell pm list packages | grep example   # Search packages
adb shell pm path com.example.app           # APK path
adb shell dumpsys package com.example.app | grep versionName
adb shell dumpsys package com.example.app | grep Activity
```

## Permissions

```bash
adb shell pm grant com.example.app android.permission.READ_EXTERNAL_STORAGE
adb shell pm revoke com.example.app android.permission.READ_EXTERNAL_STORAGE
adb shell dumpsys package com.example.app | grep permission
```
