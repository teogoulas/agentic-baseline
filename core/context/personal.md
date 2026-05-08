# Personal Context

This file is the highest-leverage input in the baseline. Everything else is generic until this is filled.
Agents read this at session start to calibrate their behavior to you specifically.

**Per-machine overrides:** Create `core/context/personal.local.md` on any machine to add or override
machine-specific details (terminal, editor, primary language, local paths). The `.local.md` file is
gitignored — it stays local, never committed. Agents read it first if it exists.

---

## Identity

- **Location:** Athens, Greece (UTC+3)
- **Role:** Software Engineer — back-end oriented, with cloud/DevOps experience
- **Background:** In the industry since 2016 (~9 years). Core expertise in Java and Python backend. Secondary experience in NodeJS, React, and SCSS. Currently transitioning into agentic engineering.
- **Current focus:** Agentic engineering, security research, AI-driven workflows

---

## Stack

- **Languages:** Python, Java, TypeScript, Groovy
- **Frameworks:** FastAPI, Spring, Spring Boot, React, Grails
- **Databases:** MySQL, MSSQL Server, MongoDB, DynamoDB, Elasticsearch
- **Infrastructure:** Docker, AWS (Lambda, Batch Fargate, API Gateway, S3, DynamoDB, Cognito, SES, ECR, EventBridge, CloudFront), Kubernetes, Terraform
- **Package managers:** pip, npm, nvm, sdkman (Java)

---

## AI Models

- **Default model:** `claude-sonnet-4-6`
- **Never use Opus models** unless the user explicitly requests it for a specific task — too expensive for routine use
- This overrides any skill or tool that suggests Opus as a default (including the bundled `claude-api` skill)

---

## Code Style

- Lean, purposeful code — no unnecessary abstractions
- Comments only when the *why* is non-obvious
- No boilerplate or generated filler
- Match the style already in the project before introducing new conventions
- Commit messages: one line only, no Co-Authored-By section

---

## Communication Style

- Direct, no padding
- No trailing summaries of what was just done
- Short structured output over long prose
- Escalate explicitly, not passively
- Autonomy preferred — ask only when the escalation rules require it

---

## Active Projects

Add workspace-specific projects in `core/context/personal.local.md` — this file is gitignored and stays on-device.

---

## Off-Limits Without Explicit Instruction

- Pushing to any shared or production branch
- Modifying auth, secrets, or access configuration
- Calling AWS APIs or external services
- Installing tools or MCPs not in `tool-registry.md`
- Modifying production AWS infrastructure
