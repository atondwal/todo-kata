#!/bin/bash
# Stop: auto-commit changes after Claude finishes responding
set -euo pipefail

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
cd "$CWD"

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  exit 0
fi

# Nothing to commit
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  exit 0
fi

MODE_FILE="$CWD/.vibecontrol-mode"
if [ -f "$MODE_FILE" ]; then
  MODE=$(cat "$MODE_FILE" | tr -d '[:space:]')
else
  MODE="SPEC_MODE"
fi

if [ "$MODE" = "SPEC_MODE" ]; then
  git add spec/ 2>/dev/null || true
  if ! git diff --cached --quiet; then
    MSG=$(bash .claude/hooks/summarize-diff.sh spec)
    git commit -m "$MSG" --no-verify 2>/dev/null || true
  fi
elif [ "$MODE" = "IMPL_MODE" ]; then
  git add -A 2>/dev/null || true
  git reset HEAD -- spec/ 2>/dev/null || true
  if ! git diff --cached --quiet; then
    MSG=$(bash .claude/hooks/summarize-diff.sh impl)
    git commit -m "$MSG" --no-verify 2>/dev/null || true
  fi
fi

exit 0
