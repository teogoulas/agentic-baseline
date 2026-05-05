---
name: api-design
description: Designs REST API endpoints following consistent, predictable conventions. Use when defining a new endpoint, reviewing an API contract before implementation, or resolving inconsistencies in an existing API surface. Outputs a documented contract (URL, method, request shape, response shape, error codes). Don't use for GraphQL or event-driven API design, internal service-to-service messaging patterns, or implementing the API (design only).
---

# API Design

## Step 1: Define the Resource

1. Name the resource as a plural noun (e.g., `orders`, `payments`, `rule-profiles`).
2. Identify the operations needed: list, get one, create, update, delete, or custom action.
3. Confirm nesting depth — nest at most one level: `/resources/:id/sub-resources`.

## Step 2: Map Operations to Endpoints

Read `references/conventions.md` for the standard URL structure, HTTP methods, and status codes.

For each operation, define:
- HTTP method and URL
- Required and optional query parameters (for filtering, sorting, pagination)
- Request body shape (for POST/PUT/PATCH)
- Success response shape
- Error responses and status codes

## Step 3: Define the Response Shape

Use the standard envelope from `references/conventions.md`.
Every response must include `data` and `error` fields — never return a bare object.

## Step 4: Define Validation Rules

List every input validation rule explicitly before implementation:
- Required fields
- Type constraints
- Format constraints (regex, enum values, ranges)
- Cross-field constraints

## Step 5: Document Before Implementing

Produce the contract as a written spec. Implementation follows the spec — the spec does not follow the implementation.

Flag any breaking changes to existing contracts before finalising.

## Error Handling

- If the resource name is ambiguous, resolve it before designing endpoints — a wrong resource name propagates into URLs, code, and docs.
- If an operation doesn't map cleanly to REST verbs, prefer a sub-resource over a verb in the URL (e.g., `POST /orders/:id/cancellations` not `POST /orders/:id/cancel`).
