---
name: api-design
description: Designs REST API endpoints following consistent, predictable conventions. Use when defining a new endpoint, reviewing an API contract before implementation, or resolving inconsistencies in an existing API surface. Outputs a documented contract (URL, method, request shape, response shape, error codes). Don't use for GraphQL or event-driven API design, internal service-to-service messaging patterns, or implementing the API (design only).
---

# API Design

## Core Principles

- **Consistency over cleverness** — predictable beats clever every time
- **Explicit contracts** — inputs, outputs, and errors are documented before implementation
- **Fail loudly** — return clear errors, never silent failures
- **Versioning from day one** — even if v1 is the only version that ever exists

## Step 1: Define the Resource

1. Name the resource as a plural noun (e.g., `orders`, `payments`, `rule-profiles`).
2. Identify the operations needed: list, get one, create, update, delete, or custom action.
3. Confirm nesting depth — nest at most one level: `/resources/:id/sub-resources`.

## Step 2: Map Operations to Endpoints

```
GET    /resources           — list
GET    /resources/:id       — get one
POST   /resources           — create
PUT    /resources/:id       — replace
PATCH  /resources/:id       — partial update
DELETE /resources/:id       — delete
```

- No verbs in URLs — the HTTP method is the verb
- Use query params for filtering, sorting, pagination — not path params

For each operation, define: HTTP method, URL, required/optional query params, request body shape, success response, error responses.

## Step 3: Define the Response Shape

Every response uses this envelope — never return a bare object:

```json
{ "data": {}, "error": null, "meta": {} }
```

Error response:
```json
{ "data": null, "error": { "code": "RESOURCE_NOT_FOUND", "message": "Human-readable", "details": {} } }
```

## Step 4: Assign Status Codes

| Code | Use |
|---|---|
| 200 | Success |
| 201 | Created |
| 204 | Success, no content (DELETE) |
| 400 | Bad request — client error, fixable by client |
| 401 | Unauthenticated |
| 403 | Unauthorized — authenticated but lacks permission |
| 404 | Not found |
| 409 | Conflict (duplicate, state mismatch) |
| 422 | Validation error |
| 429 | Rate limited |
| 500 | Server error — not the client's fault |

## Step 5: Define Validation Rules

List every input validation rule explicitly before implementation: required fields, type constraints, format constraints, cross-field constraints.

## Step 6: Document Before Implementing

Produce the contract as a written spec. Flag any breaking changes to existing contracts before finalising.

## Rules

- Validate input at the boundary — before it touches business logic
- Never expose internal IDs, stack traces, or file paths in error responses
- Authentication before authorisation — always check identity first, then permissions
- Rate limiting on all public endpoints
- Pagination on all list endpoints — never return unbounded collections

## Error Handling

- If the resource name is ambiguous, resolve it before designing endpoints.
- If an operation doesn't map cleanly to REST verbs, prefer a sub-resource over a verb in the URL (e.g., `POST /orders/:id/cancellations` not `POST /orders/:id/cancel`).
