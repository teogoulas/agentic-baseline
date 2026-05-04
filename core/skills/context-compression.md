# Context Compression

Use this skill when a conversation or task context is growing large and needs to be summarized
without losing information critical for continuing the work.

---

## When to Apply

- Context window is approaching capacity
- Handing off work between agents or sessions
- Generating a snapshot for the monthly baseline update
- Creating a status report mid-task

---

## What to Preserve

Always keep in the compressed context:
1. **Current state** — what has been done, what is the current state of the work
2. **Active decisions** — decisions made that affect future steps
3. **Open items** — what is still to be done, in order
4. **Blockers and escalations** — any unresolved escalations or blockers
5. **Key file paths** — what files have been created or modified
6. **Assumptions** — anything assumed that should be validated

---

## What to Drop

- Full file contents that can be re-read from disk
- Intermediate reasoning that led to a decision (keep the decision, drop the debate)
- Repeated information
- Tool call outputs that are now reflected in the current state

---

## Compression Format

```markdown
## Context Snapshot — [YYYY-MM-DD HH:MM]

### Task
[One sentence: what the overall task is]

### Current State
[Bullet list: what has been completed]

### Active Decisions
- [Decision made and why — 1 line each]

### Open Items
1. [Next step]
2. [Step after that]
...

### Blockers / Escalations
- [Any unresolved items requiring user input]

### Key Files
- [path/to/file] — [what it is]

### Assumptions
- [Anything assumed that hasn't been confirmed]
```

---

## Handoff Protocol

When handing off between agents or sessions:
1. Generate the snapshot above
2. Save it to `context-snapshot.md` in the project root or working directory
3. The receiving agent reads this file first before any other action
4. Delete the snapshot once the task is complete — it is ephemeral
