# Personal Context

This file is the highest-leverage input in the baseline. Everything else is generic until this is filled.
Agents read this at session start to calibrate their behavior to you specifically.

**Per-machine overrides:** Create `core/context/personal.local.md` on any machine to add or override
machine-specific details (terminal, editor, primary language, local paths). The `.local.md` file is
gitignored — it stays local, never committed. Agents read it first if it exists.

---

## Identity

- **Location:** Athens, Greece (UTC+3)
- **Role:** Software Engineer — back-end oriented, with cloud/DevOps experience
- **Background:** In the industry since 2016 (~9 years). Core expertise in Java and Python backend. Secondary experience in NodeJS, React, and SCSS. Currently transitioning into agentic engineering.
- **Current focus:** Agentic engineering, security research, AI-driven workflows

---

## Stack

- **Languages:** Python, Java, TypeScript, Groovy
- **Frameworks:** FastAPI, Spring, Spring Boot, React, Grails
- **Databases:** MySQL, MSSQL Server, MongoDB, DynamoDB, Elasticsearch
- **Infrastructure:** Docker, AWS (Lambda, Batch Fargate, API Gateway, S3, DynamoDB, Cognito, SES, ECR, EventBridge, CloudFront), Kubernetes, Terraform
- **Package managers:** pip, npm, nvm, sdkman (Java)

---

## Code Style

- Lean, purposeful code — no unnecessary abstractions
- Comments only when the *why* is non-obvious
- No boilerplate or generated filler
- Match the style already in the project before introducing new conventions
- Commit messages: one line only, no Co-Authored-By section

---

## Communication Style

- Direct, no padding
- No trailing summaries of what was just done
- Short structured output over long prose
- Escalate explicitly, not passively
- Autonomy preferred — ask only when the escalation rules require it

---

## Active Projects

### SoilSerdem — Agricultural Platform
An AWS serverless platform where farmers upload agronomic files and receive processed outputs (management zones, yield data, satellite imagery, soil maps, terrain analysis).

**Architecture:** React SPA → FastAPI Lambda (API Gateway) → AWS Batch Fargate jobs. Event-driven Lambdas handle file lifecycle, orchestration, and real-time WebSocket notifications.

| Repo | Stack |
|---|---|
| api | Python 3.11, FastAPI, Mangum, AWS Lambda |
| frontend-V2 | TypeScript, React 19, Vite 6, Node 20 |
| tools-monorepo | Python 3.9/3.13, AWS Batch Fargate, GDAL/conda |
| LambdaFunctions | Python 3.11/3.12, event-driven Lambdas |
| ADAPT | C# .NET 8, AWS Batch |
| dem_clipper | Python 3.12, GDAL, rasterio |
| cloud-processing-stack | Terraform IaC |

**AWS accounts:** Dev `342895721581` / Prod `359369607705` — both `us-east-2`
**Full architecture reference:** set `SOILSERDEM_HUB` path in `core/context/personal.local.md`

**Critical gotchas:**
- GDAL must be installed via conda — pip install fails
- `soilserdem-utils` must be installed before all other tools-monorepo packages
- remote-sensing module uses Python 3.13 and excludes soilserdem-utils
- API uses `id_token` as Bearer token (not `access_token`)
- DynamoDB table names can be prefixed with `DYNAMODB_TABLE_PREFIX` (e.g. `test-` in CI)

### toptal-zinc
- **Stack:** Grails (Groovy), React

---

## Off-Limits Without Explicit Instruction

- Pushing to any shared or production branch
- Modifying auth, secrets, or access configuration
- Calling AWS APIs or external services
- Installing tools or MCPs not in `tool-registry.md`
- Modifying production AWS infrastructure
