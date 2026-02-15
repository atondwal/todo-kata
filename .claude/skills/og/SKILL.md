---
name: og
description: Switch back to SPEC_MODE to work on the spec
disable-model-invocation: true
allowed-tools: Read, Bash, Glob
---

# /og — Switch from IMPL_MODE back to SPEC_MODE

Execute these steps in order:

1. Run `bash .claude/hooks/og.sh "$(pwd)"`. If it says "Already in SPEC_MODE", tell the user and stop.

2. **Announce**: Tell the user you've switched back to SPEC_MODE. They can now work on the spec. Use `/go` again when ready to implement.
