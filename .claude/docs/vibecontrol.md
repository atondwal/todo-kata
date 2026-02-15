# VibeControl Internals

This document explains how VibeControl works under the hood. You don't need to read this during normal operation — the CLAUDE.md and hooks handle everything. This is here if you're curious or need to debug.

## State Machine

```
Session start → detect-mode.sh checks git state
  ├─ spec/ has uncommitted changes or last commit is spec: → IMPL_MODE
  └─ otherwise → preserve existing mode (default: SPEC_MODE)

SPEC_MODE:
  User chats → Claude writes to spec/ only
  /go → commit spec, flip to IMPL_MODE, implement

IMPL_MODE:
  Claude implements spec (can't touch spec/)
  User gives task prompts → prompt written to TASK.md, committed as "task: ..."
  Claude fixes/tweaks → auto-committed as "impl: ..."
  /og → commit impl, flip back to SPEC_MODE to work on spec
```

## Hooks

### SessionStart → `.claude/hooks/detect-mode.sh`
- Ensures `spec/` directory exists
- Detects if spec changed (uncommitted diff, untracked files, or last commit was `spec:`)
- Sets `.vibecontrol-mode` accordingly
- Injects context message for Claude

### PreToolUse → `.claude/hooks/enforce-paths.sh`
- Fires on Write, Edit, NotebookEdit
- In SPEC_MODE: blocks writes outside `spec/` (except `CLAUDE.md`)
- In IMPL_MODE: blocks writes inside `spec/`
- Reads are never blocked

### UserPromptSubmit → `.claude/hooks/task-commit.sh`
- Only fires in IMPL_MODE
- Writes user's prompt to TASK.md and commits as `task: <first line>`
- Skips slash commands and empty prompts

### Stop → `.claude/hooks/auto-commit.sh`
- Fires after Claude finishes a response
- SPEC_MODE: `git add spec/` → commit with `spec:` prefix
- IMPL_MODE: `git add -A` → `git reset HEAD -- spec/` → commit with `impl:` prefix
- Safety net: spec/ is always excluded from impl commits via `git reset`

## Skills

### /go
Commits the spec, flips mode to IMPL_MODE, reads the spec diff, and begins implementation.

### /og
Commits implementation, flips mode back to SPEC_MODE to work on the spec.

### /vc-status
Shows current mode, spec files, git status, and recent commits.

## Commit Convention

| Prefix | Meaning |
|--------|---------|
| `spec:` | Spec file changes |
| `impl:` | Implementation changes |
| `task:` | Task descriptions (TASK.md) |

## Files

| File | Purpose | Tracked |
|------|---------|---------|
| `spec/` | Specification documents | Yes |
| `.vibecontrol-mode` | Current mode state | No (gitignored) |
| `TASK.md` | Current task prompt | Yes (committed as `task:`) |
