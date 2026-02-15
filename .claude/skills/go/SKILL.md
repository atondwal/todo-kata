---
name: go
description: Commit the spec and switch to IMPL_MODE to begin implementation
disable-model-invocation: true
allowed-tools: Read, Bash, Glob, Grep, Write, Edit
---

# /go — Switch from SPEC_MODE to IMPL_MODE

Execute these steps in order:

1. Run `bash .claude/hooks/go.sh "$(pwd)"`. If it says "Already in IMPL_MODE", tell the user and stop.

2. **Read the spec**: Read all files in `spec/` to understand what to implement.

3. **Get the spec diff**: Run `git diff HEAD~1 -- spec/` to see what changed.

4. **Announce**: Tell the user you've switched to IMPL_MODE and what you're about to implement.

5. **Implement**: Begin implementing the spec. Do not touch `spec/`.
