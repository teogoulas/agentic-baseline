# Docker Local Development

Patterns for running services locally with Docker in a way that is consistent, reproducible, and easy to reset.

---

## Project Structure

```
project/
  docker/
    Dockerfile
    Dockerfile.dev        # dev variant with hot reload, debug tools
  docker-compose.yml
  docker-compose.override.yml   # local overrides — gitignored
  .env.example           # committed, no real values
  .env                   # not committed, real values
```

---

## Dockerfile Guidelines

- Pin base image tags — never `FROM python:latest`
- Use multi-stage builds to keep production images lean
- Run as non-root user in production images
- `COPY` only what is needed — use `.dockerignore`
- `CMD` should be the process, not a shell script wrapping it

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

---

## docker-compose.yml Patterns

- Define a named network — never use the default bridge
- Mount volumes for persistent data (databases, uploads)
- Use `depends_on` with `condition: service_healthy` for startup order
- Define health checks on all services

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

---

## Common Commands

```bash
docker compose up -d          # start in background
docker compose logs -f app    # stream logs for one service
docker compose exec app sh    # shell into running container
docker compose down           # stop and remove containers
docker compose down -v        # also remove volumes (full reset)
docker compose build --no-cache  # force rebuild
```

---

## Rules

- Never commit `.env` — only `.env.example` with placeholder values
- `docker compose down -v` is destructive (deletes volumes) — confirm before running
- Use `override.yml` for local-only config so the base `docker-compose.yml` works everywhere
- Avoid `docker-compose` (v1) — use `docker compose` (v2)
