# Traefik Setup Instructions

## Prerequisites

1. Domain name pointing to your server
2. Cloudflare account with your domain added

## Setup Steps

### 1. Configure Environment Variables

Edit [.env.traefik](.env.traefik):
- Set your email address
- Add your Cloudflare API token (create at https://dash.cloudflare.com/profile/api-tokens)
  - Token needs `Zone:DNS:Edit` permissions

### 2. Update Configuration

Edit [docker-compose.production.yml](docker-compose.production.yml):
- Replace `yourdomain.com` with your actual domain (lines 22, 32, 33, 49, 53)
- Update email in [traefik/traefik.yml](traefik/traefik.yml) line 23

For the Traefik dashboard password (line 23):
```bash
htpasswd -nb admin your-password
```

### 3. Create Docker Network

```bash
docker network create proxy
```

### 4. Launch Services

```bash
docker-compose -f docker-compose.production.yml up -d
```

## Access Points

- **Your Flask App**: https://yourdomain.com
- **Traefik Dashboard**: https://traefik.yourdomain.com (requires basic auth)

## Dynamic Configuration

Traefik uses dynamic configuration files in [traefik/dynamic/](traefik/dynamic/) that reload automatically:

- **middlewares.yml** - Security headers, rate limiting, CORS, compression
- **tls.yml** - TLS/SSL settings and cipher suites
- **routes.yml.example** - Example for file-based routing (optional)

You can add custom `.yml` files to the dynamic directory and they'll be loaded automatically without restarting Traefik.

## Configuration Details

### Automatic HTTPS
- Uses Let's Encrypt via Cloudflare DNS challenge
- Automatic certificate renewal
- HTTP to HTTPS redirect enabled

### Security Features
- Security headers (HSTS, XSS protection, etc.)
- TLS 1.2+ only
- Modern cipher suites
- Rate limiting middleware available

### Flask App
- Runs on gunicorn with 4 workers
- Exposed internally on port 8000
- Traefik handles SSL termination

## Troubleshooting

Check logs:
```bash
docker-compose -f docker-compose.production.yml logs -f traefik
docker-compose -f docker-compose.production.yml logs -f web
```

Verify certificate:
```bash
cat traefik/acme.json
```
