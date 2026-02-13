# Docker Swarm Secrets Guide

This project uses Docker Swarm secrets to securely manage sensitive data like API keys and secret keys.

## Why Secrets?

**Docker Secrets** are much more secure than environment variables:
- ✅ Encrypted at rest and in transit
- ✅ Only accessible to services that need them
- ✅ Never appear in `docker inspect` output
- ✅ Never stored in image layers
- ✅ Mounted as files in `/run/secrets/` (not environment variables)

## Setup Secrets

Run this once on your server:

```bash
make swarm-secrets
# or
./setup-secrets.sh
```

You'll be prompted for:
1. **Flask SECRET_KEY** - Generate with: `python -c "import secrets; print(secrets.token_hex(32))"`
2. **Cloudflare API Email** - Your Cloudflare account email
3. **Cloudflare DNS API Token** - From https://dash.cloudflare.com/profile/api-tokens

## Manage Secrets

### View all secrets
```bash
docker secret ls
```

### Inspect a secret (metadata only, value is never shown)
```bash
docker secret inspect flask_secret_key
```

### Remove a secret
```bash
# First, remove services using it
docker stack rm flask-app

# Then remove the secret
docker secret rm flask_secret_key

# Recreate the secret
echo "new-secret-value" | docker secret create flask_secret_key -

# Redeploy
make swarm-deploy
```

### Update a secret

Docker secrets are immutable. To update:

```bash
# 1. Remove the stack
make swarm-down

# 2. Remove old secret
docker secret rm flask_secret_key

# 3. Create new secret
echo "new-value" | docker secret create flask_secret_key -

# 4. Redeploy
make swarm-deploy
```

## Secrets Used

This project uses these secrets:

| Secret Name | Used By | Purpose |
|------------|---------|---------|
| `flask_secret_key` | Web service | Flask session signing |
| `cf_api_email` | Traefik | Cloudflare DNS challenge (SSL) |
| `cf_dns_api_token` | Traefik | Cloudflare DNS challenge (SSL) |

## How It Works

### In Flask (web service)

Secrets are mounted at `/run/secrets/`:

```python
# website/main.py
from pathlib import Path

secret_path = Path('/run/secrets/flask_secret_key')
if secret_path.exists():
    secret_key = secret_path.read_text().strip()
```

The helper function `get_secret()` checks:
1. `/run/secrets/<name>` (Docker secret)
2. Environment variable (fallback for development)
3. Default value

### In Traefik

Traefik reads secrets via `_FILE` suffix environment variables:

```yaml
environment:
  - CF_API_EMAIL_FILE=/run/secrets/cf_api_email
  - CF_DNS_API_TOKEN_FILE=/run/secrets/cf_dns_api_token
```

Traefik automatically reads the file contents.

### In docker-swarm.yml

Services declare which secrets they need:

```yaml
services:
  web:
    secrets:
      - flask_secret_key

secrets:
  flask_secret_key:
    external: true  # Created outside the stack
```

## Troubleshooting

**Secret doesn't exist error?**
```bash
# Check if secrets are created
docker secret ls

# If missing, run setup
./setup-secrets.sh
```

**Service can't access secret?**
```bash
# Verify service has secret mounted
docker service inspect flask-app_web --format '{{json .Spec.TaskTemplate.ContainerSpec.Secrets}}'

# Check secret exists in container
docker exec $(docker ps -q -f name=flask-app_web) ls -la /run/secrets/
```

**Wrong secret value?**
```bash
# Remove stack and secret
make swarm-down
docker secret rm flask_secret_key

# Recreate with correct value
./setup-secrets.sh

# Redeploy
make swarm-deploy
```

## Development vs Production

**Development (local/Docker Compose):**
- Uses environment variables (`.env` files)
- Secrets not available in dev mode
- Falls back to `SECRET_KEY` env var or default

**Production (Docker Swarm):**
- Uses Docker secrets (encrypted)
- No `.env` files needed for secrets
- Mounted securely at `/run/secrets/`

The `get_secret()` function handles both seamlessly!
