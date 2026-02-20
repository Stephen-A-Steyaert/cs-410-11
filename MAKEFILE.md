# Makefile Commands

This project uses a Makefile to simplify common development and deployment tasks. Run `make help` to see all available commands.

## Quick Reference

```bash
make help         # Show all available commands
make dev          # Run Flask development server locally
make dev-docker   # Run Flask in Docker for development
make install      # Install Python dependencies
make deploy       # Deploy latest image to production
make logs         # View production logs
make clean        # Clean up Python cache and Docker resources
```

## Development Commands

### `make dev`
Run Flask development server locally (fastest iteration).

```bash
make dev
```

This runs Flask directly on your machine with hot reload enabled. Visit http://localhost:5000

### `make dev-docker`
Run Flask in Docker for development.

```bash
make dev-docker
```

This uses [docker-compose.development.yml](docker-compose.development.yml) to run Flask in a container with volume mounts for live code reload.

### `make install`
Install Python dependencies using uv.

```bash
make install
```

Equivalent to:
```bash
cd website && uv sync
```

### `make sync`
Sync dependencies to lock file.

```bash
make sync
```

Use this after manually editing pyproject.toml to update the lock file.

### `make add`
Add a new Python dependency.

```bash
make add PACKAGE=flask-cors
```

This adds the package to pyproject.toml and installs it.

### `make test`
Run tests (when implemented).

```bash
make test
```

Runs pytest in the website directory.

## Production Commands

### `make deploy`
Deploy the latest image from GHCR to production.

```bash
make deploy
```

This command:
1. Pulls the latest image from GitHub Container Registry
2. Updates running containers with the new image
3. Cleans up old Docker images

Alias for `make compose-deploy`.

### `make compose-deploy`
Same as `make deploy` - pulls and deploys the latest image.

```bash
make compose-deploy
```

### `make compose-up`
Start or update production services.

```bash
make compose-up
```

Pulls the latest web image and updates the running container. Useful for deploying after a new build.

### `make compose-down`
Stop and remove production services.

```bash
make compose-down
```

Stops all containers defined in [docker-compose.production.ghcr.yml](docker-compose.production.ghcr.yml).

### `make compose-restart`
Restart production services without pulling new images.

```bash
make compose-restart
```

### `make logs`
View logs from production containers.

```bash
make logs
```

Shows live logs from the production environment. Press Ctrl+C to exit.

Alias for `make compose-logs`.

## Utility Commands

### `make clean`
Clean up Python cache files and Docker resources.

```bash
make clean
```

This command:
- Removes all `__pycache__` directories
- Deletes `.pyc` files
- Runs `docker system prune -f` to clean up unused Docker resources

### `make help`
Show all available commands with descriptions.

```bash
make help
```

## Environment Configuration

Most production commands require `.env.production` to be configured:

```bash
# Create from example
cp .env.production.example .env.production

# Edit with your GitHub repository info
# GITHUB_REPOSITORY=yourusername/yourrepo
```

## Command Details

### Development vs Production

**Development commands** (`make dev`, `make dev-docker`):
- Use development configuration
- Enable debug mode and hot reload
- Run on http://localhost:5001
- Don't require GHCR authentication

**Production commands** (`make deploy`, `make compose-up`, etc.):
- Use [docker-compose.production.ghcr.yml](docker-compose.production.ghcr.yml)
- Pull images from GitHub Container Registry
- Require `.env.production` configuration
- Run with nginx-proxy for HTTPS

### Common Workflows

**Local development:**
```bash
make install
make dev
# Make changes, Flask auto-reloads
```

**Adding a dependency:**
```bash
make add PACKAGE=requests
# Package is added and installed
```

**Deploying to production:**
```bash
# Push code to GitHub
git push origin main

# On production server after GitHub Actions builds
make deploy
```

**Troubleshooting production:**
```bash
make logs          # View logs
make compose-down  # Stop services
make deploy        # Redeploy
```

## Implementation

The Makefile uses standard Make syntax. Each target has a comment that's displayed by `make help`:

```makefile
dev: ## Run Flask development server locally
	cd website && uv run python main.py
```

Production commands use the `.env.production` file for configuration and automatically export those variables.

## See Also

- [readme.md](readme.md) - Project overview and quick start
- [DEVELOPMENT.md](DEVELOPMENT.md) - Detailed development guide
- [Makefile](Makefile) - Source Makefile with all command definitions
