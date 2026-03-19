#!/usr/bin/env python3
"""Shared XML query helper for ADB UI dump files.

Properly parses uiautomator XML and finds elements by text, resource-id,
or content-desc — handling XML entities, partial matching, and special
characters that break grep-based approaches.

Usage:
    python3 _xml_query.py <xml_file> <mode> <query>

Modes:
    text-exact <query>       Exact text match
    text <query>             Partial/substring text match
    resource-id <query>      Exact or suffix resource-id match
    content-desc <query>     Partial content-desc match
    any <query>              Try all strategies (id suffix → text → desc)

Output (one line per match, tab-separated):
    bounds<TAB>text<TAB>content-desc<TAB>resource-id<TAB>class<TAB>clickable<TAB>enabled<TAB>checked<TAB>focused
"""
import sys
import re
import xml.etree.ElementTree as ET


def parse_xml(filepath):
    """Parse UI dump XML, stripping uiautomator suffix if present."""
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    # Strip trailing uiautomator message
    end_tag = "</hierarchy>"
    idx = content.rfind(end_tag)
    if idx >= 0:
        content = content[: idx + len(end_tag)]

    return ET.fromstring(content)


def get_attrs(node):
    """Extract a dict of useful attributes from a node."""
    return {
        "bounds": node.get("bounds", ""),
        "text": node.get("text", ""),
        "content-desc": node.get("content-desc", ""),
        "resource-id": node.get("resource-id", ""),
        "hint": node.get("hint", ""),
        "class": node.get("class", ""),
        "clickable": node.get("clickable", "false"),
        "enabled": node.get("enabled", "true"),
        "checked": node.get("checked", "false"),
        "checkable": node.get("checkable", "false"),
        "focused": node.get("focused", "false"),
    }


def format_result(attrs):
    """Format attrs as a tab-separated line."""
    fields = [
        "bounds",
        "text",
        "content-desc",
        "resource-id",
        "hint",
        "class",
        "clickable",
        "enabled",
        "checked",
        "checkable",
        "focused",
    ]
    return "\t".join(attrs.get(f, "") for f in fields)


def parse_bounds(bounds_str):
    """Parse bounds string to (left, top, right, bottom) or None."""
    m = re.match(r"\[(\d+),(\d+)\]\[(\d+),(\d+)\]", bounds_str)
    if m:
        return tuple(int(m.group(i)) for i in range(1, 5))
    return None


def center_of(bounds_str):
    """Calculate center (x, y) from bounds string."""
    b = parse_bounds(bounds_str)
    if b:
        return (b[0] + b[2]) // 2, (b[1] + b[3]) // 2
    return None


def find_by_text_exact(root, query):
    """Find nodes where text equals query exactly."""
    results = []
    for node in root.iter("node"):
        if node.get("text", "") == query:
            results.append(get_attrs(node))
    return results


def find_by_text_partial(root, query):
    """Find nodes where text contains query (case-insensitive)."""
    query_lower = query.lower()
    results = []
    for node in root.iter("node"):
        text = node.get("text", "")
        if text and query_lower in text.lower():
            results.append(get_attrs(node))
    return results


def find_by_resource_id(root, query):
    """Find nodes by exact resource-id or :id/ suffix match."""
    results = []
    for node in root.iter("node"):
        rid = node.get("resource-id", "")
        if rid == query or rid.endswith(":id/" + query):
            results.append(get_attrs(node))
    return results


def find_by_content_desc(root, query):
    """Find nodes where content-desc contains query."""
    query_lower = query.lower()
    results = []
    for node in root.iter("node"):
        desc = node.get("content-desc", "")
        if desc and query_lower in desc.lower():
            results.append(get_attrs(node))
    return results


def find_by_hint(root, query):
    """Find nodes where hint contains query (case-insensitive)."""
    query_lower = query.lower()
    results = []
    for node in root.iter("node"):
        hint = node.get("hint", "")
        if hint and query_lower in hint.lower():
            results.append(get_attrs(node))
    return results


def find_any(root, query):
    """Try resource-id suffix, then text partial, then content-desc, then hint."""
    results = find_by_resource_id(root, query)
    if results:
        return results
    results = find_by_text_partial(root, query)
    if results:
        return results
    results = find_by_content_desc(root, query)
    if results:
        return results
    return find_by_hint(root, query)


def main():
    if len(sys.argv) < 4:
        print(
            "Usage: _xml_query.py <xml_file> <mode> <query>", file=sys.stderr
        )
        sys.exit(2)

    xml_file, mode, query = sys.argv[1], sys.argv[2], sys.argv[3]

    try:
        root = parse_xml(xml_file)
    except (ET.ParseError, FileNotFoundError) as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    dispatch = {
        "text-exact": find_by_text_exact,
        "text": find_by_text_partial,
        "resource-id": find_by_resource_id,
        "content-desc": find_by_content_desc,
        "hint": find_by_hint,
        "any": find_any,
    }

    fn = dispatch.get(mode)
    if not fn:
        print(f"Unknown mode: {mode}", file=sys.stderr)
        sys.exit(2)

    results = fn(root, query)
    for attrs in results:
        print(format_result(attrs))

    sys.exit(0 if results else 1)


if __name__ == "__main__":
    main()
