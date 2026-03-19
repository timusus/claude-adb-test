#!/bin/bash
# Shared UI dump helper with retry logic
# Source this from other scripts: source "$(dirname "${BASH_SOURCE[0]}")/_dump.sh"
#
# Provides:
#   do_dump <tmpfile>   — dump UI hierarchy with retry, write to tmpfile
#   escape_for_grep <text> — escape regex metacharacters for safe grep

MAX_RETRIES=10
RETRY_DELAY=0.5

# Dump UI hierarchy with retry logic for null root node errors
# Usage: do_dump <output_file>
# Returns: 0 on success, 1 on failure
do_dump() {
    local outfile="$1"
    local xml=""

    for i in $(seq 1 $MAX_RETRIES); do
        xml=$(adb exec-out uiautomator dump /dev/tty 2>/dev/null | tr -d '\r')
        # Strip uiautomator suffix using bash parameter expansion
        # (macOS sed silently fails on lines >32KB)
        xml="${xml%%UI hierarch*}"

        if [[ "$xml" == *"null root node"* ]]; then
            [ $i -lt $MAX_RETRIES ] && sleep "$RETRY_DELAY"
            continue
        fi

        if [[ "$xml" == *'<?xml'* ]]; then
            printf '%s' "$xml" > "$outfile"
            return 0
        fi

        [ $i -lt $MAX_RETRIES ] && sleep "$RETRY_DELAY"
    done

    echo "Error: Failed to dump UI hierarchy after $MAX_RETRIES attempts" >&2
    return 1
}

# Escape regex metacharacters in a string for safe use in grep -E
# Usage: escaped=$(escape_for_grep "C++ [Settings]")
escape_for_grep() {
    printf '%s' "$1" | sed 's/[][\\.^$*+?(){}|]/\\&/g'
}

# Convert a search string to its XML-entity-encoded form for matching raw XML
# Usage: encoded=$(encode_for_xml_match "Import & Export")
encode_for_xml_match() {
    printf '%s' "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&apos;/g'
}

# Decode XML entities in a string back to plain text
# Usage: decoded=$(decode_xml_entities "Import &amp; Export")
decode_xml_entities() {
    printf '%s' "$1" | sed 's/&amp;/\&/g; s/&lt;/</g; s/&gt;/>/g; s/&quot;/"/g; s/&apos;/'"'"'/g'
}
