# Docker Swarm Setup Guide

This project uses Docker Swarm for production deployment instead of regular docker compose.

## Why Swarm (on Single Node)?

Even on a single server, Docker Swarm provides:
- **Easy Rollbacks**: Instantly revert to previous version with one command
- **Zero-Downtime Updates**: New container starts before old one stops
- **Auto-Restart**: Services automatically restart if they fail
- **Better Update Control**: More granular control over deployments than compose

## Initial Setup

### 1. Initialize Swarm

```bash
make swarm-init
# or
docker swarm init
```

### 2. Create Overlay Network

The deployment script will create this automatically, but you can also create it manually:

```bash
docker network create --driver overlay --attachable proxy
```

### 3. Prepare Traefik Configuration

Copy your Traefik configuration to /opt/traefik:

```bash
sudo mkdir -p /opt/traefik/dynamic
sudo cp traefik/traefik.yml /opt/traefik/
sudo cp -r traefik/dynamic/* /opt/traefik/dynamic/

# Traefik will create and manage acme.json automatically
sudo touch /opt/traefik/acme.json
sudo chmod 600 /opt/traefik/acme.json
```

### 4. Set Up Docker Secrets

Docker Swarm secrets are encrypted and much more secure than environment variables:

```bash
./setup-secrets.sh
```

This will prompt you for:
- **Flask SECRET_KEY**: Generate with `python -c "import secrets; print(secrets.token_hex(32))"`
- **Cloudflare API Email**: Your Cloudflare account email
- **Cloudflare DNS API Token**: From https://dash.cloudflare.com/profile/api-tokens

Secrets are stored encrypted and only accessible to services that need them.

### 5. Configure Repository

```bash
cp .env.production.example .env.production
# Edit .env.production and set:
# - GITHUB_REPOSITORY=your-username/your-repo
```

## Deployment

### Deploy Stack

```bash
make swarm-deploy
# or
make deploy
```

This will:
1. Pull the latest image from GHCR
2. Deploy the stack
3. Set up Traefik with automatic HTTPS via Cloudflare DNS challenge

### View Status

```bash
make swarm-services   # Show service status
make swarm-ps         # Show running containers/tasks
```

### View Logs

```bash
make swarm-logs-web      # Flask app logs
make swarm-logs-traefik  # Traefik logs
make swarm-logs          # All logs
```

### Scale Services (Optional)

If you ever get more resources, you can scale:

```bash
make swarm-scale REPLICAS=2
# or
docker service scale flask-app_web=2
```

Note: On a single VPS, you typically want to keep replicas=1.

### Update Service

When a new image is pushed to GHCR:

```bash
make swarm-update
# or
./deploy-swarm.sh  # Full redeploy
```

The `swarm-update` command will do a rolling update with zero downtime.

### Rollback Service

If something goes wrong, Docker Swarm keeps the previous version for easy rollback:

```bash
make swarm-rollback
```

This instantly reverts to the previous working version with zero downtime.

### Remove Stack

```bash
make swarm-down
# or
docker stack rm flask-app
```

## File Structure

- `docker-swarm.production.ghcr.yml` - Main production stack file (uses GHCR images)
- `docker-swarm.production.yml` - For local registry deployments
- `docker-compose.development.yml` - Development with regular compose (not swarm)
- `deploy-swarm.sh` - Deployment script
- `Makefile` - Convenient shortcuts

## Configuration Details

### Traefik Service

- Runs on manager node only (`placement.constraints`)
- Ports published in `host` mode for better performance
- Connects to Docker socket to discover services
- Automatically obtains SSL certificates from Let's Encrypt via Cloudflare DNS

### Web Service

- Runs with 1 replica (can scale if needed)
- Rolling updates: zero-downtime deployments
- Restart policy: on-failure with max 3 attempts
- Easy rollback to previous version

### Volumes

Traefik configuration is bind-mounted from `/opt/traefik/`:
- `traefik.yml` - Main configuration
- `dynamic/` - Dynamic configuration files
- `acme.json` - SSL certificates (managed by Traefik)

### Networks

The `proxy` network is an overlay network that allows:
- Communication between services across swarm nodes
- Traefik to discover and route to web services
- Attachable for debugging (can attach standalone containers)

## Development Workflow

1. **Local Development**: Use regular compose
   ```bash
   make dev          # Run Flask locally
   make dev-docker   # Run in Docker
   ```

2. **Commit & Push**: Push to GitHub
   ```bash
   git push origin main
   ```

3. **Wait for Build**: GitHub Actions builds and pushes to GHCR

4. **Deploy to Swarm**: Update production
   ```bash
   make swarm-deploy
   ```

## Troubleshooting

**Stack deployment fails?**
```bash
docker stack ps flask-app --no-trunc
```

**Service not starting?**
```bash
docker service ps flask-app_web --no-trunc
docker service logs flask-app_web
```

**Can't pull GHCR image?**
- Verify package is public on GitHub
- Check GITHUB_REPOSITORY variable in .env.production
- Manually test: `docker pull ghcr.io/username/repo/flask-app:latest`

**Traefik not getting certificates?**
- Check Cloudflare credentials in environment
- Verify DNS API token has correct permissions
- Check Traefik logs: `docker service logs flask-app_traefik`

**Rolling update stuck or failing?**
```bash
make swarm-rollback
# or
docker service rollback flask-app_web
```

## Single-Node Operation

This setup is optimized for single-node deployment. The main benefits are:
- **Rollback capability**: One command to revert bad deployments
- **Zero-downtime updates**: Swarm handles the transition smoothly
- **Service health management**: Automatic restarts and health checks

You don't need multiple servers to benefit from Docker Swarm!

## Useful Commands

```bash
# View all stacks
docker stack ls

# View all services
docker service ls

# Inspect a service
docker service inspect flask-app_web

# Scale multiple services
docker service scale flask-app_web=3 flask-app_traefik=1

# Force update (pull new image)
docker service update --force flask-app_web

# Rollback to previous version
docker service rollback flask-app_web

# View service details
docker service ps flask-app_web

# Execute command in service container
docker exec -it $(docker ps -q -f name=flask-app_web) sh
```
