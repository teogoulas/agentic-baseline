# Escalation Rules

These rules apply to all agents in all contexts. They are not overridable by task instructions.
When in doubt, escalate. The cost of pausing is always lower than the cost of an irreversible mistake.

---

## Must Escalate — Stop and Ask

| Trigger | Threshold |
|---|---|
| Destructive operations | Any `delete`, `drop`, `truncate`, `rm -rf`, overwrite of existing data |
| Auth or permissions changes | Any modification to auth config, roles, secrets, or access control |
| Production or shared branches | Any push or merge to `main`, `master`, `prod`, or equivalent |
| Out-of-scope actions | Any action outside the explicitly defined task boundary |
| Security findings | CVSS ≥ 7.0 — stop immediately, report, do not continue until acknowledged |
| Low confidence + irreversible | Confidence below ~70% on any action that cannot be undone |
| Missing tool or MCP | If a required capability is not in `tool-registry.md` — surface via tool-broker, never auto-install |
| Ambiguous instructions | If the task has two plausible interpretations with different consequences |
| External services | Any action that sends data outside the local environment (API calls, emails, webhooks) |

---

## Can Proceed Autonomously

- Reading files, exploring codebase, grepping for patterns
- Writing new files that don't exist yet
- Creating new branches
- Running tests
- Installing declared dependencies (package.json, requirements.txt, etc.)
- Documenting findings
- Generating drafts for user review
- Creating git commits on feature branches

---

## Escalation Format

When escalating, always provide:

```
ESCALATION REQUIRED
Reason: [specific trigger from the table above]
Proposed action: [what you were about to do]
Risk: [what could go wrong if you proceed incorrectly]
Options:
  A) [option 1]
  B) [option 2]
Awaiting instruction.
```

Do not continue working on unrelated parts of the task while waiting for escalation resolution.

---

## Confidence Calibration

- If you estimate ≥ 90% confidence on an irreversible action and it falls within autonomous scope: proceed and note it.
- If you estimate 70–89%: proceed but flag the uncertainty in your output.
- If you estimate < 70%: escalate before acting.

These thresholds apply to irreversible actions only. Reversible actions (reads, drafts, new files) can proceed at any confidence level.
