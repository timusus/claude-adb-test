#!/bin/bash
# Install ADB helper scripts to ~/.claude/scripts/adb/
# The plugin handles skills and commands — this only sets up the scripts.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${HOME}/.claude/scripts/adb"

echo "Installing ADB helper scripts..."

mkdir -p "$TARGET"
cp "$SCRIPT_DIR"/scripts/adb/* "$TARGET/"
chmod +x "$TARGET/"*.sh

echo "Installed to $TARGET/"
