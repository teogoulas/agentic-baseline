# Tool Registry

This is the authoritative record of what tools and MCPs are currently available.
Agents read this at session start. Never assume a capability exists that is not listed here.
Only the tool-broker updates this file. Do not edit manually.

---

## Installed Agent Tools

| Tool | Purpose | Detected via |
|---|---|---|
| Claude Code | Code editing, file ops, git, MCP host, task orchestration | `claude` in PATH |

---

## Active MCPs

| Server | Capabilities | Last Verified |
|---|---|---|
| Google Calendar | Read/write calendar events, check availability, schedule meetings | 2026-05-04 |
| ClickUp | Create/update tasks, read projects and spaces, manage task status | 2026-05-04 |
| Google Drive | Read/write files, search documents, manage folders | 2026-05-04 |
| Slack | Send messages, read channels, post to specific channels | 2026-05-04 |
| Gmail | Send email, read inbox, search messages, draft and reply | 2026-05-04 |

---

## Capability Index

Use this to answer "what can I use for X?" without reading every entry above.

| Need | Use |
|---|---|
| Schedule a meeting | Google Calendar |
| Task tracking / project management | ClickUp |
| Store or retrieve a document | Google Drive |
| Send a team notification | Slack |
| Send an email | Gmail |
| Code editing or file operations | Claude Code |

---

## Pending / Proposed

Tools and MCPs proposed by the tool-broker but not yet approved:

| Tool | Proposed | Reason | Status |
|---|---|---|---|
| — | — | — | — |

---

## Last Full Audit

Date: 2026-05-04
Audited by: tool-broker (initial seed — user verified)
