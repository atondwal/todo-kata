---
globs: "**/*"
---

# Path Restrictions

In SPEC_MODE: only write/edit files inside `spec/`.
In IMPL_MODE: never write/edit files inside `spec/`.
Reads are always allowed in both modes.

These are enforced by hooks, but follow them proactively.
