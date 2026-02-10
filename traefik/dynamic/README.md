# Traefik Dynamic Configuration

This directory contains dynamic configuration files that Traefik watches and reloads automatically without requiring a restart.

## Files

- **middlewares.yml** - HTTP middlewares (security headers, rate limiting, CORS, compression)
- **tls.yml** - TLS/SSL configuration (cipher suites, TLS versions)
- **routes.yml.example** - Example file-based routing (rename to `.yml` to enable)

## How It Works

1. Traefik watches this directory (`watch: true` in [traefik.yml](../traefik.yml))
2. Any `.yml` or `.yaml` file added here is automatically loaded
3. Changes to existing files are detected and applied without restart
4. Files are merged together, so you can organize config however you want

## Adding Custom Configuration

Create a new `.yml` file in this directory:

```yaml
# custom-middleware.yml
http:
  middlewares:
    my-custom-middleware:
      headers:
        customResponseHeaders:
          X-Custom-Header: "My Value"
```

Then reference it in your Docker labels or routes:

```yaml
labels:
  - "traefik.http.routers.myapp.middlewares=my-custom-middleware"
```

## Current Setup

Routes are currently defined via **Docker labels** in [docker-compose.production.yml](../../docker-compose.production.yml). You can optionally define routes here instead by creating a `routes.yml` file (see example file).
