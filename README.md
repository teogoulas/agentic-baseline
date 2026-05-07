# Agentic Baseline

A portable, tool-agnostic AI engineering setup. Clone this repo on any machine, run `bootstrap.sh`,
and have your full agent context, skills, and workflows ready in any project immediately.

---

## Quick Start

```bash
git clone <your-repo-url> ~/Dev/agentic-baseline
cd ~/Dev/agentic-baseline
./bootstrap.sh
```

**First-time setup only:** edit `core/context/personal.md` with your identity, stack, and communication style — this is committed and shared across machines.

**Every machine:** create `core/context/personal.local.md` with environment-specific details (terminal, editor, local paths, active projects). It is gitignored and never committed.

```bash
cp core/context/personal.md core/context/personal.local.md
# edit personal.local.md to reflect this machine
```

---

## How It Works

The repo has two layers:

- **`/core`** — tool-agnostic skills, one agent (tool-broker), and context. Never mentions specific tools.
  Any agent on any platform can read and use these files.
- **`/adapters`** — thin wrappers per tool. Each adapter points its tool at `/core` and adds
  tool-specific config on top. Swapping tools means writing a new adapter, not touching core.

Agents are instructed to read your context files at session start. They know who you are,
what tools are available, and what they're allowed to do before the first message.

---

## Repository Structure

```
core/
  skills/         Reusable skill files (code review, security audit, git, API design, docs, etc.)
  context/        personal.md, permissions-default.md, tool-registry.md
  agents/         tool-broker.md — manages tool and MCP lifecycle

adapters/
  claude-code/    CLAUDE.md + install.sh
  codex/          AGENTS.md + install.sh
  copilot/        copilot-instructions.md + install.sh

feedback-loop/    Post-task improvement prompt + improvement log
update-loop/      Monthly baseline update workflow + scripts
intelligence/     Weekly digest workflow, sources list, saved digests
bootstrap.sh      Entry point — detects tools, runs relevant adapters
```

---

## Scripts Reference

### `bootstrap.sh`

The entry point for new machine setup and updates. Always runs a full refresh — safe to re-run at any time.

**What it does:**
1. Detects which tools are installed (`claude`, `codex`, `gh copilot`)
2. Regenerates the config for each detected tool (backs up and overwrites existing)
3. For Claude Code: runs `npx get-shit-done-cc --claude --global` and prints the `/plugin` install checklist
4. Makes loop scripts executable
5. Warns if `core/context/personal.md` still has unfilled TODOs

```bash
./bootstrap.sh
```

Re-run any time you install a new tool, move the repo, or want to pull in the latest adapter changes.

---

### `adapters/claude-code/install.sh`

Sets up Claude Code to load your baseline context in every session, in every project.

**What it does:**
1. Generates `~/.claude/CLAUDE.md` with **absolute paths** to all baseline files — this file
   is loaded by Claude Code globally, regardless of your working directory
2. Backs up any existing `~/.claude/CLAUDE.md` before overwriting
3. Copies `CLAUDE.md` (relative paths) to the baseline repo root for use inside this repo

**Why absolute paths matter:** Claude Code reads `~/.claude/CLAUDE.md` in every session.
If it contains relative paths like `core/context/tool-registry.md`, those paths only work
when you're inside the baseline repo. The global file uses absolute paths so it resolves
correctly from any project directory on this machine.

**Re-run if:**
- You move the baseline repo to a different path
- You install Claude Code on a new machine after cloning

```bash
./adapters/claude-code/install.sh
```

---

### `adapters/codex/install.sh`

**What it does:**
1. Copies `AGENTS.md` to the baseline repo root
2. Symlinks all `core/skills/*.md` files into `~/.codex/skills/` so Codex can find them
   as named skill files (set `CODEX_SKILLS_DIR` env var to override the target path)

```bash
./adapters/codex/install.sh
```

---

### `adapters/copilot/install.sh`

**What it does:**
1. Copies `copilot-instructions.md` to `.github/copilot-instructions.md` in the baseline root

For other projects: copy `.github/copilot-instructions.md` to each project's `.github/` directory.
Copilot does not support a global config file, so per-project setup is manual.

```bash
./adapters/copilot/install.sh
```

---

### `intelligence/run-digest.sh`

Prepares the weekly intelligence digest run.

**What it does:**
1. Finds the last digest in `intelligence/digests/` and calculates days since last run
2. Warns if fewer than 5 days have passed (pass `--force` to override)
3. Prints the scan window, output file path, and the exact steps to follow

**How to use:**
```bash
./intelligence/run-digest.sh
```
Then open a Claude Code session with web search enabled, paste the contents of
`intelligence/digest-prompt.md` with the printed date and scan window filled in.
The agent saves the digest to `intelligence/digests/YYYY-MM-DD.md`.
Commit it: `git add intelligence/digests/YYYY-MM-DD.md && git commit -m "chore: weekly digest YYYY-MM-DD"`

**Delivery options** (via MCP after the digest is saved):
- Slack: pipe to a personal channel via Slack MCP
- Gmail: send to self via Gmail MCP
- ClickUp: create a task with the digest as note
- Plain file: read directly from `intelligence/digests/`

---

### `update-loop/run-update.sh`

Prepares the monthly baseline update run.

**What it does:**
1. Reads the last update date from `update-loop/update-log.md`
2. Auto-generates `update-loop/baseline-snapshot.md` by concatenating all key core files
   with metadata — this snapshot is what the research agent reviews to propose changes
3. Prints the exact steps to follow

**How to use:**
```bash
./update-loop/run-update.sh
```
Then open a Claude Code session with web search enabled, paste `update-loop/research-prompt.md`
and `update-loop/mcp-review.md` with the printed dates filled in.
The agent outputs JSON with findings and proposed diffs.
Review, approve the diffs, apply them, then commit:
`git commit -m "chore: monthly baseline update YYYY-MM-DD"`
Append a summary to `update-loop/update-log.md`.

Note: `baseline-snapshot.md` is auto-generated — it is listed in `.gitignore` and should not
be committed or edited manually.

---

## Claude Code Plugins

Five plugins extend Claude Code beyond what the baseline markdown files provide.
`bootstrap.sh` handles GSD automatically. The rest are one-time installs per machine via a Claude Code session.

| Plugin | Install | Activation |
|---|---|---|
| **GSD** | `npx get-shit-done-cc --claude --global` (auto via bootstrap) | Manual — `/gsd-*` commands for multi-session project workflow |
| **Superpowers** | `/plugin install superpowers@claude-plugins-official` | Automatic — skills trigger based on task context |
| **Skill Creator** | `/plugin install skill-creator@claude-plugins-official` | Manual — `/skill-creator` |
| **Frontend Design** | `/plugin install frontend-design@claude-plugins-official` | Manual — `/frontend-design` |
| **Context Mode** | `/plugin marketplace add mksglu/context-mode` then `/plugin install context-mode@context-mode` | Automatic — always-on context window optimisation via hooks |

Once installed, plugins persist globally across all sessions and projects. Re-run the `/plugin install` commands in a Claude Code session to update them.

---

## Three Loops

### 1. Feedback Loop — after every significant task

After completing any significant task, paste `feedback-loop/post-task-template.md` into your
agent while the task context is still loaded. The agent outputs structured JSON covering:

- What you had to explain more than once
- Output formats that needed fixing
- Escalations that should have been autonomous (and vice versa)
- Missing tools or MCPs
- Suggested edits to skill files and context

Apply changes immediately, or log them in `feedback-loop/improvement-log.md` for batching.
This loop is what makes the baseline compound over time.

### 2. Weekly Intelligence Digest

Run `./intelligence/run-digest.sh` each week. Sources are defined in `intelligence/sources.md`
(edit this file as your interests evolve). The digest covers:

- Must-know developments affecting your work as an agentic engineer
- New tools and releases
- Interesting papers (plain-language summaries)
- One content pick
- Early signals not yet mainstream

Target read time: under 5 minutes. All digests are saved and committed to `intelligence/digests/`.

### 3. Monthly Baseline Update

Run `./update-loop/run-update.sh` once a month, or immediately after a major model or tool release.
The research agent scans for: new models, new tools, architectural pattern changes, security
vulnerabilities, and deprecations. It also runs an MCP audit via `update-loop/mcp-review.md`.

You review and approve every proposed change before anything is applied.

---

## Per-Machine Context

`core/context/personal.md` is committed and contains everything generic about you: identity,
full stack, projects, communication style.

For machine-specific details (terminal app, editor, local file paths, language versions),
create `core/context/personal.local.md` on that machine:

```bash
cp core/context/personal.md core/context/personal.local.md
# edit to reflect this machine
```

The `.local.md` file is gitignored — it stays on-device. Agents read it first; fall back
to `personal.md` for anything not listed. When you set up a new machine, create a fresh
`personal.local.md` after cloning.

---

## New Machine Setup

```bash
git clone <your-repo-url> ~/Dev/agentic-baseline
cd ~/Dev/agentic-baseline
./bootstrap.sh
cp core/context/personal.md core/context/personal.local.md
# edit personal.local.md: terminal, editor, primary language, local paths
```

---

## New Project Setup

Because `bootstrap.sh` installs a global `~/.claude/CLAUDE.md`, your baseline context loads
automatically in every new Claude Code session regardless of directory — no per-project setup needed.

For Copilot: copy `.github/copilot-instructions.md` to the new project's `.github/` directory.

For any tool that doesn't support global config: copy the relevant adapter config file to
the project root.

---

## Validating the Setup

Open a new Claude Code session in any directory — including a brand new project — and ask:

> "What do you know about my personal context, available tools, and escalation rules?"

Claude should respond with your identity, stack, active projects, available MCPs, and
escalation thresholds. If it can't, re-run `./adapters/claude-code/install.sh` and check
that `~/.claude/CLAUDE.md` was generated with correct absolute paths.

---

## Tool Registry

`core/context/tool-registry.md` is the source of truth for what tools and MCPs are available.

- Agents read it at session start — never assume a capability exists that isn't listed
- Only the tool-broker updates it (see `core/agents/tool-broker.md`)
- When a task needs a missing capability: tool-broker surfaces a proposal, user approves, nothing is auto-installed
- Monthly MCP audit is part of the update loop (`update-loop/mcp-review.md`)

---

## Adding a New Adapter

1. Create `adapters/<tool-name>/`
2. Write the config file in the format the tool expects — instruct the agent to read
   `/core` files at session start, add tool-specific config on top
3. Write `install.sh` — generate or copy the config with correct paths
4. Add detection logic to `bootstrap.sh`

The core never changes when you add an adapter.

---

## Escalation Rules

All agents follow `core/skills/escalation-rules.md`. These cannot be overridden by task instructions:

- Destructive actions always escalate
- CVSS ≥ 7.0 security findings stop the audit immediately
- Missing tools go to the tool-broker — never auto-install
- Production branches always require explicit instruction
- Confidence below ~70% on an irreversible action always escalates
