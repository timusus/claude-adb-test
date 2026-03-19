#!/bin/bash
# Dump UI hierarchy with retry logic and formatted output
# Usage: ui-dump.sh [--raw]
#   --raw    Print raw XML only (skip formatted summary)
#
# Retries up to 10 times on "null root node" errors.
# Outputs a numbered list of interactive elements with coordinates.
# Also saves raw XML to a temp file for detailed inspection.

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/_dump.sh"

RAW_ONLY=false

if [ "$1" = "--raw" ]; then
    RAW_ONLY=true
fi

# Detect system bar insets for safe zone annotation
SAFE_ZONE=$("$SCRIPT_DIR/safe-zone.sh" 2>/dev/null)
SAFE_TOP=$(echo "$SAFE_ZONE" | awk '{print $1}')
SAFE_BOTTOM=$(echo "$SAFE_ZONE" | awk '{print $2}')
SAFE_TOP=${SAFE_TOP:-0}
SAFE_BOTTOM=${SAFE_BOTTOM:-99999}

# Dump with retry
TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

if ! do_dump "$TMPFILE"; then
    exit 1
fi

XML=$(cat "$TMPFILE")

# Save raw XML to local tmp directory
mkdir -p ./tmp
RAW_FILE="./tmp/adb-ui-dump-$(date +%s).xml"
echo "$XML" > "$RAW_FILE"

if $RAW_ONLY; then
    echo "$XML"
    echo "" >&2
    echo "Raw XML saved to: $RAW_FILE" >&2
    exit 0
fi

# Parse XML and output formatted interactive elements
# Filter to nodes that have text, content-desc, or resource-id
echo "$XML" | SAFE_TOP="$SAFE_TOP" SAFE_BOTTOM="$SAFE_BOTTOM" python3 -c "
import sys
import os
import xml.etree.ElementTree as ET
import re

safe_top = int(os.environ.get('SAFE_TOP', '0'))
safe_bottom = int(os.environ.get('SAFE_BOTTOM', '99999'))

xml_input = sys.stdin.read().strip()
if not xml_input:
    sys.exit(1)

# Strip any trailing content after </hierarchy> (safety net)
end_tag = '</hierarchy>'
idx_end = xml_input.rfind(end_tag)
if idx_end >= 0:
    xml_input = xml_input[:idx_end + len(end_tag)]

try:
    root = ET.fromstring(xml_input)
except ET.ParseError as e:
    print(f'Error: Failed to parse UI XML: {e}', file=sys.stderr)
    sys.exit(1)

if safe_top > 0 or safe_bottom < 99999:
    print(f'[Safe zone: y={safe_top}..{safe_bottom} — elements marked SYSTEM_BAR overlap status/nav bar]')
    print()

idx = 0
for node in root.iter('node'):
    text = node.get('text', '')
    desc = node.get('content-desc', '')
    rid = node.get('resource-id', '')
    cls = node.get('class', '')
    bounds = node.get('bounds', '')
    clickable = node.get('clickable', 'false')
    focused = node.get('focused', 'false')
    enabled = node.get('enabled', 'true')
    checked = node.get('checked', 'false')
    checkable = node.get('checkable', 'false')
    hint = node.get('hint', '')

    # Include if: has text, content-desc, resource-id, hint, or is checkable
    if not text and not desc and not rid and not hint and checkable != 'true':
        continue

    # Parse bounds [left,top][right,bottom]
    m = re.match(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]', bounds)
    if not m:
        continue
    l, t, r, b = int(m.group(1)), int(m.group(2)), int(m.group(3)), int(m.group(4))
    w, h = r - l, b - t

    # Skip tiny or zero-size elements (off-screen, invisible, or decorative)
    if w < 8 or h < 8:
        continue

    idx += 1
    cx, cy = (l + r) // 2, (t + b) // 2

    # Extract short class name
    short_class = cls.split('.')[-1] if cls else 'Unknown'

    # Build display label (prefer text, then desc, then hint)
    label = text or desc or hint
    if label:
        # Truncate long text (e.g. episode descriptions) for readability
        if len(label) > 100:
            label = label[:100].rstrip() + '...'
        # Collapse internal newlines to spaces
        label = label.replace('\n', ' ')
        label = f'\"{ label }\"'
    else:
        label = '\"\"'

    # Build info parts
    parts = [f'[{idx}] {short_class} {label}']
    if rid:
        # Trim package prefix from resource-id for readability
        short_rid = rid.split(':id/')[-1] if ':id/' in rid else rid
        parts.append(f'id={short_rid}')
    parts.append(f'bounds={bounds}')
    parts.append(f'size={w}x{h}')
    parts.append(f'center=({cx},{cy})')

    # Flags (only show when noteworthy)
    flags = []
    if focused == 'true':
        flags.append('focused')
    if checked == 'true':
        flags.append('checked')
    if checkable == 'true':
        flags.append('checkable')
    if enabled == 'false':
        flags.append('disabled')
    if clickable == 'true':
        flags.append('clickable')
    if hint and not text:
        flags.append(f'hint=\"{hint}\"')

    # Warn if element overlaps system bars (risky tap target)
    if t < safe_top or b > safe_bottom:
        flags.append('SYSTEM_BAR')

    if flags:
        parts.append(' '.join(flags))

    print(' '.join(parts))

if idx == 0:
    print('(No interactive elements found)')
"

echo ""
echo "Raw XML saved to: $RAW_FILE"
