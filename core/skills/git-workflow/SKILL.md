---
name: git-workflow
description: Executes git operations following consistent branch naming, commit message, and workflow conventions. Use when creating branches, writing commit messages, preparing PRs, or handling escalation-required git operations. Don't use for repository initialisation, resolving complex merge conflicts requiring domain knowledge, or CI/CD pipeline configuration.
---

# Git Workflow

## Step 1: Create the Branch

Read `references/conventions.md` for branch naming rules.
Branch from `main` (or the project's default branch) — never from another feature branch.
One logical change per branch — keep PRs reviewable.

## Step 2: Make Commits

Read `references/conventions.md` for the commit message format.

Each commit must be atomic — one logical change, fully working.
Do not commit:
- Generated files or build artifacts
- Secrets or credentials
- Files that break the build or tests

## Step 3: Before Opening a PR

1. Rebase on main — never merge main into the feature branch.
2. Confirm CI passes.
3. Delete branch after merge.

## Step 4: Check Escalation Triggers

Read `references/conventions.md` for operations that require escalation before proceeding.
If any trigger applies, escalate per `core/skills/escalation-rules.md` before acting.

## Error Handling

- If a commit has already been pushed and needs correction, do not amend — create a new commit. Amending pushed commits is an escalation trigger.
- If `.gitignore` was not set before the first commit and secrets were committed, treat as a CVSS ≥ 7.0 finding and escalate immediately.
