---
description: "ADB advanced: broadcasts, emulator, performance"
allowed-tools: ["Bash(adb:*)"]
---

# ADB Advanced

## Broadcast Intents

Simulate system events:
```bash
# Battery events
adb shell am broadcast -a android.intent.action.BATTERY_LOW
adb shell am broadcast -a android.intent.action.BATTERY_OKAY

# Network change
adb shell am broadcast -a android.net.conn.CONNECTIVITY_CHANGE

# Custom app broadcast
adb shell am broadcast -a com.app.CUSTOM_ACTION --es data "value"

# Time/timezone
adb shell am broadcast -a android.intent.action.TIME_SET
adb shell am broadcast -a android.intent.action.TIMEZONE_CHANGED
```

## Emulator Control

```bash
# Network conditions (emulator only)
adb emu network delay gprs      # High latency
adb emu network delay none      # Normal
adb emu network speed gsm       # Slow
adb emu network speed full      # Full speed

# GPS location
adb emu geo fix -122.084 37.422  # longitude latitude

# Rotate screen
adb shell settings put system accelerometer_rotation 0
adb shell settings put system user_rotation 1  # 0=0°, 1=90°, 2=180°, 3=270°

# Battery simulation
adb emu power capacity 15       # 15% battery
adb emu power status charging   # or not-charging
```

## Performance Profiling

```bash
adb shell dumpsys gfxinfo com.example.app          # Frame stats
adb shell dumpsys meminfo com.example.app           # Memory
adb shell dumpsys cpuinfo | grep com.example.app    # CPU
adb shell dumpsys gfxinfo com.example.app reset     # Reset stats
```

## Device State

```bash
# Display
adb shell wm size
adb shell wm density
adb shell wm size 1080x1920     # Override
adb shell wm size reset

# Dark mode
adb shell cmd uimode night yes
adb shell cmd uimode night no
```

## File Operations

```bash
adb pull /sdcard/Download/file.txt ./local.txt
adb push ./local.txt /sdcard/Download/file.txt
adb shell ls /sdcard/Download/

# App private data (debug builds)
adb shell run-as com.example.app cat /data/data/com.example.app/shared_prefs/prefs.xml
```

## ADB over WiFi

```bash
adb tcpip 5555                          # USB connected first
adb connect 192.168.1.100:5555          # Then wireless
adb disconnect 192.168.1.100:5555
```

## Screen Recording

```bash
adb shell screenrecord /sdcard/demo.mp4   # Ctrl+C to stop (max 3 min)
adb pull /sdcard/demo.mp4
```
