---
name: code-review
description: Applies a structured multi-domain checklist to review code changes for correctness, security, contracts, test coverage, quality, and operational readiness. Use when reviewing a PR or code change before merge. Escalates any security finding with CVSS ≥ 7.0. Don't use for full security audits (use security-audit), architecture design reviews, or performance profiling.
---

# Code Review Checklist

Apply this checklist when reviewing any code change. Use `reviewer` agent for structured output.

---

## Correctness

- [ ] Does the code do what the task description says it should?
- [ ] Are edge cases handled (empty input, null, zero, max values)?
- [ ] Are error conditions handled at system boundaries?
- [ ] Are there any off-by-one errors, race conditions, or concurrency issues?
- [ ] Does the code handle partial failures gracefully?

## Security

- [ ] Is all user input validated before use?
- [ ] Are there any injection risks (SQL, command, template)?
- [ ] Is authentication checked before authorization?
- [ ] Are secrets or credentials hardcoded anywhere?
- [ ] Are error messages safe to expose (no stack traces, no internal paths)?
- [ ] If files are written: is the path user-controlled?

## Contracts & APIs

- [ ] Are any public APIs or interfaces changed in a breaking way?
- [ ] Are any shared data models modified in a backward-incompatible way?
- [ ] Are API changes documented?

## Tests

- [ ] Are there tests for the changed code paths?
- [ ] Do existing tests still pass?
- [ ] Are tests testing behavior (not implementation)?

## Dependencies

- [ ] Are new dependencies justified?
- [ ] Are versions pinned?
- [ ] Are there known CVEs in added packages?

## Code Quality

- [ ] Are names self-explanatory?
- [ ] Is there any dead code?
- [ ] Are comments present only where the *why* is non-obvious?
- [ ] Is there unnecessary complexity that could be simplified?
- [ ] Does this introduce any tech debt that isn't tracked?

## Operations

- [ ] If this ships: will it behave correctly in production?
- [ ] Are there any performance implications at scale?
- [ ] Is there adequate logging for diagnosing production issues?
- [ ] Are any required config changes documented?

---

## Escalation

If any finding is CVSS ≥ 7.0, escalate immediately per `core/skills/escalation-rules.md`.
Do not continue the review until acknowledged.
