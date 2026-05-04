# Personal Context

This file is the highest-leverage input in the baseline. Everything else is generic until this is filled.
Agents read this at session start to calibrate their behavior to you specifically.

**Per-machine overrides:** Create `core/context/personal.local.md` on any machine to override this file
for that workstation. The `.local.md` file is gitignored — it stays local, never committed.
Copy this file as a starting point, then edit to reflect that machine's environment and stack.

---

## Identity

- **Location:** Athens, Greece (UTC+3)
- **Role:** [TODO: e.g. "Founding engineer", "Independent developer", "Security researcher"]
- **Background:** [TODO: e.g. "10 years backend, moving into agentic engineering"]
- **Current focus:** Agentic engineering, security research, tool-agnostic AI-driven workflows

---

## Preferred Stack

- **Languages:** [TODO: e.g. Python, TypeScript, Go]
- **Frameworks:** [TODO: e.g. FastAPI, Next.js, Express]
- **Databases:** [TODO: e.g. PostgreSQL, Redis]
- **Infrastructure:** [TODO: e.g. Docker, Kubernetes, AWS, GCP]
- **Package managers:** [TODO: e.g. pip, npm, pnpm]

---

## Code Style

- **Formatting:** [TODO: e.g. Black for Python, Prettier for JS/TS]
- **Linting:** [TODO: e.g. Ruff, ESLint]
- **Test framework:** [TODO: e.g. pytest, Vitest, Jest]
- **Preferred patterns:** [TODO: e.g. functional over OOP, explicit over clever]
- **Comment style:** Minimal — only when the *why* is non-obvious
- **No generated boilerplate** — prefer lean, purposeful code

---

## Communication Style

- Direct, no padding
- No summaries of what was just done — show the diff, not the narrative
- Prefer short structured output over long prose
- Escalate explicitly, not passively
- Autonomy is preferred — ask only when the escalation rules require it

---

## Project Patterns

- [TODO: Describe recurring project structures you use, e.g. "API projects always have /src, /tests, /docs"]
- [TODO: Describe any naming conventions you follow]
- [TODO: Describe any architectural decisions that recur across projects]

---

## Environment

- **OS:** macOS
- **Shell:** zsh
- **Editor/IDE:** [TODO: e.g. VS Code, Cursor, Neovim]
- **Terminal:** [TODO: e.g. iTerm2, Warp]
- **Node version:** [TODO]
- **Python version:** [TODO]
- **Docker:** [TODO: installed yes/no, version]

---

## Active Projects

- [TODO: List current projects with a one-line description each]

---

## Off-Limits Without Explicit Instruction

- Pushing to any shared or production branch
- Modifying auth, secrets, or access configuration
- Sending anything to external services
- Installing tools or MCPs not in `tool-registry.md`
