---
name: docker-local
description: Sets up and manages local Docker development environments that are consistent, reproducible, and easy to reset. Use when scaffolding Docker for a new project, writing Dockerfiles or docker-compose configurations, or running and debugging containerised services locally. Don't use for production Docker deployments, Kubernetes manifests, or CI/CD pipeline container configuration.
---

# Docker Local Development

## Step 1: Set Up Project Structure

Read `references/patterns.md` for the standard directory layout.

Create:
- `docker/Dockerfile` (and `docker/Dockerfile.dev` if hot reload is needed)
- `docker-compose.yml`
- `.env.example` — committed, placeholder values only
- `.env` — gitignored, real values

Confirm `.env` is in `.gitignore` before writing any real values to it.

## Step 2: Write the Dockerfile

Read `references/patterns.md` for Dockerfile guidelines and the multi-stage build pattern.

Rules:
- Pin the base image tag — never `FROM python:latest`
- Use multi-stage builds to keep production images lean
- Run as non-root user in production images
- `COPY` only what is needed — use `.dockerignore`
- `CMD` must be the process, not a shell wrapper

## Step 3: Write docker-compose.yml

Read `references/patterns.md` for the compose skeleton.

Every service must have:
- Named network (never the default bridge)
- `depends_on` with `condition: service_healthy` for startup ordering
- Health check defined

Mount volumes for persistent data (databases, uploads).
Put local-only overrides in `docker-compose.override.yml` — gitignored.

## Step 4: Run and Manage

Use the commands in `references/patterns.md`.

When resetting the environment:
- `docker compose down` — stops and removes containers (data preserved in volumes)
- `docker compose down -v` — also removes volumes (full reset, **destructive** — confirm before running)

## Error Handling

- If a service fails to start, check `docker compose logs -f <service>` before modifying config.
- If a port conflict occurs, check what is bound with `lsof -i :<port>` or `ss -tlnp | grep <port>`.
- If `.env` was committed with real values, treat as a CVSS ≥ 7.0 finding and escalate immediately.
