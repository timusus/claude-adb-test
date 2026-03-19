#!/bin/bash
# Install claude-adb-test skill, commands, and scripts
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"

echo "Installing claude-adb-test..."

# Commands
mkdir -p "$CLAUDE_DIR/commands"
cp "$SCRIPT_DIR"/commands/adb-test*.md "$CLAUDE_DIR/commands/"
echo "  Commands → $CLAUDE_DIR/commands/"

# Skill
mkdir -p "$CLAUDE_DIR/skills/android-device"
cp "$SCRIPT_DIR/skills/android-device/SKILL.md" "$CLAUDE_DIR/skills/android-device/"
echo "  Skill → $CLAUDE_DIR/skills/android-device/"

# Scripts
mkdir -p "$CLAUDE_DIR/scripts/adb"
cp "$SCRIPT_DIR"/scripts/adb/* "$CLAUDE_DIR/scripts/adb/"
chmod +x "$CLAUDE_DIR/scripts/adb/"*.sh
echo "  Scripts → $CLAUDE_DIR/scripts/adb/"

echo ""
echo "Done! Start a new Claude Code session to use /adb-test commands."
