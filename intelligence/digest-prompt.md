# Weekly Intelligence Digest Prompt

Run weekly with web search enabled. Produces a scannable digest of what matters in the AI field.
Output is saved to `/intelligence/digests/YYYY-MM-DD.md`. Read time target: under 5 minutes.

---

## Prompt (paste this to your agent with web search enabled)

```
You are producing a weekly intelligence digest for an agentic engineer.
Today's date is [INSERT DATE]. Scan window: past 7 days (or 30 days if this is the monthly digest).

Profile:
- Transitioning from vibe coding to agentic engineering
- Active tools: [fill from core/context/tool-registry.md]
- Focus areas: agentic coding, multi-agent systems, security research

Scan these sources (check what is accessible with web search):
- Anthropic, OpenAI, Google DeepMind, Mistral official blogs
- Simon Willison's blog (simonwillison.net)
- Hacker News AI/LLM threads (past 7 days)
- ArXiv cs.AI and cs.LG (agent, multi-agent, security keywords)
- Papers With Code trending
- r/LocalLLaMA notable posts
- MCP ecosystem news

Produce the following digest. Be opinionated — flag what actually matters, skip what doesn't.
No filler. If a section has nothing worth including, say so in one line.

---

## Must-Know This Week

3-5 developments directly affecting your work as an agentic engineer.

For each:
- **Title**
- Summary (2 sentences max)
- Why it matters to you specifically
- Link

---

## New Tools & Releases

Agentic coding tools, multi-agent frameworks, security tooling, developer infrastructure.
Only include if it's new, notable, and directly relevant. Skip incremental updates unless breaking.

---

## Interesting Papers

2-3 papers maximum. Plain-language summary + one practical implication.

---

## Content Pick

One article, post, or write-up worth reading this week. Say why in one sentence.

---

## On the Radar

2-3 early signals — things not yet mainstream but worth watching.

---

Save the output as a markdown file. Do not add introductory or closing prose.
The digest starts with `## Must-Know This Week` and ends after `## On the Radar`.
```

---

## Delivery Options

After the digest is generated, optionally deliver via:
- **Slack:** pipe to a personal channel via Slack MCP
- **Gmail:** send to self via Gmail MCP
- **ClickUp:** create a task with digest as note
- **Plain file:** read directly from `/intelligence/digests/`
