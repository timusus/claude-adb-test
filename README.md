# claude-adb-test

A Claude Code skill and slash command collection for testing Android apps via ADB on connected devices and emulators.

## What's included

- **Skill** (`skills/android-device/SKILL.md`) — Full reference guide for Android device control via ADB
- **Slash commands** (`commands/`) — Quick-access commands for common ADB testing workflows
- **Helper scripts** (`scripts/adb/`) — Shell scripts that wrap ADB with retry logic, safe zone detection, and formatted output

## Slash commands

| Command | Description |
|---------|-------------|
| `/adb-test` | Main entry point — core workflow and script reference |
| `/adb-test:input` | Touch, text input, key events, gestures |
| `/adb-test:lifecycle` | App launch, stop, install, permissions |
| `/adb-test:recipes` | Common testing patterns and workflows |
| `/adb-test:troubleshoot` | Error handling and debugging |
| `/adb-test:compose` | Jetpack Compose testing specifics |
| `/adb-test:advanced` | Broadcasts, emulator control, performance |

## Installation

Run the install script to copy files to the correct locations:

```bash
./install.sh
```

This copies:
- Commands → `~/.claude/commands/`
- Skill → `~/.claude/skills/android-device/`
- Scripts → `~/.claude/scripts/adb/`

### Manual installation

```bash
# Commands
cp commands/* ~/.claude/commands/

# Skill
mkdir -p ~/.claude/skills/android-device
cp skills/android-device/SKILL.md ~/.claude/skills/android-device/

# Scripts
mkdir -p ~/.claude/scripts/adb
cp scripts/adb/* ~/.claude/scripts/adb/
chmod +x ~/.claude/scripts/adb/*.sh
```

## Prerequisites

- [ADB](https://developer.android.com/tools/adb) installed and on PATH
- A connected Android device or running emulator (`adb devices` should list it)
- Python 3 (for XML parsing in `_xml_query.py`)
- Optional: ImageMagick (for WebP screenshot conversion)

## Usage

In Claude Code, invoke any slash command:

```
/adb-test              # See core workflow and available scripts
/adb-test:input        # Input commands reference
/adb-test:recipes      # Common testing patterns
```

The golden rule: **never guess coordinates from screenshots** — always use `ui-dump.sh` to get exact element bounds before tapping.

## License

MIT
