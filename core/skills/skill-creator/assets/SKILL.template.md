---
name: [skill-name]
description: [Action-oriented capability description in the third person. Max 1,024 characters. Include positive triggers ("Use when..."). Include negative triggers ("Don't use for..."). No first or second person pronouns.]
---

# [Skill Title]

## Procedures

**Step 1: [Action Phase]**
1. [Third-person imperative instruction, e.g., "Extract the query parameters..."]
2. [Instruction referencing an asset, e.g., "Read `assets/template.json` to structure the final output."]

**Step 2: [Action Phase]**
1. [Decision tree/conditional logic, e.g., "If source maps are required, run `scripts/build.sh`. Otherwise, skip to Step 3."]
2. [Instruction requiring JIT loading, e.g., "Read `references/auth-flow.md` to map the specific error codes."]
3. Execute `python3 scripts/[script-name].py` to [perform deterministic action].

## Error Handling

- If `scripts/[script-name].py` fails due to [specific edge case], execute [recovery step].
- If [condition B occurs], read `references/[troubleshooting-file].md`.
