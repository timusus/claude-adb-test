# claude-adb-test

A Claude Code plugin for testing Android apps on real devices and emulators via ADB.

## What's included

- **Skill** — Full reference for Android device control via ADB (auto-activates on device interaction)
- **Slash commands** — Progressive-disclosure commands for common ADB testing workflows
- **Helper scripts** — Shell scripts wrapping ADB with retry logic, safe zone detection, and formatted output

## Commands

| Command | When to use |
|---------|-------------|
| `/adb-test` | Starting point — core workflow, script reference, links to sub-commands |
| `/adb-test:input` | Need detailed touch, text, gesture, or key event reference |
| `/adb-test:lifecycle` | Installing, launching, stopping apps, managing permissions |
| `/adb-test:recipes` | Common patterns — search, scroll, toggle, verify, before/after |
| `/adb-test:compose` | Testing Jetpack Compose apps (testTag, semantics, LazyColumn) |
| `/adb-test:troubleshoot` | Something isn't working — null root, tap misses, text garbled |
| `/adb-test:advanced` | Broadcasts, emulator control, performance profiling, file ops |

## Installation

### As a Claude Code plugin (recommended)

```bash
# Clone and register as a local plugin
git clone https://github.com/timusus/claude-adb-test.git ~/.claude/plugins/adb-test
```

Then add to your Claude Code settings or use `/plugin install`.

### Scripts setup

The helper scripts need to be at `~/.claude/scripts/adb/`. Run the setup script:

```bash
./setup-scripts.sh
```

Or manually:

```bash
mkdir -p ~/.claude/scripts/adb
cp scripts/adb/* ~/.claude/scripts/adb/
chmod +x ~/.claude/scripts/adb/*.sh
```

## Prerequisites

- [ADB](https://developer.android.com/tools/adb) installed and on PATH
- A connected Android device or running emulator (`adb devices` should list it)
- Python 3 (for UI hierarchy XML parsing)
- Optional: ImageMagick (for WebP screenshot conversion)

## The golden rule

**Never guess coordinates from screenshots** — always use `ui-dump.sh` to get exact element bounds before tapping.

## License

MIT
