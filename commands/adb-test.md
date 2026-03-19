---
description: "Test Android apps via ADB on connected device/emulator"
allowed-tools: ["Bash(adb:*)", "Bash(~/.claude/scripts/adb/*:*)"]
---

# ADB Testing

Test Android applications using ADB on connected devices/emulators.

## Critical Rule

**NEVER estimate coordinates from screenshots.** Always use `ui-dump.sh` to find exact element bounds.

## Core Workflow

```bash
~/.claude/scripts/adb/ui-dump.sh          # 1. See what's on screen
~/.claude/scripts/adb/tap.sh 200 550      # 2. Tap using center coords from dump
sleep 0.5
~/.claude/scripts/adb/ui-dump.sh          # 3. Verify state change
```

## Helper Scripts

All at `~/.claude/scripts/adb/`:

| Script | Usage |
|--------|-------|
| `ui-dump.sh [--raw]` | UI hierarchy — formatted elements with center coords, retry on null root |
| `screenshot.sh [name]` | Screenshot (max 1000px, WebP) |
| `tap.sh <x> <y>` | Tap coordinates |
| `tap-by-id.sh <id>` | Tap by resource-id |
| `tap-by-text.sh <text>` | Tap by visible text |
| `long-press.sh <x> <y> [ms]` | Long press (default 1000ms) |
| `swipe.sh <direction\|coords>` | Swipe up/down/left/right or explicit coords |
| `type-text.sh [--clear] <text>` | Type text (--clear erases first) |
| `key.sh <name\|code>` | Key event: back, home, enter, menu, etc. |
| `find-element.sh <query>` | Element properties and tap coords |
| `wait-for-element.sh <query> [timeout]` | Wait for element (default 10s) |
| `scroll-to-find.sh <query> [scrolls] [dir]` | Scroll to find element |
| `install-apk.sh <path> [--grant-permissions]` | Install APK (-r -t, optional -g) |
| `logcat.sh [package] [--errors] [--lines N]` | View logs (default 50 lines) |

Full reference: `~/.claude/skills/android-device/SKILL.md`

## Sub-commands

| Command | Content |
|---------|---------|
| `/adb-test:input` | Touch, text input, key events, gestures |
| `/adb-test:lifecycle` | App launch, stop, install, permissions |
| `/adb-test:recipes` | Common testing patterns and workflows |
| `/adb-test:troubleshoot` | Error handling and debugging |
| `/adb-test:compose` | Jetpack Compose testing specifics |
| `/adb-test:advanced` | Broadcasts, emulator control, performance |
