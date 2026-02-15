#!/bin/bash
# /og: commit impl, switch to SPEC_MODE
set -euo pipefail
CWD="$1"
cd "$CWD"

MODE_FILE="$CWD/.vibecontrol-mode"
if [ -f "$MODE_FILE" ] && [ "$(cat "$MODE_FILE" | tr -d '[:space:]')" = "SPEC_MODE" ]; then
  echo "Already in SPEC_MODE"
  exit 1
fi

# Commit any uncommitted impl changes (excluding spec/)
git add -A 2>/dev/null || true
git reset HEAD -- spec/ 2>/dev/null || true
if ! git diff --cached --quiet; then
  MSG=$(bash .claude/hooks/summarize-diff.sh impl)
  git commit -m "$MSG" --no-verify 2>/dev/null || true
fi

echo "SPEC_MODE" > "$MODE_FILE"
echo "Switched to SPEC_MODE"
