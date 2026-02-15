#!/bin/bash
# Generate a meaningful one-line commit message from the staged diff.
# Uses claude -p with haiku from /tmp to avoid project context.
# Falls back to stat summary on failure.
set -euo pipefail

PREFIX="${1:-impl}"

DIFF=$(git diff --cached 2>/dev/null)
if [ -z "$DIFF" ]; then
  echo "$PREFIX: no changes"
  exit 0
fi

# Truncate diff to ~8k chars to stay within limits
DIFF_TRUNCATED=$(echo "$DIFF" | head -c 8000)

# Try claude -p from /tmp to avoid project hooks/CLAUDE.md
SUMMARY=$(
  cd /tmp
  unset CLAUDECODE
  echo "$DIFF_TRUNCATED" | claude -p \
    "Write a concise git commit message (one line, no prefix, max 60 chars) summarizing this diff. Output ONLY the message, nothing else." \
    --model haiku 2>/dev/null | head -1 | cut -c1-60
) || true

# Fallback to stat summary
if [ -z "${SUMMARY:-}" ]; then
  SUMMARY=$(git diff --cached --stat | head -1 | sed 's/^ *//')
fi

echo "$PREFIX: $SUMMARY"
