#!/usr/bin/env bash
# Stop hook: lightweight, best-effort session cost-awareness log.
# Appends a timestamp line; does not attempt exact token accounting.
set -euo pipefail

LOG_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/logs"
mkdir -p "$LOG_DIR"
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) session stopped" >> "$LOG_DIR/session-cost.log"

exit 0
