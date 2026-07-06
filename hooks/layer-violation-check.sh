#!/usr/bin/env bash
# PostToolUse check for Dart file edits: flags presentation -> data direct imports,
# a common Clean Architecture layer-rule violation.
set -euo pipefail

INPUT="$(cat)"
FILE_PATH="$(echo "$INPUT" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("tool_input",{}).get("file_path",""))' 2>/dev/null || true)"

if [[ -z "$FILE_PATH" || "$FILE_PATH" != *.dart || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

if [[ "$FILE_PATH" == *"/presentation/"* ]]; then
  if grep -qE "^\s*import\s+'.*\/data\/" "$FILE_PATH"; then
    echo "Warning: $FILE_PATH (presentation) directly imports a 'data/' module. In Clean Architecture, presentation should only depend on domain." >&2
    exit 2
  fi
fi

exit 0
