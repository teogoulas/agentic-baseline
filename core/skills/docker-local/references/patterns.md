# Docker Local Development Patterns

## Project Structure

```
project/
  docker/
    Dockerfile
    Dockerfile.dev          # dev variant with hot reload, debug tools
  docker-compose.yml
  docker-compose.override.yml   # local overrides — gitignored
  .env.example              # committed, placeholder values only
  .env                      # gitignored, real values
```

## Dockerfile — Multi-Stage Build

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

Rules:
- Pin base image tags — never `FROM python:latest`
- Use multi-stage builds to keep production images lean
- Run as non-root user in production images
- `COPY` only what is needed — use `.dockerignore`
- `CMD` must be the process, not a shell script wrapping it

## docker-compose.yml Skeleton

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

## Common Commands

```bash
docker compose up -d             # start in background
docker compose logs -f app       # stream logs for one service
docker compose exec app sh       # shell into running container
docker compose down              # stop and remove containers (volumes preserved)
docker compose down -v           # stop and remove containers + volumes (full reset — destructive)
docker compose build --no-cache  # force rebuild
```

## Rules

- Never commit `.env` — only `.env.example` with placeholder values
- `docker compose down -v` deletes volumes — always confirm before running
- Use `override.yml` for local-only config so the base `docker-compose.yml` works everywhere
- Use `docker compose` (v2) — not `docker-compose` (v1)
