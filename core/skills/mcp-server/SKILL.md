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

Read `assets/tool-design.template.md` and fill in one block per operation before proceeding.

For each operation:

1. Name the tool in `verb_resource_qualifier` snake_case (e.g., `search_orders`, `get_order`, `submit_payment`).
2. Write a description that includes:
   - What the tool does (positive trigger — when to call it)
   - How it relates to other tools in the set (sequencing hints)
   - What it does NOT do (negative trigger)
3. Define each parameter: name, description, type (`string`, `integer`, `boolean`, `object`, `array`), required/optional.
4. For write operations that are irreversible or require human confirmation, apply the **draft-confirm-submit** pattern:
   - `draft_*` — builds and validates the payload, returns a preview, writes nothing
   - `submit_*` — accepts the confirmed draft and persists it
5. If the system has a permission model, record the required permission per tool.

## Step 3: Select the Language and Read the Reference

Read the relevant reference file for implementation patterns and framework conventions:

- **Java (Spring Boot):** Read `references/java-spring-pattern.md`
- **Python (FastMCP / mcp SDK):** Read `references/python-pattern.md`
- **TypeScript (MCP TypeScript SDK):** Read `references/typescript-pattern.md`

If the target language is not listed, apply the universal principles in Step 4 and adapt to the language's idioms.

## Step 4: Universal Implementation Principles

Regardless of language:

1. **Tool provider** — group tools for one domain in one class/module/file.
2. **Auto-registration** — prefer declaration-based registration (annotations, decorators, or SDK `tool()` calls) over manual wiring.
3. **Token/auth injection** — accept auth credentials as a parameter on each tool. In the tool schema exposed to the LLM, hide or omit the auth parameter if the transport layer injects it automatically.
4. **Typed parameters** — map all inputs to the narrowest correct type. Never accept a free-text string where an enum or integer is correct.
5. **JsonNode / dict / any return type** — tools should return the raw service response rather than transforming it, unless the raw response is too large or contains fields the LLM should not reason over.
6. **Feature flags** — gate each tool group behind a config flag so it can be disabled without a redeploy.
7. **Observability** — wrap tool method bodies with a trace span named `mcp.tool.{tool_name}`.

## Step 5: Generate the Files

Using the completed tool design from Step 2 and the patterns from the reference file read in Step 3:

1. Generate one file per concern (tools declaration, service/client, config) following the reference pattern.
2. Add the tool group to the server's configuration (application.yml, .env, config file) with the feature flag set to `true`.

## Step 6: Validate

1. All tool names are snake_case.
2. Every description has a positive trigger and a negative trigger (or a "use this before/after X" sequencing hint).
3. No required parameter is missing.
4. Write tools use the draft-confirm-submit pattern where the operation is irreversible.
5. Auth credentials are accepted but not logged.

## Error Handling

- If the service's response schema is unknown, return the raw response and note in the tool description that the shape may vary.
- If a required config value (endpoint, subject, URL) is not known at generation time, insert a `TODO` placeholder and flag it in output.
- If the operation is destructive and no approval flow exists, require a boolean `confirm` parameter on the tool and refuse if `false`.
