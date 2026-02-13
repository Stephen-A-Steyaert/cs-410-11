#!/bin/bash
# SSL Certificate Renewal Script
# Run this via cron: 0 3 * * 0 /srv/classproject/renew-certs.sh

set -e

cd /srv/classproject

echo "$(date): Attempting certificate renewal..."

# Scale certbot service to 1 to run renewal
docker service scale flask-app_certbot=1

# Wait for renewal to complete
sleep 30

# Scale back down
docker service scale flask-app_certbot=0

# Reload nginx to pick up new certificates
docker service update --force flask-app_proxy

echo "$(date): Certificate renewal complete"
