This repo uses VibeControl for spec-driven development.

## How it works

There are two modes, controlled by `.vibecontrol-mode`:

- **SPEC_MODE** (default): Help design specs in `spec/`. Don't write implementation code.
- **IMPL_MODE**: Implement the spec. Don't touch `spec/`.

Hooks enforce this automatically — you don't need to worry about it, just follow the mode.

Commits are auto-generated with `spec:` / `impl:` / `task:` prefixes.

Use `/go` when the spec is ready. Use `/og` to go back and work on the spec. Use `/vc-status` to check where things stand.

## To get you started

- A human-written specification of the project lives in spec/. spec/ is NOT edited by agents
- The spec MUST be followed, if specifications in spec/ have mistakes or require something impossible, surface this to a human
- notes/ contains Agent-written documentation, plans, thoughts and other long-lived writing to aid in the coding process
- Add or edit notes/ files to track major architectural decisions, record solutions to problems repeatedly encountered, etc
- Notes should be USEFUL and CONCISE markdown files with kebab-case.md names, don't put info in notes that is obvious from the code
- Notes should link to each other with standard Markdown formatting [foo-doc](/notes/foo-doc.md) where appropriate, notes can also link to spec files
- Markdown links to notes/spec should also appear in doc comments for relevant functions/traits/etc
- Always read relevant notes before editing code, but remember notes may have mistakes or bad ideas. they have not been human-reviewed
- Delete notes that are no longer relevant, or simply have little value
- Do not let notes and note links fall out of date, update/remove references in both code and other notes when deleting/renaming them
- It's encouraged to add and update notes at any time you come across outdated information, even when working on something unrelated
- If there is a committed TASK.md, it contains your current task to accomplish
- TASK.md should be deleted when completed, but otherwise not edited
- Unless explicitly asked, ignore uncommitted changes to doctrine/ and TASK.md
- Agents should NOT commit or otherwise change the git state
- TDD should generally be used, write a failing test before attempting to add a feature

## About this file

This is the starter CLAUDE.md. Once the project has real code, rewrite this file to describe the actual project — architecture, conventions, key files, whatever helps you work effectively. Keep the VibeControl paragraph above (or just a one-liner noting the repo uses VibeControl) so future sessions know the workflow.

Details on how VibeControl works are in `.claude/docs/vibecontrol.md` if you need them.
