#!/bin/bash
set -e

echo "🚀 Deploying Flask app to Docker Swarm from GHCR..."

# Configuration
STACK_NAME="flask-app"
COMPOSE_FILE="docker-swarm.production.ghcr.yml"
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

# Check if swarm is initialized
if ! docker info | grep -q "Swarm: active"; then
    echo "❌ Error: Docker Swarm is not initialized"
    echo "Run: docker swarm init"
    exit 1
fi

# Check if secrets exist
REQUIRED_SECRETS=("flask_secret_key")
MISSING_SECRETS=()

for secret in "${REQUIRED_SECRETS[@]}"; do
    if ! docker secret ls --format '{{.Name}}' | grep -q "^${secret}$"; then
        MISSING_SECRETS+=("$secret")
    fi
done

if [ ${#MISSING_SECRETS[@]} -ne 0 ]; then
    echo "❌ Error: Missing required secrets: ${MISSING_SECRETS[*]}"
    echo "Run: ./setup-secrets.sh"
    exit 1
fi

# Create network if it doesn't exist
if ! docker network ls | grep -q proxy; then
    echo "📡 Creating overlay network 'proxy'..."
    docker network create --driver overlay --attachable proxy
fi

# Create required directories on the swarm manager
echo "📁 Creating required directories..."
sudo mkdir -p /opt/traefik/dynamic
# Create empty acme.json with proper permissions - Traefik will populate it
if [ ! -f /opt/traefik/acme.json ]; then
    sudo touch /opt/traefik/acme.json
    sudo chmod 600 /opt/traefik/acme.json
fi

# Copy traefik config files to /opt/traefik
echo "📋 Copying Traefik configuration..."
sudo cp traefik/traefik.yml /opt/traefik/
sudo cp -r traefik/dynamic/* /opt/traefik/dynamic/ 2>/dev/null || true

# Load environment variables
export $(grep -v '^#' $ENV_FILE | xargs)

# Pull latest image
echo "📦 Pulling latest image..."
docker pull "ghcr.io/${GITHUB_REPOSITORY}/flask-app:latest"

# Deploy stack
echo "🚢 Deploying stack '$STACK_NAME'..."
docker stack deploy --compose-file "$COMPOSE_FILE" --with-registry-auth "$STACK_NAME"

# Wait a moment for services to start
sleep 5

# Show status
echo ""
echo "✅ Deployment complete!"
echo ""
echo "Stack services:"
docker stack services "$STACK_NAME"
echo ""
echo "To view logs:"
echo "  docker service logs ${STACK_NAME}_web -f"
echo "  docker service logs ${STACK_NAME}_traefik -f"
echo ""
echo "To scale the web service:"
echo "  docker service scale ${STACK_NAME}_web=3"
