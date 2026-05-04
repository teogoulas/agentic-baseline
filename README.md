# Agentic Baseline

A portable, tool-agnostic AI engineering setup. Clone this repo on any machine and bootstrap
a fully configured agentic workspace in minutes.

## Quick Start

```bash
git clone <your-repo-url> agentic-baseline
cd agentic-baseline
./bootstrap.sh
```

Then fill in `core/context/personal.md` — that file is the highest-leverage input.
Everything else is generic until it is filled.

---

## Structure

```
core/           Tool-agnostic skills, agent definitions, and context
adapters/       Thin wrappers for specific tools (Claude Code, Codex, Copilot)
feedback-loop/  Post-task improvement prompts and improvement log
update-loop/    Monthly baseline update workflow
intelligence/   Weekly digest workflow and saved digests
bootstrap.sh    Detects installed tools, runs relevant adapters
```

### Core

`core/` never mentions specific tools by name. Any agent on any tool can use it.

| Directory | Contents |
|---|---|
| `core/skills/` | Reusable skill files — code review, security audit, git, API design, etc. |
| `core/context/` | Who you are, what's allowed, what tools are available |
| `core/agents/` | Specialist agent definitions — orchestrator, reviewer, security auditor, etc. |

### Adapters

Each adapter is a thin wrapper that points a specific tool at `/core`:

| Adapter | File installed |
|---|---|
| Claude Code | `CLAUDE.md` at repo root |
| Codex | `AGENTS.md` at repo root |
| Copilot | `.github/copilot-instructions.md` |

Adding a new tool: create a new directory under `/adapters/`, write a thin config that
references `/core`, add a `install.sh`, and register it in `bootstrap.sh`.

---

## Three Loops

### 1. Feedback Loop (after every significant task)

```bash
# Paste into your agent after completing a task:
cat feedback-loop/post-task-template.md
```

Produces structured JSON identifying what to improve. Apply changes to `/core` or log them
in `feedback-loop/improvement-log.md` for batching.

### 2. Weekly Intelligence Digest

```bash
./intelligence/run-digest.sh
```

Prints the digest prompt pre-filled with today's date and scan window.
Paste into your agent with web search enabled. Output saves to `intelligence/digests/YYYY-MM-DD.md`.

Delivery options: Slack, Gmail, ClickUp (via MCP), or read directly from the digests folder.

### 3. Monthly Baseline Update

```bash
./update-loop/run-update.sh
```

1. Generates a snapshot of current core files
2. Prints the research prompt pre-filled with dates
3. Paste into your agent with web search enabled
4. Review the JSON output, approve changes, and apply as a git commit

Run this monthly, or immediately after a major model or tool release.
The MCP review (`update-loop/mcp-review.md`) runs as part of this cycle.

---

## Tool Registry

`core/context/tool-registry.md` is the source of truth for what tools and MCPs are available.

- Agents read it at session start — they never assume a capability exists that isn't listed
- Only the tool-broker updates it
- When a task needs a missing capability, the tool-broker surfaces a proposal — nothing is auto-installed

To propose a new tool or MCP, see `core/agents/tool-broker.md`.

---

## Adding a New Adapter

1. Create `adapters/<tool-name>/`
2. Write the config file in the format the tool expects
3. The config should: instruct the agent to read `/core` files at session start, and add any tool-specific settings on top
4. Write `install.sh` to copy or symlink the config file
5. Add detection logic to `bootstrap.sh`

The core never changes when you add an adapter. That's the point.

---

## Escalation

All agents follow `core/skills/escalation-rules.md`. Key rules that cannot be overridden:

- Destructive actions always escalate
- CVSS ≥ 7.0 security findings always escalate
- Missing tools go to the tool-broker — never auto-install
- Production branches always require explicit instruction
