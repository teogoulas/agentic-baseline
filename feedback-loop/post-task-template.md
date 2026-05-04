# Post-Task Feedback Template

Run this after any significant task. Paste it into your agent with the task context still loaded.
Output is structured JSON for easy processing and logging.

---

## Prompt (paste this to your agent)

```
You just completed a task. Before we close out, I need structured feedback to improve the baseline.
Answer the following questions based on what actually happened — not what should have happened.
Be specific. Output as JSON using the schema below.

Questions:
1. What did I have to explain more than once during this task?
2. What output format needed fixing after you produced it?
3. What did you escalate that, in hindsight, you could have handled autonomously?
4. What did you handle autonomously that, in hindsight, should have been escalated?
5. What tool or capability was missing that would have improved this task?
6. Was any MCP or tool absent that should be added to tool-registry.md?
7. What specific changes would improve a skill file? (name the file and the proposed change)
8. What should be updated in personal.md or permissions-default.md?

Output schema:
{
  "task_date": "YYYY-MM-DD",
  "task_summary": "one sentence",
  "repeated_explanations": ["string"],
  "format_fixes_needed": ["string"],
  "over_escalated": ["string"],
  "under_escalated": ["string"],
  "missing_tools": [
    { "capability": "string", "suggested_tool": "string or null" }
  ],
  "missing_mcps": [
    { "capability": "string", "suggested_mcp": "string or null" }
  ],
  "skill_updates": [
    { "file": "core/skills/example.md", "change": "string" }
  ],
  "context_updates": [
    { "file": "core/context/example.md", "change": "string" }
  ]
}
```

---

## After Getting the Output

1. Review the JSON for anything surprising
2. For any `skill_updates` or `context_updates`: apply them now or log them in `feedback-loop/improvement-log.md`
3. For any `missing_tools` or `missing_mcps`: route to tool-broker for a Discover proposal
4. For `over_escalated` or `under_escalated`: update `core/skills/escalation-rules.md` accordingly
