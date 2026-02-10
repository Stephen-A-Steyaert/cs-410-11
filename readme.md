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
uv run flask run
```

### Production Deployment

See detailed guides:
- [Traefik Setup](TRAEFIK_SETUP.md) - HTTPS reverse proxy configuration
- [GHCR Setup](GHCR_SETUP.md) - Automated Docker builds

## Project Structure

```
.
├── website/              # Flask application
│   ├── Dockerfile       # Production Docker image
│   ├── pyproject.toml   # Python dependencies (uv)
│   └── app.py           # Main Flask app
├── traefik/             # Traefik configuration
│   ├── traefik.yml      # Main Traefik config
│   └── dynamic/         # Dynamic configuration (auto-reload)
│       ├── middlewares.yml
│       ├── tls.yml
│       └── README.md
├── .github/
│   └── workflows/
│       ├── build-and-push.yml    # Auto-build to GHCR
│       └── deploy.yml.example    # Auto-deploy example
├── docker-compose.production.yml       # Local build
├── docker-compose.production.yml.ghcr  # GHCR image
└── deploy.sh            # Deployment helper script
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

Update domains in [docker-compose.production.yml](docker-compose.production.yml):
- `cs.steyaert.xyz` - Flask app
- `traefik.steyaert.xyz` - Traefik dashboard

## Access

- **Flask App**: https://cs.steyaert.xyz
- **Traefik Dashboard**: https://traefik.steyaert.xyz

## Development Workflow

1. Make changes to your Flask app
2. Commit and push to GitHub
3. GitHub Actions builds and pushes to GHCR
4. Run `./deploy.sh` on your server (or set up auto-deploy)

## Security

- Automatic HTTPS via Let's Encrypt
- Security headers (HSTS, XSS protection, etc.)
- TLS 1.2+ only
- Rate limiting available
- Basic auth for Traefik dashboard

## Documentation

- [TRAEFIK_SETUP.md](TRAEFIK_SETUP.md) - Complete Traefik configuration guide
- [GHCR_SETUP.md](GHCR_SETUP.md) - GitHub Container Registry setup
- [traefik/dynamic/README.md](traefik/dynamic/README.md) - Dynamic configuration

## Troubleshooting

View logs:
```bash
docker compose -f docker-compose.production.yml.ghcr logs -f web
docker compose -f docker-compose.production.yml.ghcr logs -f traefik
```

Check GitHub Actions builds:
- Go to repository → Actions tab
