# MCP Review Prompt

Run monthly alongside research-prompt.md. Instructs the tool-broker to audit installed MCPs
and propose additions, removals, or updates. No changes are made until the user approves.

---

## Prompt (paste this to your agent with web search enabled)

```
You are the tool-broker running a monthly MCP audit. Today's date is [INSERT DATE].

Read core/context/tool-registry.md — this is the current list of installed MCPs.

Perform the following:

1. **Verify each installed MCP**
   For each entry in the registry:
   - Is the MCP server still actively maintained?
   - Are there any reported issues, breaking changes, or deprecations?
   - Based on usage patterns (check improvement-log.md and update-log.md for mentions),
     has this MCP actually been used in the past month?
   - Flag any that are broken, unmaintained, or unused.

2. **Scan for new MCP servers**
   Search the MCP ecosystem for servers not currently in the registry that would be
   directly useful for an agentic engineer with this profile:
   - Agentic engineering and developer workflows
   - Security research and auditing
   - Productivity (calendar, tasks, communication)
   - Local automation

   Focus on: well-maintained, actively developed, non-redundant with existing registry entries.

3. **Produce a proposal**
   Output the following structure — make no changes until the user approves:

   {
     "audit_date": "YYYY-MM-DD",
     "verified": [
       {
         "name": "MCP name",
         "status": "OK|BROKEN|UNUSED|DEPRECATED",
         "notes": "any relevant findings"
       }
     ],
     "proposed_removals": [
       {
         "name": "MCP name",
         "reason": "why it should be removed"
       }
     ],
     "proposed_additions": [
       {
         "name": "MCP server name",
         "capabilities": "what it can do",
         "install": "exact install command or URL",
         "why": "why it's worth adding given the user's workflow"
       }
     ],
     "proposed_updates": [
       {
         "name": "MCP name",
         "change": "what needs to be updated"
       }
     ]
   }
```

---

## After Getting the Output

1. Review each proposed removal, addition, and update
2. Approve or reject each item individually
3. For approved changes: route to tool-broker Update mode to apply them to tool-registry.md
4. Commit registry changes as: `chore: mcp-registry update YYYY-MM-DD`
