#!/bin/bash
# UserPromptSubmit: in IMPL_MODE, write user prompt to TASK.md and commit it
set -euo pipefail

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

cd "$CWD"

# Only in IMPL_MODE
MODE_FILE="$CWD/.vibecontrol-mode"
if [ ! -f "$MODE_FILE" ]; then
  exit 0
fi
MODE=$(cat "$MODE_FILE" | tr -d '[:space:]')
if [ "$MODE" != "IMPL_MODE" ]; then
  exit 0
fi

# Skip slash commands — /go and /vc-status have their own flows
case "$PROMPT" in
  /*) exit 0 ;;
esac

# Skip empty prompts
[ -z "$PROMPT" ] && exit 0

# Write prompt to TASK.md and commit
echo "$PROMPT" > "$CWD/TASK.md"
git add TASK.md 2>/dev/null || true

# Use first line (truncated) as commit summary
SUMMARY=$(echo "$PROMPT" | head -1 | cut -c1-72)
git commit -m "task: $SUMMARY" --no-verify 2>/dev/null || true

exit 0
