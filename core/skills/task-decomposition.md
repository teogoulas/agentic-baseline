# Task Decomposition

Use this skill to break large or ambiguous tasks into concrete, routable subtasks.

---

## When to Decompose

Decompose any task that:
- Has more than one distinct deliverable
- Spans more than one specialist domain (e.g. code + security + docs)
- Would take more than ~30 minutes end-to-end
- Has subtasks that could run in parallel

---

## Process

### Step 1: Clarify Before Decomposing

If the task is ambiguous, resolve it first:
- What is the expected output?
- What is in and out of scope?
- Are there dependencies on other teams, systems, or data?
- What is the deadline or priority?

Do not decompose an ambiguous task — the decomposition will be wrong.

### Step 2: Identify Subtasks

List every distinct unit of work. A subtask is:
- Owned by one agent or role
- Has a clear, verifiable output
- Can be reviewed independently

### Step 3: Map Dependencies

For each subtask, identify:
- What it needs as input
- What it produces as output
- Which other subtasks depend on it

Use this to determine what can run in parallel.

### Step 4: Check Capability Gaps

For each subtask, confirm the required capability exists in `core/context/tool-registry.md`.
If a subtask needs a missing tool: surface it to tool-broker before routing.

### Step 5: Assign and Route

Map each subtask to the correct specialist (see orchestrator routing table).
State the execution order explicitly.

---

## Output Format

```
DECOMPOSITION: [task name]

SUBTASKS:
  [id]. [description]
      Agent: [which agent]
      Input: [what it needs]
      Output: [what it produces]
      Depends on: [id list, or "none"]
      Run: [PARALLEL with X | SEQUENTIAL after Y]

CAPABILITY GAPS: [list, or "none"]

EXECUTION ORDER: [describe the sequence]
```

---

## Signals That Decomposition Is Wrong

- A subtask has no clear output
- Two subtasks have the same owner and could be merged
- A subtask spans multiple domains (it should be split further)
- The dependency chain is longer than 4 steps (consider restructuring)
