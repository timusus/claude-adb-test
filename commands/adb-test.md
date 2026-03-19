---
description: "Test Android apps via ADB on connected device/emulator"
allowed-tools: ["Bash(adb:*)", "Bash(~/.claude/scripts/adb/*:*)"]
---

# ADB Testing

Test Android applications using ADB on connected devices/emulators.

**NEVER estimate coordinates from screenshots.** Always use `ui-dump.sh` to find exact element bounds.

All helper scripts are at `~/.claude/scripts/adb/` (abbreviated as `adb/` below).

## Core Workflow

```
1. DUMP    → adb/ui-dump.sh           (get element coordinates)
2. ACT     → adb/tap.sh X Y           (use center coords from dump)
3. WAIT    → sleep 0.5                 (let animations settle)
4. VERIFY  → adb/ui-dump.sh           (confirm state change)
```

## Scripts Quick Reference

| Script | Purpose |
|--------|---------|
| `ui-dump.sh [--raw]` | UI hierarchy with center coords, retry on null root |
| `screenshot.sh [name]` | Screenshot (max 1000px, WebP) |
| `tap.sh X Y` | Tap coordinates |
| `tap-by-id.sh ID` | Tap by resource-id |
| `tap-by-text.sh TEXT` | Tap by visible text |
| `long-press.sh X Y [ms]` | Long press (default 1000ms) |
| `swipe.sh DIRECTION` | Swipe up/down/left/right |
| `type-text.sh [--clear] TEXT` | Type text (--clear erases first) |
| `key.sh NAME` | Key event: back, home, enter, menu, etc. |
| `find-element.sh QUERY` | Element properties and tap coords |
| `wait-for-element.sh QUERY [timeout]` | Wait for element (default 10s) |
| `scroll-to-find.sh QUERY [scrolls] [dir]` | Scroll to find element |
| `install-apk.sh PATH [--grant-permissions]` | Install APK |
| `logcat.sh [package] [--errors] [--lines N]` | View logs (default 50 lines) |

## Go Deeper

| Command | When to use |
|---------|-------------|
| `/adb-test:input` | Need detailed input reference — touch, text, gestures, key events |
| `/adb-test:lifecycle` | Installing, launching, stopping apps, managing permissions |
| `/adb-test:recipes` | Common testing patterns — search, scroll, toggle, verify |
| `/adb-test:compose` | Testing Jetpack Compose apps (testTag, semantics, LazyColumn) |
| `/adb-test:troubleshoot` | Something isn't working — null root, tap misses, text garbled |
| `/adb-test:advanced` | Broadcasts, emulator control, performance profiling, file ops |
