# Python MCP Pattern

Two options depending on complexity. FastMCP for simple servers; the low-level `mcp` SDK for full control.

---

## Option A: FastMCP (recommended for most cases)

```python
from fastmcp import FastMCP
from pydantic import Field
from typing import Annotated, Optional

mcp = FastMCP("my-service")

@mcp.tool()
def search_orders(
    status: Annotated[Optional[str], Field(description="Filter by status (PENDING, ACTIVE, CLOSED)")] = None,
    limit: Annotated[int, Field(description="Max results (default 50)")] = 50,
) -> dict:
    """Search orders by status. Use before get_order to locate the id.
    Does not return line item detail — use get_order for that."""
    return order_client.search(status=status, limit=limit)

@mcp.tool()
def get_order(
    order_id: Annotated[str, Field(description="The order id")],
) -> dict:
    """Get a single order including line items. Call search_orders first to find the id."""
    return order_client.get(order_id)

if __name__ == "__main__":
    mcp.run()  # defaults to stdio transport
```

Transport options:
```python
mcp.run()                          # stdio (default — for Claude Desktop, claude CLI)
mcp.run(transport="sse")           # HTTP SSE (for web clients)
```

---

## Option B: Low-level mcp SDK

```python
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp import types

server = Server("my-service")

@server.list_tools()
async def list_tools() -> list[types.Tool]:
    return [
        types.Tool(
            name="search_orders",
            description="Search orders by status. Use before get_order. Does not return line items.",
            inputSchema={
                "type": "object",
                "properties": {
                    "status": {"type": "string", "description": "Filter by status"},
                    "limit": {"type": "integer", "description": "Max results"},
                },
                "required": [],
            },
        ),
    ]

@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[types.TextContent]:
    if name == "search_orders":
        result = order_client.search(**arguments)
        return [types.TextContent(type="text", text=str(result))]
    raise ValueError(f"Unknown tool: {name}")

async def main():
    async with stdio_server() as (read, write):
        await server.run(read, write, server.create_initialization_options())
```

---

## Project Structure

```
my_mcp_server/
  server.py              ← FastMCP app or Server instance + tool declarations
  tools/
    orders.py            ← tool functions for the orders domain
    payments.py          ← tool functions for the payments domain
  clients/
    order_client.py      ← HTTP/gRPC/DB client for the order service
  config.py              ← settings (base URL, timeouts, auth)
```

---

## Authentication

For tools that call authenticated backends, pass the token as an env var or inject via context — do not accept it as a tool parameter visible to the LLM:

```python
import os

@mcp.tool()
def get_order(order_id: str) -> dict:
    """Get a single order by id."""
    token = os.environ["SERVICE_TOKEN"]
    return order_client.get(order_id, token=token)
```

If the auth token must be per-request (e.g., delegated user token), use FastMCP's dependency injection or pass through context:

```python
from fastmcp import Context

@mcp.tool()
async def get_order(order_id: str, ctx: Context) -> dict:
    token = ctx.request_context.meta.get("token")
    return await order_client.get(order_id, token=token)
```

---

## Feature Flags

```python
import os
from fastmcp import FastMCP

mcp = FastMCP("my-service")

if os.getenv("MCP_TOOLS_ORDERS_ENABLED", "true") == "true":
    from tools.orders import register_order_tools
    register_order_tools(mcp)
```
