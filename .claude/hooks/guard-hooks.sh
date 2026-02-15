#!/bin/bash
# PreToolUse: block Claude from reading .claude/hooks/
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

[ -z "$FILE_PATH" ] && exit 0
[[ "$FILE_PATH" != /* ]] && FILE_PATH="$CWD/$FILE_PATH"

case "$FILE_PATH" in
  */.claude/hooks/*)
    echo "Cannot read hook scripts." >&2
    exit 2 ;;
esac

exit 0
