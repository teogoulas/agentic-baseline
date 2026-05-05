# TypeScript MCP Pattern

Using the official `@modelcontextprotocol/sdk`.

---

## Basic Structure

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({ name: "my-service", version: "1.0.0" });

// Tool registration
server.tool(
  "search_orders",
  "Search orders by status. Use before get_order to find the id. Does not return line items.",
  {
    status: z.string().optional().describe("Filter by status (PENDING, ACTIVE, CLOSED)"),
    limit: z.number().int().optional().default(50).describe("Max results"),
  },
  async ({ status, limit }) => {
    const result = await orderClient.search({ status, limit });
    return { content: [{ type: "text", text: JSON.stringify(result) }] };
  }
);

server.tool(
  "get_order",
  "Get a single order including line items. Call search_orders first to find the id.",
  { orderId: z.string().describe("The order id") },
  async ({ orderId }) => {
    const result = await orderClient.get(orderId);
    return { content: [{ type: "text", text: JSON.stringify(result) }] };
  }
);

// Start with stdio transport (for Claude Desktop / claude CLI)
const transport = new StdioServerTransport();
await server.connect(transport);
```

---

## HTTP SSE Transport

```typescript
import { SSEServerTransport } from "@modelcontextprotocol/sdk/server/sse.js";
import express from "express";

const app = express();
const transport = new SSEServerTransport("/messages", res);
app.get("/sse", (req, res) => server.connect(new SSEServerTransport("/messages", res)));
app.post("/messages", (req, res) => transport.handlePostMessage(req, res));
app.listen(3000);
```

---

## Project Structure

```
src/
  index.ts               ← server setup + transport
  tools/
    orders.ts            ← tool registrations for the orders domain
    payments.ts
  clients/
    orderClient.ts       ← HTTP/gRPC client
  config.ts              ← env-based config
```

Registering tools from a module:

```typescript
// tools/orders.ts
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";

export function registerOrderTools(server: McpServer) {
  server.tool("search_orders", "...", { status: z.string().optional() }, handler);
  server.tool("get_order", "...", { orderId: z.string() }, handler);
}

// index.ts
import { registerOrderTools } from "./tools/orders.js";
registerOrderTools(server);
```

---

## Authentication

Inject token from environment or transport context — do not expose it as a tool parameter:

```typescript
server.tool("get_order", "...", { orderId: z.string() }, async ({ orderId }, extra) => {
  const token = process.env.SERVICE_TOKEN ?? extra.authInfo?.token;
  const result = await orderClient.get(orderId, token);
  return { content: [{ type: "text", text: JSON.stringify(result) }] };
});
```

---

## Feature Flags

```typescript
if (process.env.MCP_TOOLS_ORDERS_ENABLED !== "false") {
  registerOrderTools(server);
}
```

---

## package.json dependencies

```json
{
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.0.0",
    "zod": "^3.0.0"
  }
}
```
