# GitHub Container Registry Setup

This project automatically builds and pushes Docker images to GitHub Container Registry (ghcr.io) using GitHub Actions.

## How It Works

1. **Automatic builds** - When you push to `main` or changes in `website/`, GitHub Actions builds the Docker image
2. **Multi-architecture** - Builds for both `linux/amd64` and `linux/arm64`
3. **Caching** - Uses GitHub Actions cache to speed up builds
4. **Versioning** - Creates tags:
   - `latest` - Latest main branch build
   - `main-<sha>` - Specific commit SHA
   - `main` - Latest from main branch

## Architecture

- **Application code** - Lives in `website/` folder, built into Docker images via GitHub Actions
- **Infrastructure code** - Lives in repository (nginx, docker-swarm configs, scripts), pulled to server via git
- **Deployment** - Docker Swarm pulls images from GHCR and runs them with nginx reverse proxy

The `website/` folder is **excluded** from server git checkouts using sparse-checkout. Application updates come through GHCR, not git.

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

On your production server:

```bash
cd /srv/classproject

# Copy and configure environment
cp .env.production.example .env.production
nano .env.production  # Set GITHUB_REPOSITORY=your-username/your-repo-name
```

### 3. Initialize Docker Swarm

```bash
make swarm-init
```

### 4. Get SSL Certificate

```bash
chmod +x setup-ssl.sh
./setup-ssl.sh
```

This will:
- Deploy the stack
- Obtain SSL certificate from Let's Encrypt via HTTP challenge
- Configure automatic renewal

### 5. Set Up Automatic Certificate Renewal (Optional)

```bash
sudo crontab -e
# Add this line:
0 3 * * 0 /srv/classproject/renew-certs.sh >> /var/log/cert-renewal.log 2>&1
```

## Development Workflow

### Making Changes to the Flask App

1. **Edit code locally** in the `website/` folder
2. **Commit and push**:
   ```bash
   git add website/
   git commit -m "Update Flask app"
   git push origin main
   ```
3. **GitHub Actions builds automatically** (check Actions tab)
4. **Deploy to server**:
   ```bash
   ssh user@your-server
   cd /srv/classproject
   make swarm-update
   ```

The `make swarm-update` command:
- Pulls the latest image from GHCR
- Performs a rolling update (zero downtime)
- Old containers stay running until new ones are healthy

### Making Infrastructure Changes

Infrastructure files (nginx config, docker-swarm.yml, scripts):

1. **Edit files** in repository (everything except `website/`)
2. **Push to GitHub**:
   ```bash
   git push origin main
   ```
3. **On server, pull infrastructure updates**:
   ```bash
   cd /srv/classproject
   git pull origin main  # Only pulls infrastructure files
   make swarm-deploy     # Redeploy with new config
   ```

## Deployment Commands

```bash
# Update application (pull new GHCR image)
make swarm-update

# Full redeploy (infrastructure + application)
make swarm-deploy

# Rollback to previous version
make swarm-rollback

# View service status
docker service ls
docker service ps flask-app_web
docker service ps flask-app_proxy

# View logs
docker service logs flask-app_web --tail 50 --follow
docker service logs flask-app_proxy --tail 50 --follow
```

## Automatic Deployment (Optional)

Set up automatic deployment using GitHub Actions. See [.github/workflows/deploy.yml.example](.github/workflows/deploy.yml.example):

1. Generate SSH key for GitHub Actions:
   ```bash
   ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/deploy_key
   cat ~/.ssh/deploy_key.pub >> ~/.ssh/authorized_keys
   ```

2. Add secrets to GitHub repo (Settings → Secrets → Actions):
   - `DEPLOY_HOST`: Your server IP/domain
   - `DEPLOY_USER`: SSH username
   - `DEPLOY_SSH_KEY`: Contents of `~/.ssh/deploy_key` (private key)

3. Copy and enable the workflow:
   ```bash
   cp .github/workflows/deploy.yml.example .github/workflows/deploy.yml
   git add .github/workflows/deploy.yml
   git commit -m "Enable automatic deployment"
   git push
   ```

Now every push to `main` will automatically:
1. Build Docker image
2. Push to GHCR
3. SSH to server and run `make swarm-update`

## Manual Build

To manually trigger a build without pushing code:

1. Go to your repository on GitHub
2. Click "Actions" tab
3. Select "Build and Push to GHCR" workflow
4. Click "Run workflow" → "Run workflow"

## Authentication for Private Repositories

If your GHCR package is private, authenticate on the server:

```bash
# Create personal access token at https://github.com/settings/tokens
# Needs: read:packages scope

echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

Then Docker Swarm will be able to pull private images.

## Services Architecture

- **web** - Flask application (from GHCR)
- **proxy** - Nginx reverse proxy (handles SSL, proxies to web)
- **certbot** - SSL certificate renewal (runs on-demand)

All services run on the `proxy` overlay network. Only nginx exposes ports 80/443 to the host.

## Troubleshooting

**Build failing?**
- Check the Actions tab for error logs
- Verify Dockerfile builds locally: `docker build -t test ./website`
- Check that `website/pyproject.toml` dependencies are correct

**Can't pull image?**
- Verify package is public (or you're authenticated)
- Check image name in `.env.production` matches: `username/repo-name`
- Try: `docker pull ghcr.io/username/repo-name/flask-app:latest`

**Service not starting?**
- Check service logs: `docker service logs flask-app_web --tail 50`
- Check service details: `docker service ps flask-app_web --no-trunc`
- Verify secrets exist: `docker secret ls`

**SSL certificate issues?**
- Verify domain points to server IP
- Check nginx logs: `docker service logs flask-app_proxy`
- Manually renew: `./setup-ssl.sh`
- Check certificate: `sudo ls -la /etc/letsencrypt/live/copper.steyaert.xyz/`

**Updates not deploying?**
- Verify image was built: Check GitHub Actions
- Force pull: `docker service update --force --image ghcr.io/username/repo-name/flask-app:latest flask-app_web`
- Check current image: `docker service ps flask-app_web`
