---
name: skill-creator
description: Authors and structures professional-grade agent skills following the agentskills.io spec. Use when creating new skill directories, drafting procedural instructions, or optimizing metadata for discoverability. Use to evaluate existing skill files against the spec and propose improvements. Don't use for general documentation, non-agentic library code, or README files.
---

# Skill Authoring Procedure

Follow these steps to generate a skill that adheres to the agentskills.io specification and progressive disclosure principles.

## Step 1: Initialize and Validate Metadata

1. Define a unique `name`: 1-64 characters, lowercase, numbers, and single hyphens only.
2. Draft a `description`: Max 1,024 characters, written in the third person, including negative triggers.
3. **Execute validation script:** Run the validation script to ensure compliance before proceeding:
   `python3 scripts/validate-metadata.py --name "[name]" --description "[description]"`
4. If the script returns an error, self-correct the metadata based on the `stderr` output and re-run until successful.

## Step 2: Structure the Directory

1. Create the root directory using the validated `name`.
2. Initialize the following subdirectories:
   - `scripts/`: For tiny CLI tools and deterministic logic.
   - `references/`: For flat (one-level deep) context like schemas or API docs.
   - `assets/`: For output templates, JSON schemas, or static files.
3. Ensure no human-centric files (README.md, INSTALLATION.md) are created.

## Step 3: Draft Core Logic (SKILL.md)

1. Use the template in `assets/SKILL.template.md` as the starting point.
2. Write all instructions in the **third-person imperative** (e.g., "Extract the text," "Run the build").
3. **Enforce progressive disclosure:**
   - Keep the main logic under 500 lines.
   - If a procedure requires a large schema or complex rule set, move it to `references/`.
   - Command the agent to read the specific file only when needed: *"Read `references/api-spec.md` to identify the correct endpoint."*

## Step 4: Identify and Bundle Scripts

1. Identify "fragile" tasks (regex, complex parsing, or repetitive boilerplate).
2. Outline a single-purpose script for the `scripts/` directory.
3. Ensure the script uses standard output (stdout/stderr) to communicate success or failure to the agent.

## Step 5: Final Logic Validation

1. Review the `SKILL.md` for "hallucination gaps" (points where the agent is forced to guess).
2. Verify all file paths are **relative** and use forward slashes (`/`).
3. Cross-reference the final output against `references/checklist.md`.

## Evaluating Existing Skills

When asked to evaluate an existing skill file or directory:

1. Read the skill content in full.
2. Extract `name` and `description` for validation: if the file has YAML frontmatter, use those fields directly. If not, use the first `#` heading as the name (lowercased, spaces replaced with hyphens) and the first non-heading paragraph as the description.
3. Run `scripts/validate-metadata.py --name "[name]" --description "[description]"`.
4. Check each item in `references/checklist.md` — mark Pass/Fail.
5. Identify hallucination gaps: steps where the agent must guess rather than follow a deterministic instruction.
6. Identify missing progressive disclosure: large inline content that should be in `references/`.
7. Output a structured report:
   ```
   SKILL EVALUATION: [name]
   Metadata: Pass/Fail — [issues]
   Structure: Pass/Fail — [issues]
   Logic: Pass/Fail — [gaps or ambiguities]
   Progressive Disclosure: Pass/Fail — [what should move to references/]
   Proposed Changes: [specific edits]
   ```

## Error Handling

- **Metadata failure:** If `scripts/validate-metadata.py` fails, identify the specific error (e.g., "STYLE ERROR") and rewrite the field to remove first/second person pronouns.
- **Context bloat:** If the draft exceeds 500 lines, extract the largest procedural block and move it to a file in `references/`.
