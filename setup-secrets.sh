#!/bin/bash
set -e

echo "🔐 Setting up Docker Swarm secrets..."

# Check if swarm is initialized
if ! docker info | grep -q "Swarm: active"; then
    echo "❌ Error: Docker Swarm is not initialized"
    echo "Run: make swarm-init"
    exit 1
fi

# Function to create or update a secret
create_secret() {
    local secret_name=$1
    local secret_value=$2

    # Check if secret already exists
    if docker secret ls --format '{{.Name}}' | grep -q "^${secret_name}$"; then
        echo "⚠️  Secret '${secret_name}' already exists. Skipping..."
        echo "   To update, remove it first: docker secret rm ${secret_name}"
    else
        echo "✅ Creating secret: ${secret_name}"
        echo "$secret_value" | docker secret create "${secret_name}" -
    fi
}

# Prompt for Flask secret key
echo ""
echo "📝 Flask Secret Key"
echo "Generate one with: python -c \"import secrets; print(secrets.token_hex(32))\""
read -p "Enter Flask SECRET_KEY: " -s FLASK_SECRET_KEY
echo ""
create_secret "flask_secret_key" "$FLASK_SECRET_KEY"

# Prompt for Cloudflare API email
echo ""
echo "📧 Cloudflare API Email"
read -p "Enter Cloudflare email: " CF_EMAIL
create_secret "cf_api_email" "$CF_EMAIL"

# Prompt for Cloudflare DNS API token
echo ""
echo "🔑 Cloudflare DNS API Token"
echo "Get this from: https://dash.cloudflare.com/profile/api-tokens"
echo "Needs: Zone.DNS.Edit permission"
read -p "Enter Cloudflare DNS API token: " -s CF_TOKEN
echo ""
create_secret "cf_dns_api_token" "$CF_TOKEN"

echo ""
echo "✅ Secrets setup complete!"
echo ""
echo "View secrets:"
echo "  docker secret ls"
echo ""
echo "Remove a secret:"
echo "  docker secret rm <secret-name>"
echo ""
echo "Note: Secrets are encrypted and only accessible to services that use them"
