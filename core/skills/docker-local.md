---
name: docker-local
description: Sets up and manages local Docker development environments that are consistent, reproducible, and easy to reset. Use when scaffolding Docker for a new project, writing Dockerfiles or docker-compose configurations, or running and debugging containerised services locally. Don't use for production Docker deployments, Kubernetes manifests, or CI/CD pipeline container configuration.
---

# Docker Local Development

## Project Structure

```
project/
  docker/
    Dockerfile
    Dockerfile.dev              # dev variant with hot reload, debug tools
  docker-compose.yml
  docker-compose.override.yml  # local overrides — gitignored
  .env.example                 # committed, placeholder values only
  .env                         # gitignored, real values
```

## Step 1: Set Up Project Structure

Create the layout above. Confirm `.env` is in `.gitignore` before writing any real values to it.

## Step 2: Write the Dockerfile

- Pin the base image tag — never `FROM python:latest`
- Use multi-stage builds to keep production images lean
- Run as non-root user in production images
- `COPY` only what is needed — use `.dockerignore`
- `CMD` must be the process, not a shell wrapper

```dockerfile
FROM python:3.12-slim AS base
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM base AS production
COPY src/ .
USER nobody
CMD ["python", "-m", "app"]
```

## Step 3: Write docker-compose.yml

Every service must have a named network, `depends_on` with `condition: service_healthy`, and a health check.

```yaml
services:
  app:
    build: .
    environment:
      - DATABASE_URL=${DATABASE_URL}
    depends_on:
      db:
        condition: service_healthy
    networks:
      - app-net

  db:
    image: postgres:16
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5
    networks:
      - app-net

volumes:
  pgdata:

networks:
  app-net:
```

Put local-only overrides in `docker-compose.override.yml` — gitignored.

## Common Commands

```bash
docker compose up -d             # start in background
docker compose logs -f app       # stream logs for one service
docker compose exec app sh       # shell into running container
docker compose down              # stop and remove containers (volumes preserved)
docker compose down -v           # also remove volumes — destructive, confirm first
docker compose build --no-cache  # force rebuild
```

Use `docker compose` (v2) — not `docker-compose` (v1).

## Error Handling

- If a service fails to start, check `docker compose logs -f <service>` before modifying config.
- If a port conflict occurs, check with `lsof -i :<port>` or `ss -tlnp | grep <port>`.
- If `.env` was committed with real values, treat as a CVSS ≥ 7.0 finding and escalate immediately.
