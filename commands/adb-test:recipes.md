---
description: "ADB testing recipes and common patterns"
allowed-tools: ["Bash(adb:*)", "Bash(~/.claude/scripts/adb/*:*)"]
---

# ADB Testing Recipes

## Verify Element Exists

```bash
~/.claude/scripts/adb/find-element.sh targetElement
# or check ui-dump output
~/.claude/scripts/adb/ui-dump.sh | grep "Submit"
```

## Tap Button by Text

```bash
~/.claude/scripts/adb/tap-by-text.sh "Submit"
```

## Toggle a Switch

```bash
~/.claude/scripts/adb/find-element.sh mySwitch   # check current state
~/.claude/scripts/adb/tap-by-id.sh mySwitch       # toggle
~/.claude/scripts/adb/find-element.sh mySwitch   # verify new state
```

## Fresh Install Test

```bash
adb shell pm clear com.example.app
adb shell monkey -p com.example.app -c android.intent.category.LAUNCHER 1
sleep 2
~/.claude/scripts/adb/screenshot.sh fresh_install
```

## Wait Then Act

```bash
~/.claude/scripts/adb/wait-for-element.sh submitButton 15
~/.claude/scripts/adb/tap-by-id.sh submitButton
```

## Scroll List to Find Item

```bash
~/.claude/scripts/adb/scroll-to-find.sh "Privacy" 10 down
~/.claude/scripts/adb/tap-by-text.sh "Privacy"
```

## Capture Before/After

```bash
~/.claude/scripts/adb/screenshot.sh before
# ... perform actions ...
~/.claude/scripts/adb/screenshot.sh after
```

## Navigate and Verify

```bash
~/.claude/scripts/adb/tap-by-text.sh "Settings"
sleep 0.5
~/.claude/scripts/adb/wait-for-element.sh settingsTitle 5
```

## Handle Permission Dialog

```bash
~/.claude/scripts/adb/wait-for-element.sh "Allow" 5
~/.claude/scripts/adb/tap-by-text.sh "Allow"
```

## Type Into Search

```bash
~/.claude/scripts/adb/tap-by-id.sh searchField
~/.claude/scripts/adb/type-text.sh "search query"
~/.claude/scripts/adb/key.sh enter
```
