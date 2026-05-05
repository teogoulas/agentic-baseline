---
name: mcp-server
description: Generates MCP server tool implementations for a given service and target language. Use when adding tools to an existing MCP server, wrapping an existing backend service as MCP tools, or scaffolding an MCP server from scratch in any language. Don't use for designing the LLM/agent layer, implementing MCP resources or prompts primitives, or choosing which transport to use (that is an architectural decision).
---

# MCP Server Tool Generation

## Step 1: Understand the Target Service

1. Identify the service being wrapped: its name, purpose, and how it is called (HTTP, gRPC, message queue, SDK, CLI, etc.).
2. List all operations to expose as tools. For each, note:
   - Is it a read or a write?
   - What are the inputs and their types?
   - What does a successful response look like?
   - Are there any safety constraints (irreversible, destructive, requires approval)?
3. Note the authentication model (JWT, API key, session token, none).

## Step 2: Design the Tool Set

Fill in the following for each operation before generating any code:

```
Tool name:        [verb_resource_qualifier in snake_case]
Operation type:   read | write
Description:      [positive trigger]. [sequencing hint]. [negative trigger].
Draft-confirm:    yes | no
Permission:       [permission.domain.verb / none]

Parameters:
  [name] ([type], required/optional) — [description]

Response shape:   [describe or example]
```

For write operations that are irreversible or require human confirmation, apply the **draft-confirm-submit** pattern:
- `draft_*` — builds and validates the payload, returns a preview, writes nothing
- `submit_*` — accepts the confirmed draft and persists it

If the operation is destructive and no approval flow exists, add a `confirm: boolean` parameter and refuse if `false`.

## Step 3: Select the Language and Apply Patterns

**Universal principles regardless of language:**

1. Group tools for one domain in one class/module/file.
2. Prefer declaration-based registration (annotations, decorators, `tool()` calls) over manual wiring.
3. Accept auth credentials as a parameter on each tool. Hide or omit from the LLM-facing schema if the transport injects it automatically.
4. Map all inputs to the narrowest correct type — never accept free text where an enum or integer is correct.
5. Return the raw service response unless it is too large or contains fields the LLM should not reason over.
6. Gate each tool group behind a config flag so it can be disabled without a redeploy.
7. Wrap each tool body with a trace span named `mcp.tool.{tool_name}`.

**Language-specific patterns:**

- **Java (Spring Boot):** `@McpToolProvider` class + `@McpTool` methods + `@ToolParam` parameters. Auto-discovered by `ToolRegistry` at startup. Three files per domain: `{Domain}Tools`, `{Domain}Service`, `{Domain}SubjectConfig`.
- **Python (FastMCP):** `@mcp.tool()` decorator on functions. Run with `mcp.run()` for stdio or `mcp.run(transport="sse")` for HTTP.
- **TypeScript (MCP SDK):** `server.tool(name, description, zodSchema, handler)`. Register tool groups via module functions called at startup.

## Step 4: Generate the Files

Using the completed tool design from Step 2:

1. Generate one file per concern (tools declaration, service/client, config) following the language pattern in Step 3.
2. Add the tool group to the server configuration with the feature flag set to `true`.

## Step 5: Validate

1. All tool names are snake_case.
2. Every description has a positive trigger and a negative trigger (or a sequencing hint).
3. No required parameter is missing.
4. Write tools use the draft-confirm-submit pattern where the operation is irreversible.
5. Auth credentials are accepted but not logged.

## Error Handling

- If the service's response schema is unknown, return the raw response and note in the tool description that the shape may vary.
- If a required config value (endpoint, subject, URL) is not known, insert a `TODO` placeholder and flag it in output.
