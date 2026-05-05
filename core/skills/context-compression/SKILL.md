---
name: context-compression
description: Compresses a growing conversation or task context into a structured snapshot without losing information critical for continuing the work. Use when the context window is approaching capacity, handing off work between agents or sessions, or generating a mid-task status report. Don't use for summarising completed work for documentation (use the docs agent), or for producing user-facing reports (use the report agent).
---

# Context Compression

## When to Apply

- Context window is approaching capacity
- Handing off work between agents or sessions
- Generating a snapshot for the monthly baseline update
- Creating a status report mid-task

## Step 1: Identify What to Preserve

Always retain:
1. **Current state** — what has been done, what is the current state of the work
2. **Active decisions** — decisions made that affect future steps
3. **Open items** — what is still to be done, in order
4. **Blockers and escalations** — any unresolved escalations or blockers
5. **Key file paths** — files created or modified
6. **Assumptions** — anything assumed that should be validated

Always drop:
- Full file contents that can be re-read from disk
- Intermediate reasoning that led to a decision (keep the decision, drop the debate)
- Repeated information
- Tool call outputs already reflected in current state

## Step 2: Generate the Snapshot

Read `assets/context-snapshot.template.md` and fill in every section.
Do not leave any section empty — write "none" if there is nothing to record.

## Step 3: Save and Hand Off

1. Save the snapshot to `context-snapshot.md` in the project root or working directory.
2. The receiving agent reads this file first before any other action.
3. Delete the snapshot once the task is complete — it is ephemeral.

## Error Handling

- If a decision's rationale is unclear from the context, record the decision and flag it as "rationale unknown — verify before proceeding."
- If open items are ambiguous, escalate before compressing — a compressed context with wrong open items is worse than a full one.
