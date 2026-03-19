#!/bin/bash
# Take a screenshot and save to local .adb-screenshots directory
# Usage: screenshot.sh [filename]
# If no filename provided, uses timestamp
#
# Images are automatically resized to max 1000px (longest dimension)
# and converted to WebP (~60% smaller than PNG) for efficient API usage.
# Original device dimensions are printed for coordinate mapping.
#
# Conversion priority:
#   1. sips (resize) + ImageMagick (WebP) — macOS native resize, best output
#   2. ImageMagick only — resize + WebP in one step
#   3. sips only — resize to PNG (no WebP support in sips)
#   4. No tools — raw PNG from device

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration
MAX_DIMENSION=1000
QUALITY=80

# Use current working directory's .adb-screenshots folder
SCREENSHOT_DIR="${PWD}/.adb-screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Generate filename
if [ -n "$1" ]; then
    FILENAME="$1"
    # Strip any existing extension — we'll add the right one later
    FILENAME="${FILENAME%.*}"
else
    FILENAME="screenshot_$(date +%Y%m%d_%H%M%S)"
fi

TEMP_RAW="${SCREENSHOT_DIR}/${FILENAME}_raw.png"

# Take screenshot
adb exec-out screencap -p > "$TEMP_RAW"

if [ $? -ne 0 ] || [ ! -s "$TEMP_RAW" ]; then
    rm -f "$TEMP_RAW"
    echo "Error: Failed to capture screenshot" >&2
    exit 1
fi

# Detect available tools
HAS_MAGICK=false
HAS_SIPS=false
MAGICK_CMD=""

if command -v magick &> /dev/null; then
    HAS_MAGICK=true
    MAGICK_CMD="magick"
elif command -v convert &> /dev/null; then
    HAS_MAGICK=true
    MAGICK_CMD="convert"
fi

if command -v sips &> /dev/null; then
    HAS_SIPS=true
fi

# Get original dimensions
ORIG_DIMS=""
if $HAS_MAGICK; then
    ORIG_DIMS=$(identify -format "%wx%h" "$TEMP_RAW" 2>/dev/null)
elif $HAS_SIPS; then
    W=$(sips -g pixelWidth "$TEMP_RAW" 2>/dev/null | tail -1 | awk '{print $2}')
    H=$(sips -g pixelHeight "$TEMP_RAW" 2>/dev/null | tail -1 | awk '{print $2}')
    [ -n "$W" ] && [ -n "$H" ] && ORIG_DIMS="${W}x${H}"
fi

# Strategy: sips resize + magick WebP > magick only > sips only > raw
if $HAS_SIPS && $HAS_MAGICK; then
    # Best path: sips for fast native resize, ImageMagick for WebP conversion
    FILEPATH="${SCREENSHOT_DIR}/${FILENAME}.webp"
    TEMP_RESIZED="${SCREENSHOT_DIR}/${FILENAME}_resized.png"

    sips --resampleHeightWidthMax "$MAX_DIMENSION" "$TEMP_RAW" --out "$TEMP_RESIZED" &>/dev/null

    $MAGICK_CMD "$TEMP_RESIZED" -quality "$QUALITY" "$FILEPATH"
    rm -f "$TEMP_RESIZED"

elif $HAS_MAGICK; then
    # ImageMagick only: resize + WebP in one step
    FILEPATH="${SCREENSHOT_DIR}/${FILENAME}.webp"

    $MAGICK_CMD "$TEMP_RAW" \
        -resize "${MAX_DIMENSION}x${MAX_DIMENSION}>" \
        -quality "$QUALITY" \
        "$FILEPATH"

elif $HAS_SIPS; then
    # sips only: resize to PNG (sips can't output WebP)
    FILEPATH="${SCREENSHOT_DIR}/${FILENAME}.png"

    cp "$TEMP_RAW" "$FILEPATH"
    sips --resampleHeightWidthMax "$MAX_DIMENSION" "$FILEPATH" &>/dev/null

else
    # No tools: use raw PNG
    FILEPATH="${SCREENSHOT_DIR}/${FILENAME}.png"
    mv "$TEMP_RAW" "$FILEPATH"
    echo "Warning: No image tools found, screenshot not optimized" >&2
    echo "Original dimensions: ${ORIG_DIMS:-unknown}" >&2
    echo "$FILEPATH"
    exit 0
fi

# Clean up raw temp file
rm -f "$TEMP_RAW"

if [ -f "$FILEPATH" ]; then
    # Report dimensions for coordinate mapping
    NEW_DIMS=""
    if $HAS_MAGICK; then
        NEW_DIMS=$(identify -format "%wx%h" "$FILEPATH" 2>/dev/null)
    elif $HAS_SIPS; then
        W=$(sips -g pixelWidth "$FILEPATH" 2>/dev/null | tail -1 | awk '{print $2}')
        H=$(sips -g pixelHeight "$FILEPATH" 2>/dev/null | tail -1 | awk '{print $2}')
        [ -n "$W" ] && [ -n "$H" ] && NEW_DIMS="${W}x${H}"
    fi

    echo "Original dimensions: ${ORIG_DIMS:-unknown}" >&2
    if [ -n "$ORIG_DIMS" ] && [ -n "$NEW_DIMS" ] && [ "$ORIG_DIMS" != "$NEW_DIMS" ]; then
        echo "Resized: ${ORIG_DIMS} -> ${NEW_DIMS}" >&2
    fi
    echo "$FILEPATH"
else
    echo "Error: Failed to process screenshot" >&2
    exit 1
fi
