# API Design

Guidelines for designing APIs that are consistent, predictable, and maintainable.

---

## Core Principles

- **Consistency over cleverness** — predictable beats clever every time
- **Explicit contracts** — inputs, outputs, and errors are documented before implementation
- **Fail loudly** — return clear errors, never silent failures
- **Versioning from day one** — even if v1 is the only version that ever exists

---

## REST

### URL Structure
```
GET    /resources           — list
GET    /resources/:id       — get one
POST   /resources           — create
PUT    /resources/:id       — replace
PATCH  /resources/:id       — partial update
DELETE /resources/:id       — delete
```

- Plural nouns for collections
- No verbs in URLs — the HTTP method is the verb
- Nest only one level deep: `/resources/:id/sub-resources`
- Use query params for filtering, sorting, pagination — not path params

### Response Shape
```json
{
  "data": {},
  "error": null,
  "meta": {}
}
```

Errors:
```json
{
  "data": null,
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "Human-readable message",
    "details": {}
  }
}
```

### Status Codes

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

---

## General Rules

- Validate input at the boundary — before it touches business logic
- Never expose internal IDs, stack traces, or file paths in error responses
- Authentication before authorization — always check identity first, then permissions
- Rate limiting on all public endpoints
- Pagination on all list endpoints — never return unbounded collections
- Document breaking changes before shipping them
