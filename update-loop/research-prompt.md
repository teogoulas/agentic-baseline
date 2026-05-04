# Monthly Baseline Research Prompt

Run this once a month with web search enabled, or immediately after a major model or tool release.
The agent scans the AI engineering landscape and proposes changes to the baseline.

---

## Prompt (paste this to your agent with web search enabled)

```
You are updating an agentic engineering baseline repository. Today's date is [INSERT DATE].
The last update was [INSERT DATE FROM update-log.md].

Scan the following areas and identify anything that should change in this baseline:

1. **Models** — Are there new models from Anthropic, OpenAI, Google, or Mistral that should
   update default model recommendations? Are any models being deprecated?

2. **Agentic tools** — New coding agents, multi-agent frameworks, or developer infrastructure
   worth adding as an adapter or registering in tool-registry.md?

3. **Architectural patterns** — New multi-agent patterns, orchestration approaches, or
   prompt engineering techniques that should update core skill files?

4. **Security** — New vulnerabilities in tools the user uses? New CVEs in common dependencies?
   New security tooling worth adding to the security-auditor workflow?

5. **Deprecations** — Any patterns, tools, or approaches in this baseline that are now
   outdated or superseded?

6. **MCP ecosystem** — Run the mcp-review.md prompt separately and include its output here.

Sources to check:
- Anthropic, OpenAI, Google DeepMind, Mistral official blogs and changelogs
- Simon Willison's blog (simonwillison.net)
- Hacker News AI threads from the past 30 days
- ArXiv cs.AI recent papers (agent, multi-agent, security keywords)
- MCP server registry and community repos
- GitHub trending repositories (AI/agent/LLM category)

Output the following JSON — propose only changes that are well-evidenced and directly relevant:

{
  "scan_date": "YYYY-MM-DD",
  "scan_window_days": 30,
  "findings": [
    {
      "category": "models|tools|architecture|security|deprecation|mcp",
      "action": "ADD|UPDATE|REMOVE|MONITOR",
      "title": "short title",
      "summary": "2-3 sentence summary of what changed and why it matters",
      "impact_on_baseline": "which file(s) should change and exactly how",
      "priority": "high|medium|low",
      "sources": ["url1", "url2"]
    }
  ],
  "proposed_diffs": [
    {
      "file": "core/skills/example.md",
      "change_type": "append|replace_section|new_file|delete_file",
      "content": "the actual content to add or replace"
    }
  ]
}
```

---

## After Getting the Output

1. Review findings — reject anything speculative or not directly relevant
2. For each approved proposed_diff: apply the change
3. Commit as: `chore: monthly baseline update YYYY-MM-DD`
4. Append to `update-loop/update-log.md`
