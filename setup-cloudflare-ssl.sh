#!/bin/bash
# Cloudflare Origin Certificate Setup Script
# Run this once on the server to install Cloudflare Origin Certificates

set -e

DOMAIN="copper.steyaert.xyz"
SSL_DIR="/srv/classproject/ssl"

echo "Setting up Cloudflare Origin SSL certificate for $DOMAIN..."
echo ""
echo "Instructions:"
echo "1. Go to Cloudflare Dashboard → SSL/TLS → Origin Server"
echo "2. Click 'Create Certificate'"
echo "3. Keep default settings (RSA, 15 years)"
echo "4. Copy the certificate and private key"
echo ""

# Create SSL directory
echo "Creating SSL directory..."
sudo mkdir -p "$SSL_DIR"

# Get certificate from user
echo ""
echo "Paste the Origin Certificate (including -----BEGIN CERTIFICATE----- and -----END CERTIFICATE-----):"
echo "Press Ctrl+D when done:"
sudo tee "$SSL_DIR/cert.pem" > /dev/null

echo ""
echo "Paste the Private Key (including -----BEGIN PRIVATE KEY----- and -----END PRIVATE KEY-----):"
echo "Press Ctrl+D when done:"
sudo tee "$SSL_DIR/key.pem" > /dev/null

# Set permissions
echo ""
echo "Setting permissions..."
sudo chmod 644 "$SSL_DIR/cert.pem"
sudo chmod 600 "$SSL_DIR/key.pem"
sudo chown root:root "$SSL_DIR"/*.pem

echo ""
echo "✅ Cloudflare Origin Certificate installed!"
echo ""
echo "Certificate files:"
ls -la "$SSL_DIR"
echo ""
echo "Next steps:"
echo "1. In Cloudflare: Set SSL/TLS mode to 'Full (strict)'"
echo "2. Deploy the stack: make swarm-deploy"
echo "3. Test: https://$DOMAIN/example"
