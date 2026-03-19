---
description: "ADB testing for Jetpack Compose apps"
allowed-tools: ["Bash(adb:*)", "Bash(~/.claude/scripts/adb/*:*)"]
---

# Jetpack Compose Testing via ADB

Compose apps work differently from traditional View-based apps.

## Key Differences

1. **No resource-ids by default** — Compose elements don't automatically get resource-ids
2. **testTag is the equivalent** — `Modifier.testTag("myTag")` maps to `resource-id` in uiautomator
3. **Semantics tree** — Only elements with semantic properties appear in `ui-dump.sh`

## Finding Compose Elements

### By text (most reliable)
```bash
~/.claude/scripts/adb/tap-by-text.sh "Submit"
~/.claude/scripts/adb/tap-by-text.sh "Settings"
```

### By testTag (shows as resource-id in ui-dump)
```bash
~/.claude/scripts/adb/ui-dump.sh | grep "submitButton"
# Then tap using center coords from output
```

### By content-desc (accessibility labels)
```bash
~/.claude/scripts/adb/ui-dump.sh | grep "Submit form"
```

## Common Compose Patterns

### Navigate Bottom Nav
```bash
~/.claude/scripts/adb/tap-by-text.sh "Home"
~/.claude/scripts/adb/tap-by-text.sh "Settings"
```

### Toggle Switch
```bash
# Find by associated text in ui-dump
~/.claude/scripts/adb/ui-dump.sh | grep -A2 "Dark mode"
# Tap the clickable element
```

### Scroll LazyColumn
```bash
~/.claude/scripts/adb/swipe.sh down
# Or find specific item
~/.claude/scripts/adb/scroll-to-find.sh "Item 50" 20 down
```

### Type in TextField
```bash
~/.claude/scripts/adb/tap-by-text.sh "Search"   # focus the field
~/.claude/scripts/adb/type-text.sh "query"
```

## Elements Missing from ui-dump?

- **Off-screen in LazyColumn**: `swipe.sh down` to reveal
- **No semantics**: Developer needs to add `Modifier.testTag()` or `Modifier.semantics { contentDescription = "..." }`
- **Custom drawing**: Elements using `Canvas` without semantics won't appear
- **Animations in progress**: `sleep 0.5` to let transitions settle

## Requesting testTags

If elements lack identifiers, add to source:
```kotlin
Modifier.testTag("uniqueId")
// or
Modifier.semantics { contentDescription = "Description" }
```
