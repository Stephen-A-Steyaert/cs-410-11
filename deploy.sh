#!/bin/bash
set -e

echo "🚀 Deploying Flask app from GHCR..."

# Configuration
COMPOSE_FILE="docker-compose.production.ghcr.yml"
ENV_FILE=".env.production"

# Check if files exist
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "❌ Error: $COMPOSE_FILE not found"
    exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: $ENV_FILE not found"
    echo "Copy .env.production.example to .env.production and configure it"
    exit 1
fi

# Pull latest image
echo "📦 Pulling latest image..."
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" pull web

# Restart the web service
echo "🔄 Restarting web service..."
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d web

# Clean up old images
echo "🧹 Cleaning up old images..."
docker image prune -f

# Show status
echo ""
echo "✅ Deployment complete!"
echo ""
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" ps web
