#!/bin/bash
# /go: commit spec, switch to IMPL_MODE
set -euo pipefail
CWD="$1"
cd "$CWD"

MODE_FILE="$CWD/.vibecontrol-mode"
if [ -f "$MODE_FILE" ] && [ "$(cat "$MODE_FILE" | tr -d '[:space:]')" = "IMPL_MODE" ]; then
  echo "Already in IMPL_MODE"
  exit 1
fi

# Commit any uncommitted spec changes
git add spec/ 2>/dev/null || true
if ! git diff --cached --quiet; then
  SUMMARY=$(git diff --cached --stat | head -1 | sed 's/^ *//')
  git commit -m "spec: $SUMMARY" --no-verify 2>/dev/null || true
fi

echo "IMPL_MODE" > "$MODE_FILE"
echo "Switched to IMPL_MODE"
