#!/usr/bin/env bash
# PostToolUse filter for long Bash output (flutter test / analyze / pub get):
# keeps the full log on disk, feeds back only the actionable lines.
set -euo pipefail

INPUT="$(cat)"
OUTPUT="$(echo "$INPUT" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("tool_response",{}).get("stdout","") + d.get("tool_response",{}).get("stderr",""))' 2>/dev/null || true)"

LINE_COUNT=$(echo "$OUTPUT" | wc -l)

if [[ "$LINE_COUNT" -le 80 ]]; then
  exit 0
fi

LOG_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/bash-output-$(date +%s).log"
echo "$OUTPUT" > "$LOG_FILE"

SUMMARY="$(echo "$OUTPUT" | grep -iE 'error|fail|exception|warning' || true)"

if [[ -z "$SUMMARY" ]]; then
  echo "Long command output ($LINE_COUNT lines) written to $LOG_FILE; no error/warning lines found, likely successful." >&2
else
  {
    echo "Long command output ($LINE_COUNT lines) summarized, full log: $LOG_FILE"
    echo "$SUMMARY"
  } >&2
fi

exit 2
