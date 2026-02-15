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
  # Commit any uncommitted spec changes before switching to IMPL_MODE
  git add spec/ 2>/dev/null || true
  if ! git diff --cached --quiet 2>/dev/null; then
    MSG=$(bash .claude/hooks/summarize-diff.sh spec)
    git commit -m "$MSG" --no-verify 2>/dev/null || true
  fi
  echo "IMPL_MODE" > "$MODE_FILE"
  CONTEXT="Spec changes detected and committed. You are in IMPL_MODE. Read all files in spec/, read any relevant notes/, then start implementing. Use TDD — write failing tests first."
elif [ -f "$MODE_FILE" ] && [ "$(cat "$MODE_FILE" | tr -d '[:space:]')" = "IMPL_MODE" ]; then
  # Already in IMPL_MODE from a previous session — check if work is done
  LAST_MSG=$(git log -1 --format=%s 2>/dev/null || echo "")

  if [[ "$LAST_MSG" == task:* ]] && [ -f "$CWD/TASK.md" ]; then
    # Last commit was a task commit — unfinished work, continue
    TASK=$(cat "$CWD/TASK.md")
    CONTEXT="You are in IMPL_MODE. There is an unfinished task: $TASK — Read the spec and relevant notes, then implement it."
  else
    # Last commit was impl: or anything else — work is done, back to spec
    echo "SPEC_MODE" > "$MODE_FILE"
    CONTEXT="Previous implementation work is complete. You are in SPEC_MODE. Help design specs in spec/. Use /go when ready to implement."
  fi
else
  if [ -f "$MODE_FILE" ]; then
    MODE=$(cat "$MODE_FILE" | tr -d '[:space:]')
  else
    echo "SPEC_MODE" > "$MODE_FILE"
    MODE="SPEC_MODE"
  fi
  CONTEXT="You are in SPEC_MODE. Help design specs in spec/. Use /go when ready to implement."
fi

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "$CONTEXT"
  }
}
EOF
