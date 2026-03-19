---
name: android-device
description: Use when interacting with Android devices or emulators via ADB — tapping, swiping, typing, screenshots, UI inspection, app install, logcat. Triggers on "test on device", "tap the button", "take a screenshot", "what's on screen", "scroll down", "install the APK", "element not found", "null root node".
---

# Android Device Control via ADB

## Golden Rules

1. **NEVER estimate or guess coordinates from screenshots.** Always use `ui-dump.sh` to get exact element bounds before tapping.
2. **NEVER use raw `adb exec-out screencap` directly.** Always use `screenshot.sh` for screenshots — it saves to the correct local directory, resizes, and converts to WebP.
3. **NEVER tap elements marked `SYSTEM_BAR`.** These overlap the status bar or navigation bar and will trigger system actions instead of app actions.
4. **Prefer elements with `clickable` flag.** If the target element isn't clickable, look for a clickable parent in the dump that contains it.

## When to Use

- Testing app behavior on a real device or emulator
- Verifying UI state after code changes
- Navigating through app screens to reach a specific state
- Capturing screenshots for visual verification
- Debugging UI issues (element not visible, tap not registering)
- Installing and launching builds

## Scripts

All scripts at `~/.claude/scripts/adb/`. Run `<script> --help` or with no args for usage.

### UI Inspection

| Script | Description |
|--------|-------------|
| `ui-dump.sh [--raw]` | Dump UI hierarchy with retry (10x). Formatted element list with `center=(x,y)`, `size=WxH`, safe zone annotations. Raw XML saved to temp file. |
| `screenshot.sh [name]` | Capture screenshot to `.adb-screenshots/`. Max 1000px, WebP. Prints original dimensions for coordinate mapping. |
| `find-element.sh <query>` | Find element by text/id/desc/hint, show properties and tap coords. |
| `wait-for-element.sh <query> [timeout]` | Wait for element to appear (default 10s). |
| `scroll-to-find.sh <query> [scrolls] [dir]` | Scroll to find element in scrollable list. |
| `safe-zone.sh` | Detect status bar and nav bar insets. Returns `SAFE_TOP SAFE_BOTTOM SCREEN_W SCREEN_H`. |

### Input

| Script | Description |
|--------|-------------|
| `tap.sh <x> <y>` | Tap at exact coordinates. |
| `tap-by-id.sh <id>` | Find element by resource-id and tap center. |
| `tap-by-text.sh <text>` | Find element by visible text and tap center. |
| `long-press.sh <x> <y> [ms]` | Long press via stationary swipe. Default 1000ms. |
| `swipe.sh <direction>` | Swipe up/down/left/right. Auto screen size, 75%→25%, 800ms. |
| `swipe.sh <x1> <y1> <x2> <y2> [ms]` | Swipe explicit coordinates. |
| `type-text.sh [--clear] <text>` | Type text. `--clear` erases field first. Handles spaces and special chars. |
| `key.sh <name\|keycode>` | Key event. Names: back, home, enter, menu, delete, volume_up, volume_down, play_pause, next, previous, tab, escape, recents, power, space, dpad_*. |

### App Management

| Script | Description |
|--------|-------------|
| `install-apk.sh <path> [--grant-permissions]` | Install with -r -t. Optional -g for runtime permissions. |
| `logcat.sh [package] [--errors] [--lines N]` | Recent logs. Filters by package PID. Default 50 lines. |

## Core Workflow

```
1. DUMP    → ui-dump.sh           (get element coordinates + safe zone)
2. FIND    → identify target      (by text, id, content-desc, or hint)
3. CHECK   → avoid SYSTEM_BAR     (pick a safe, clickable element)
4. ACT     → tap.sh / type / key  (use center coords from dump)
5. VERIFY  → ui-dump.sh / screenshot.sh  (confirm state change)
```

### Example

```bash
~/.claude/scripts/adb/ui-dump.sh
# [Safe zone: y=83..2148 — elements marked SYSTEM_BAR overlap status/nav bar]
#
# [3] Button "Sign In" id=com.app:id/login bounds=[100,800][300,880] size=200x80 center=(200,840) clickable

~/.claude/scripts/adb/tap.sh 200 840
sleep 0.5
~/.claude/scripts/adb/ui-dump.sh   # verify state change
```

## ui-dump.sh Output Format

Each element shows:
- `[N]` — element index
- `ClassName` — short class name
- `"label"` — text, content-desc, or hint (in priority order)
- `id=...` — resource-id (if present)
- `bounds=[l,t][r,b]` — raw bounds
- `size=WxH` — element dimensions (helps distinguish icons from buttons)
- `center=(x,y)` — tap target coordinates
- Flags: `clickable`, `focused`, `checked`, `checkable`, `disabled`, `hint="..."`, `SYSTEM_BAR`

The `SYSTEM_BAR` flag marks elements whose bounds overlap the status bar or navigation bar. **Never tap these** — you'll trigger system UI instead of app actions.

## Edge Tap Safety

Elements near screen edges are risky:
- **Status bar** (top ~83px on most devices): tapping here opens the notification shade
- **Navigation bar** (bottom ~132px): tapping here triggers back/home/recents
- `ui-dump.sh` automatically detects these zones and flags overlapping elements as `SYSTEM_BAR`
- If you need to tap near an edge, verify the element is fully within the safe zone

## Common Mistakes

1. **Guessing coordinates from a screenshot.** Screenshots are resized — pixel coordinates don't match device coordinates. Always use `ui-dump.sh` for coords.
2. **Tapping without a fresh dump.** The UI changes after every action. A stale dump gives stale coordinates. Dump again before each tap.
3. **Forgetting `sleep` after actions.** Compose animations take time. Add `sleep 0.5` between action and verification.
4. **Using `tap-by-text.sh` for Compose elements without text.** Many Compose elements only have `testTag` (shows as `resource-id`). Use `tap-by-id.sh` or `ui-dump.sh` + `tap.sh` instead.
5. **Skipping verification.** Always confirm the UI changed after an action — either `ui-dump.sh` or `screenshot.sh`.
6. **Tapping SYSTEM_BAR elements.** Elements overlapping status/nav bars will trigger system actions. Use a different element or approach.
7. **Tapping non-clickable elements.** Check for `clickable` flag. If the element isn't clickable, look for a clickable ancestor that contains it.

## Raw ADB Quick Reference

For tasks without a helper script:

| Task | Command |
|------|---------|
| List devices | `adb devices` |
| Screen size | `adb shell wm size` |
| Launch app | `adb shell monkey -p PACKAGE -c android.intent.category.LAUNCHER 1` |
| Stop app | `adb shell am force-stop PACKAGE` |
| Clear data | `adb shell pm clear PACKAGE` |

## Coordinate Mapping

Screenshots are resized (max 1000px). `screenshot.sh` prints original dimensions:
```
Original dimensions: 1080x2400
Resized: 1080x2400 -> 450x1000
```

**Always use coordinates from `ui-dump.sh`** (device space), not from visually inspecting screenshots.

## Jetpack Compose

- **Semantics = accessibility**: Elements appear in hierarchy only with semantic properties (testTag, contentDescription, text).
- **`testTag`**: `Modifier.testTag("tag")` maps to `resource-id` in uiautomator.
- **`hint`**: Now included in ui-dump — text fields with hint text are visible even without entered text.
- **`checkable`**: Toggles, checkboxes, and switches now appear even without text labels.
- **LazyColumn**: Only visible items appear. Use `scroll-to-find.sh` or `swipe.sh down`.
- **Animations**: Add `sleep 0.5` between actions to let transitions settle.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "null root node" | `ui-dump.sh` retries 10x automatically. If persistent: `sleep 1` and retry. |
| Element not in dump | May lack semantics. Compose: add `Modifier.testTag()`. Views: add `contentDescription`. |
| Tap doesn't register | Fresh `ui-dump.sh` — UI may have changed. Check `clickable=true`. Try the clickable parent. |
| Tap hits system bar | Check for `SYSTEM_BAR` flag. Use an element fully within the safe zone. |
| Text input garbled | Use `type-text.sh` for escaping. |
| Swipe overshoots | Swipes use 800ms duration to prevent fling. For precise scrolling, reduce distance or increase duration. |
| Multiple devices | Use `adb -s SERIAL` or `adb -d` (USB) / `adb -e` (emulator). |
