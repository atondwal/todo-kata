#!/bin/bash
# SessionStart: detect mode based on git state
set -euo pipefail

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
cd "$CWD"

mkdir -p "$CWD/spec"

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  git init
  git add -A
  git commit -m "init: vibecontrol project" --allow-empty --no-verify 2>/dev/null || true
fi

SPEC_CHANGED="false"

# Uncommitted spec changes
if ! git diff --quiet -- spec/ 2>/dev/null || ! git diff --cached --quiet -- spec/ 2>/dev/null; then
  SPEC_CHANGED="true"
fi

# New untracked files in spec/
if [ -n "$(git ls-files --others --exclude-standard -- spec/ 2>/dev/null)" ]; then
  SPEC_CHANGED="true"
fi

# Last commit was a spec commit with no working changes
LAST_MSG=$(git log -1 --format=%s 2>/dev/null || echo "")
if [[ "$LAST_MSG" == spec:* ]] && git diff --quiet 2>/dev/null; then
  SPEC_CHANGED="true"
fi

MODE_FILE="$CWD/.vibecontrol-mode"

if [ "$SPEC_CHANGED" = "true" ]; then
  echo "IMPL_MODE" > "$MODE_FILE"
  CONTEXT="Spec changes detected. Entering IMPL_MODE. Read the spec and implement it."
else
  if [ -f "$MODE_FILE" ]; then
    MODE=$(cat "$MODE_FILE" | tr -d '[:space:]')
  else
    echo "SPEC_MODE" > "$MODE_FILE"
    MODE="SPEC_MODE"
  fi
  CONTEXT="Current mode: ${MODE:-SPEC_MODE}. In SPEC_MODE, help design specs in spec/. Use /go when ready to implement."
fi

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "$CONTEXT"
  }
}
EOF
