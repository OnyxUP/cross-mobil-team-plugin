#!/usr/bin/env bash
# PreToolUse guard for Read: warns when a file is large enough that reading
# it whole would waste context, nudging the agent toward offset/limit.
set -euo pipefail

INPUT="$(cat)"
FILE_PATH="$(echo "$INPUT" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("tool_input",{}).get("file_path",""))' 2>/dev/null || true)"

if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

LINE_COUNT=$(wc -l < "$FILE_PATH" 2>/dev/null || echo 0)

LIMIT_SET="$(echo "$INPUT" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(bool(d.get("tool_input",{}).get("limit")))' 2>/dev/null || echo "False")"

if [[ "$LINE_COUNT" -gt 500 && "$LIMIT_SET" == "False" ]]; then
  echo "This file has $LINE_COUNT lines. Instead of loading it all into context, read it in chunks with offset/limit or search it targeted with Grep." >&2
  exit 2
fi

exit 0
