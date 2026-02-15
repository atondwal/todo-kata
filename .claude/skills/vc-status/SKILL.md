---
name: vc-status
description: Show current VibeControl mode and project status
disable-model-invocation: true
allowed-tools: Read, Bash, Glob
---

# /vc-status — Show VibeControl Status

Gather and display:

1. **Current mode**: Read `.vibecontrol-mode` (default SPEC_MODE if missing)
2. **Spec files**: List files in `spec/`
3. **Git status**: `git status --short`
4. **Recent commits**: `git log --oneline -10`
5. **Uncommitted spec changes**: `git diff -- spec/`

Format clearly with headers.
