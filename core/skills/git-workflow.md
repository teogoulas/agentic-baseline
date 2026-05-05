---
name: git-workflow
description: Executes git operations following consistent branch naming, commit message, and workflow conventions. Use when creating branches, writing commit messages, preparing PRs, or handling escalation-required git operations. Don't use for repository initialisation, resolving complex merge conflicts requiring domain knowledge, or CI/CD pipeline configuration.
---

# Git Workflow

## Branch Naming

```
[type]/[short-description]

feat/     — new feature
fix/      — bug fix
chore/    — maintenance, tooling, deps
docs/     — documentation only
refactor/ — no behavior change
security/ — security fix or hardening
hotfix/   — urgent production fix
```

## Commit Messages

Format: `[type]: [imperative description]`

- Imperative mood — "add", "fix", "remove" not "added", "fixed", "removed"
- Under 72 characters for the subject line
- Body (optional): explain *why*, not *what*

## Step 1: Create the Branch

Branch from `main` (or the project's default branch) — never from another feature branch.
One logical change per branch — keep PRs reviewable.

## Step 2: Make Commits

Each commit must be atomic — one logical change, fully working. Do not commit:
- Generated files or build artifacts
- Secrets or credentials
- Files that break the build or tests

## Step 3: Before Opening a PR

1. Rebase on main — never merge main into the feature branch.
2. Confirm CI passes.
3. Delete branch after merge.

## Escalation Triggers

These require explicit instruction before proceeding (per `core/skills/escalation-rules.md`):
- Pushing to `main`, `master`, `prod`, or equivalent
- Force push to any branch
- Amending a commit that has already been pushed

## Auto-Generated Files

- List in `.gitignore` if ephemeral, OR
- Commit with `chore:` prefix and a clear automated message
- Never edit manually after generation

## Error Handling

- If a commit has already been pushed and needs correction, create a new commit — do not amend. Amending pushed commits is an escalation trigger.
- If `.env` or secrets were committed, treat as a CVSS ≥ 7.0 finding and escalate immediately.
