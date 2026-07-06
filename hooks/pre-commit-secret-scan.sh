#!/usr/bin/env bash
# PostToolUse hook triggered on `git commit`: quick pattern scan of the staged
# diff for hardcoded secrets and debug leftovers before the commit lands.
set -euo pipefail

cd "${CLAUDE_PROJECT_DIR:-.}"

DIFF="$(git diff --cached 2>/dev/null || true)"

if [[ -z "$DIFF" ]]; then
  exit 0
fi

PATTERN='sk-[A-Za-z0-9]{10,}|AIza[0-9A-Za-z_-]{20,}|Bearer [A-Za-z0-9._-]{10,}|api[_-]?key\s*[:=]\s*["'\''][A-Za-z0-9]{10,}|print\('
MATCHES="$(echo "$DIFF" | grep -inE "$PATTERN" || true)"

if [[ -n "$MATCHES" ]]; then
  {
    echo "Pre-commit security scan found potential issues (suspected secret/debug log):"
    echo "$MATCHES" | head -20
    echo "Verify with security-engineer before committing, or ignore if it's a false positive."
  } >&2
  exit 2
fi

exit 0
