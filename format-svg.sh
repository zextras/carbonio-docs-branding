#!/usr/bin/env bash
#
# Format all SVG files in dist/images/ using xmlstarlet.
# Uses 2-space indentation and omits the XML declaration.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SVG_DIR="${SCRIPT_DIR}/dist/images"

if ! command -v xmlstarlet &>/dev/null; then
  echo "error: xmlstarlet is not installed" >&2
  exit 1
fi

if [[ ! -d "$SVG_DIR" ]]; then
  echo "error: directory not found: ${SVG_DIR}" >&2
  exit 1
fi

count=0
errors=0

for svg in "${SVG_DIR}"/*.svg; do
  [[ -f "$svg" ]] || continue

  tmp="${svg}.tmp"

  # xmlstarlet fo returns non-zero exit codes even on success,
  # so we validate the output instead of trusting the exit code.
  xmlstarlet fo -s 2 -o "$svg" > "$tmp" 2>/dev/null || true

  if [[ -s "$tmp" ]] && xmlstarlet val "$tmp" &>/dev/null; then
    mv "$tmp" "$svg"
    count=$((count + 1))
  else
    echo "error: failed to format $(basename "$svg")" >&2
    rm -f "$tmp"
    errors=$((errors + 1))
  fi
done

echo "formatted ${count} SVG files (${errors} errors)"
