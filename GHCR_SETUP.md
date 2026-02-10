# GitHub Container Registry Setup

This project automatically builds and pushes Docker images to GitHub Container Registry (ghcr.io) using GitHub Actions.

## How It Works

1. **Automatic builds** - When you push to `main`/`master` or changes in `website/`, GitHub Actions builds the Docker image
2. **Multi-architecture** - Builds for both `linux/amd64` and `linux/arm64`
3. **Caching** - Uses GitHub Actions cache to speed up builds
4. **Versioning** - Creates tags:
   - `latest` - Latest main/master branch build
   - `main-<sha>` - Specific commit SHA
   - `main` - Latest from main branch

## Initial Setup

### 1. Make GHCR Package Public (One-time)

After your first push/build:

1. Go to your GitHub repository
2. Click "Packages" on the right sidebar
3. Click on your `flask-app` package
4. Click "Package settings"
5. Scroll to "Danger Zone"
6. Click "Change visibility" → Make public

### 2. Configure Production Server

On your production server, create `.env.production`:

```bash
cp .env.production.example .env.production
```

Edit `.env.production` and set your repository name:
```bash
GITHUB_REPOSITORY=your-username/your-repo-name
```

### 3. Deploy Using GHCR Image

Use the GHCR-specific compose file:

```bash
# Pull latest image
docker compose -f docker-compose.production.ghcr.yml --env-file .env.production pull web

# Start services
docker compose -f docker-compose.production.ghcr.yml --env-file .env.production up -d
```

## Development Workflow

### Local Development
Use the regular compose file that builds locally:
```bash
docker-compose -f docker-compose.production.yml up -d
```

### Production Deployment
```bash
# 1. Push code to GitHub
git push origin main

# 2. Wait for GitHub Actions to build (check Actions tab)

# 3. On server, pull and restart
docker compose -f docker-compose.production.ghcr.yml --env-file .env.production pull web
docker compose -f docker-compose.production.ghcr.yml --env-file .env.production up -d web
```

## Automatic Deployment (Optional)

You can set up automatic deployment using:

1. **Watchtower** - Automatically pulls new images and restarts containers
2. **GitHub Actions Deploy** - SSH into server and run deploy commands
3. **Webhook** - Trigger deployment on push

Example Watchtower setup:
```bash
docker run -d \
  --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  flask-app \
  --interval 300
```

## Manual Build

To manually trigger a build without pushing code:

1. Go to your repository on GitHub
2. Click "Actions" tab
3. Select "Build and Push to GHCR" workflow
4. Click "Run workflow" → "Run workflow"

## Authentication for Private Repositories

If your repository is private, you need to authenticate on the server:

```bash
# Create personal access token at https://github.com/settings/tokens
# Needs: read:packages scope

echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

## Troubleshooting

**Build failing?**
- Check the Actions tab for error logs
- Verify Dockerfile builds locally: `docker build -t test ./website`

**Can't pull image?**
- Verify package is public (or you're authenticated)
- Check image name matches: `ghcr.io/username/repo-name/flask-app:latest`

**Old image running?**
- Force pull: `docker compose ... pull --force web`
- Remove old container: `docker rm -f flask-app`
