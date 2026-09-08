#!/usr/bin/env bash
# PostToolUse check for Dart file edits: heuristic guards for UI/widget discipline —
# flags presentation pages that grew too long (extract widgets) and likely business
# logic living inside widget callbacks. Heuristic only, not a linter; the final call
# belongs to flutter-developer / mobile-lead. See rules.md and the
# solid-separation-of-concerns skill.
set -euo pipefail

INPUT="$(cat)"
FILE_PATH="$(echo "$INPUT" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("tool_input",{}).get("file_path",""))' 2>/dev/null || true)"

if [[ -z "$FILE_PATH" || "$FILE_PATH" != *.dart || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Only inspect presentation-layer UI files.
if [[ "$FILE_PATH" != *"/presentation/"* ]]; then
  exit 0
fi

WARNINGS=()

# 1) Page length: pages should read as composition — extract sub-widgets when long.
if [[ "$FILE_PATH" == *"/presentation/pages/"* ]]; then
  LINE_COUNT="$(wc -l < "$FILE_PATH" | tr -d ' ')"
  if [[ "$LINE_COUNT" -gt 250 ]]; then
    WARNINGS+=("$FILE_PATH is $LINE_COUNT lines. Pages should stay short — extract sub-widgets into presentation/widgets/ (own classes, not _buildX() methods).")
  fi
fi

# 2) Business logic inside widget callbacks: an on...: (...) { ... } callback whose
#    body contains control flow or awaits is a likely SRP/UI-logic violation.
#    Heuristic: a callback opener followed within a few lines by if/for/while/await/try.
if grep -nEA4 "on[A-Z][A-Za-z]*:\s*\(" "$FILE_PATH" 2>/dev/null \
     | grep -qE "^\s*[0-9]+[:-]\s*(if\s*\(|for\s*\(|while\s*\(|await\s|try\s*\{|switch\s*\()"; then
  WARNINGS+=("$FILE_PATH: a widget callback appears to contain business logic (branching/await). Callbacks should only call a single Cubit/BLoC method — move logic into the Cubit/BLoC or a use-case.")
fi

if [[ ${#WARNINGS[@]} -gt 0 ]]; then
  printf 'Warning: %s\n' "${WARNINGS[@]}" >&2
  exit 2
fi

exit 0
