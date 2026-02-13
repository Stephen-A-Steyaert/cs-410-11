# Website for Team Copper

Flask web application with automatic Docker builds to GitHub Container Registry and Traefik reverse proxy for production deployment.

## Features

- **Flask + Gunicorn** - Production-ready WSGI server
- **uv** - Fast Python package management
- **Traefik** - Automatic HTTPS with Let's Encrypt
- **GHCR** - Automated Docker image builds
- **Multi-architecture** - Supports AMD64 and ARM64

## Quick Start

### Local Development

```bash
# Install dependencies with uv
cd website
uv sync

# Run development server
uv run python main.py
```

Visit http://localhost:5000

**Or use Docker for development:**
```bash
docker compose -f docker-compose.development.yml up
```

See [DEVELOPMENT.md](DEVELOPMENT.md) for detailed development guide.

### Production Deployment

See detailed guides:
- [Traefik Setup](TRAEFIK_SETUP.md) - HTTPS reverse proxy configuration
- [GHCR Setup](GHCR_SETUP.md) - Automated Docker builds
- [DEVELOPMENT.md](DEVELOPMENT.md) - Local development guide

## Project Structure

```
.
├── website/                      # Flask application
│   ├── main.py                  # Flask app entry point
│   ├── site_blueprints.py       # Route definitions
│   ├── templates/               # Jinja2 templates
│   ├── static/                  # CSS, JS, images
│   ├── Dockerfile               # Production Docker image
│   └── pyproject.toml           # Python dependencies (uv)
├── traefik/                      # Traefik configuration
│   ├── traefik.yml              # Main Traefik config
│   └── dynamic/                 # Dynamic configuration (auto-reload)
├── .github/workflows/
│   ├── build-and-push.yml       # Auto-build to GHCR
│   └── deploy.yml.example       # Auto-deploy example
├── docker-compose.development.yml       # Development
├── docker-compose.production.yml        # Production (local build)
├── docker-compose.production.ghcr.yml   # Production (GHCR image)
└── deploy.sh                            # Deployment helper script
```

## Deployment Options

### Option 1: Build Locally
```bash
docker compose -f docker-compose.production.yml up -d
```

### Option 2: Use GHCR Images (Recommended)
```bash
# First time setup
cp .env.production.example .env.production
# Edit .env.production with your GitHub username/repo

# Deploy
./deploy.sh
```

## Configuration

### Environment Files

- `.env.traefik` - Cloudflare API credentials
- `.env.production` - GitHub repository info for GHCR

### Domain Configuration

Update domain in swarm files:
- `copper.steyaert.xyz` - Flask app

## Access

- **Flask App**: https://copper.steyaert.xyz

## Development Workflow

**Local Development:**
1. Make changes to your Flask app
2. Flask auto-reloads - just refresh your browser
3. See [DEVELOPMENT.md](DEVELOPMENT.md) for details

**Deployment:**
1. Commit and push to GitHub
2. GitHub Actions builds and pushes to GHCR
3. Run `./deploy.sh` on your server (or set up auto-deploy)

## Security

- **Docker Secrets**: Encrypted storage for API keys and secrets
- **Automatic HTTPS**: Let's Encrypt via Cloudflare DNS challenge
- **Security headers**: HSTS, XSS protection, etc.
- **TLS 1.2+ only**: Modern cipher suites
- **Rate limiting**: Available via Traefik middlewares

## Documentation

- [DEVELOPMENT.md](DEVELOPMENT.md) - Local development guide
- [SWARM_SETUP.md](SWARM_SETUP.md) - Docker Swarm deployment
- [SECRETS.md](SECRETS.md) - Managing Docker secrets
- [TRAEFIK_SETUP.md](TRAEFIK_SETUP.md) - Complete Traefik configuration guide
- [GHCR_SETUP.md](GHCR_SETUP.md) - GitHub Container Registry setup
- [traefik/dynamic/README.md](traefik/dynamic/README.md) - Dynamic configuration

## Troubleshooting

View logs:
```bash
docker compose -f docker-compose.production.ghcr.yml logs -f web
docker compose -f docker-compose.production.ghcr.yml logs -f traefik
```

Check GitHub Actions builds:
- Go to repository → Actions tab
