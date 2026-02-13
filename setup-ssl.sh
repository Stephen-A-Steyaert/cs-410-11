#!/bin/bash
# Initial SSL Certificate Setup Script
# Run this once on the server to get your first certificate

set -e

DOMAIN="copper.steyaert.xyz"
EMAIL="savagery2005@gmail.com"

echo "Setting up SSL certificate for $DOMAIN..."

# Create letsencrypt directory if it doesn't exist
sudo mkdir -p /etc/letsencrypt

# Deploy the stack first (without certificates)
make swarm-deploy

# Wait for services to start
echo "Waiting for services to start..."
sleep 10

# Run certbot to get the certificate
docker run --rm \
  -v /etc/letsencrypt:/etc/letsencrypt \
  -v $(docker volume inspect flask-app_certbot-webroot --format '{{.Mountpoint}}'):/var/www/certbot \
  certbot/certbot:latest \
  certonly \
  --webroot \
  -w /var/www/certbot \
  --email $EMAIL \
  --agree-tos \
  --no-eff-email \
  -d $DOMAIN

echo "Certificate obtained! Reloading nginx..."

# Force update nginx to reload with new certificates
docker service update --force flask-app_proxy

echo "SSL setup complete!"
echo ""
echo "To set up automatic renewal, add this to crontab:"
echo "0 3 * * 0 /srv/classproject/renew-certs.sh >> /var/log/cert-renewal.log 2>&1"
