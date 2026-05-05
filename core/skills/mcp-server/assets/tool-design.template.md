# Tool Design — [Service Name]

**Service:** [name and one-line purpose]
**Protocol:** [HTTP / NATS / gRPC / SDK / CLI / other]
**Auth model:** [JWT / API key / session token / none]
**Target language:** [Java / Python / TypeScript / other]

---

## Tools

### [tool_name]
- **Operation type:** read | write
- **Description:** [positive trigger]. [sequencing hint — use before/after X]. [negative trigger — does not do Y].
- **Draft-confirm-submit:** yes | no
- **Permission:** [permission.domain.verb / none]

| Parameter | Type | Required | Description |
|---|---|---|---|
| [name] | string / integer / boolean / object / array | yes / no | [description] |

**Response shape:** [describe or paste example]

---

<!-- repeat block above for each tool -->

## Safety Constraints

- [ ] Any destructive operations? → draft-confirm-submit required
- [ ] Any irreversible operations without approval flow? → add `confirm: boolean` parameter
- [ ] Auth credentials logged anywhere? → must not be
