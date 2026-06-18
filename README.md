# Catchup Chat Backend

JSON API backend for Catchup Chat, built with [Phoenix](https://www.phoenixframework.org/) and PostgreSQL.

## Prerequisites

- [Elixir](https://elixir-lang.org/install.html) 1.15+
- [Erlang/OTP](https://www.erlang.org/downloads) 26+
- [Docker](https://www.docker.com/) (for the local database)

## First-time setup

### 1. Clone the repository

```bash
git clone <repository-url>
cd catchup_chat_backend
```

### 2. Configure environment variables

```bash
cp .env.example .env
```

Edit `.env` if you need to change the database credentials. Defaults:

| Variable            | Default                    |
|---------------------|----------------------------|
| `POSTGRES_USER`     | `postgres`                 |
| `POSTGRES_PASSWORD` | `your_password_here`       |
| `POSTGRES_HOST`     | `localhost`                |
| `POSTGRES_PORT`     | `5432`                     |
| `POSTGRES_DB`       | `catchup_chat_db_postgres` |
| `POSTGRES_TEST_DB`  | `catchup_chat_backend_test`|

`.env` is gitignored. Commit `.env.example` only.

### 3. Start the database

```bash
mix db.up
```

This runs PostgreSQL in Docker using credentials from `.env`.

> If you already have a Postgres container on port 5432, stop it first:
> `docker stop catchup_chat_db_postgres`

#### Migrating from a manually created container

Docker Compose cannot adopt an existing container, but it **can reuse the same data volume**. Your database files live in the volume, not the container.

1. Find your existing volume name:

```bash
docker inspect catchup_chat_db_postgres --format '{{range .Mounts}}{{.Name}}{{end}}'
```

2. Remove only the old container (this keeps the volume):

```bash
docker rm catchup_chat_db_postgres
```

3. Create a local override file:

```bash
cp docker-compose.override.yml.example docker-compose.override.yml
```

4. Edit `docker-compose.override.yml` and replace `EXISTING_VOLUME_NAME` with the volume name from step 1.

5. Start with Compose:

```bash
mix db.up
```

Compose will create a new container with the same name, image, and **your existing data**.

`docker-compose.override.yml` is gitignored — it is for your machine only.

### 4. Install dependencies and set up the database

```bash
mix setup
```

This will:

- Fetch Elixir dependencies
- Create the database
- Run migrations
- Run seeds (if any)

### 5. Start the server

```bash
mix phx.server
```

The API is available at **http://localhost:4000**.

## API endpoints

### Public

| Method | Path                  | Description              |
|--------|-----------------------|--------------------------|
| POST   | `/api/users/register` | Register a new user      |
| POST   | `/api/users/log-in`   | Log in and receive token |

### Authenticated

Requires header: `Authorization: Bearer <token>`

| Method | Path                  | Description              |
|--------|-----------------------|--------------------------|
| GET    | `/api/users/me`       | Get current user         |
| DELETE | `/api/users/log-out`  | Revoke session token     |

### Example: register

```bash
curl -X POST http://localhost:4000/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "you@example.com",
    "password": "password123",
    "name": "Alice",
    "last_coordinates": {"lat": 1.0, "lng": 2.0}
  }'
```

Response:

```json
{
  "data": {
    "id": 1,
    "email": "you@example.com",
    "name": "Alice",
    "last_coordinates": {"lat": 1.0, "lng": 2.0},
    "is_admin": false
  },
  "token": "..."
}
```

`name` and `last_coordinates` are optional. `last_coordinate` is also accepted as an alias for `last_coordinates`.

### Example: authenticated request

```bash
curl http://localhost:4000/api/users/me \
  -H "Authorization: Bearer <token>"
```

## Useful commands

| Command          | Description                          |
|------------------|--------------------------------------|
| `mix db.up`      | Start the Postgres container         |
| `mix db.down`    | Stop the Postgres container          |
| `mix db.logs`    | Tail Postgres logs                   |
| `mix phx.server` | Start the API server                 |
| `mix test`       | Run tests                            |
| `mix ecto.migrate` | Run pending migrations             |
| `mix ecto.reset` | Drop, recreate, and migrate the DB   |
| `mix precommit`  | Format, compile, and run tests       |

## Running tests

Make sure Docker is running, then:

```bash
mix db.up
mix test
```

## Project structure

```
lib/
  catchup_chat_backend/          # Business logic (contexts, schemas)
    accounts/                    # User auth and tokens
  catchup_chat_backend_web/      # API layer (controllers, plugs, router)
config/                          # Environment configuration
priv/repo/migrations/            # Database migrations
docker-compose.yml               # Local Postgres setup
.env.example                     # Environment variable template
```

## Production

Production secrets (`DATABASE_URL`, `SECRET_KEY_BASE`, etc.) are read from environment variables via `config/runtime.exs` — they are not hardcoded in the repo.

See the [Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html) when you're ready to host.
