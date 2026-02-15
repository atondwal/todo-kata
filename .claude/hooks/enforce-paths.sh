#!/bin/bash
# PreToolUse: enforce path restrictions based on current mode
set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

case "$TOOL_NAME" in
  Write|Edit|NotebookEdit) ;;
  *) exit 0 ;;
esac

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty')
[ -z "$FILE_PATH" ] && exit 0

[[ "$FILE_PATH" != /* ]] && FILE_PATH="$CWD/$FILE_PATH"

MODE_FILE="$CWD/.vibecontrol-mode"
if [ -f "$MODE_FILE" ]; then
  MODE=$(cat "$MODE_FILE" | tr -d '[:space:]')
else
  MODE="SPEC_MODE"
fi

SPEC_DIR="$CWD/spec"
IS_SPEC="false"
case "$FILE_PATH" in
  "$SPEC_DIR"/*|"$SPEC_DIR") IS_SPEC="true" ;;
esac

if [ "$MODE" = "SPEC_MODE" ] && [ "$IS_SPEC" = "false" ]; then
  case "$FILE_PATH" in
    */CLAUDE.md) exit 0 ;;
  esac
  echo "SPEC_MODE: Cannot write outside spec/. Use /go to switch to IMPL_MODE." >&2
  exit 2
fi

if [ "$MODE" = "IMPL_MODE" ] && [ "$IS_SPEC" = "true" ]; then
  echo "IMPL_MODE: Cannot modify spec/. The spec is frozen during implementation." >&2
  exit 2
fi

exit 0
