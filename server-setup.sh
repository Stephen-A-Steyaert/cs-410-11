#!/bin/bash
set -e

echo "📦 Setting up server repository..."
echo ""
<<<<<<< HEAD
echo "⚠️  Note: This repository is private and requires authentication."
echo "    Make sure you've set up SSH deploy keys first!"
echo "    See: Setting Up Authentication section in SERVER_SETUP.md"
echo ""

# Configuration
# Note: Using SSH with custom host (requires deploy key setup first)
# See SERVER_SETUP.md for authentication setup instructions
REPO_URL="git@github.com-classproject:stephen-steyaert-odu/cs-410-11.git"
=======
echo "⚠️  Note: This repository is private and requires SSH authentication."
echo "    Make sure you connected with 'ssh -A' to forward your SSH agent."
echo "    Your local SSH key will be used for git operations."
echo ""

# Configuration
# Using SSH - users authenticate via SSH agent forwarding
REPO_URL="git@github.com:stephen-steyaert-odu/cs-410-11.git"
>>>>>>> main
APP_DIR="/srv/classproject"

cd "$APP_DIR"

<<<<<<< HEAD
# Initialize git repository
=======
# Configure git to trust this directory
echo "🔧 Configuring git safe.directory..."
git config --global --add safe.directory "$APP_DIR"

# Initialize git repository if needed
>>>>>>> main
if [ ! -d ".git" ]; then
    echo "🔧 Initializing git repository..."
    git init
    git remote add origin "$REPO_URL"
    echo "📥 Pulling repository..."
    git pull origin main
<<<<<<< HEAD
else
    echo "✅ Repository already initialized"
    echo "📥 Pulling latest changes..."
    git pull origin main
fi

echo ""
echo "✅ Repository setup complete!"
echo ""

=======
    echo ""
    echo "✅ Repository setup complete!"
    echo ""
else
    echo "✅ Repository already initialized"
    echo ""
fi

>>>>>>> main
# Configure git for group sharing
echo "🔧 Configuring repository for group access..."
git config core.sharedRepository group

# Set up group permissions if we have sudo
if command -v sudo &> /dev/null && groups | grep -q classproject; then
    echo "🔧 Setting up group permissions..."
    sudo chgrp -R classproject "$APP_DIR"
    sudo chmod -R g+w "$APP_DIR"
    sudo chmod g+s "$APP_DIR"
    echo "✅ Group permissions configured for 'classproject' group"
fi

echo ""
echo "Files pulled:"
ls -la
echo ""
echo "Next steps:"
echo "1. Initialize swarm: make swarm-init"
echo "2. Set up secrets: make swarm-secrets"
echo "3. Copy environment: cp .env.production.example .env.production"
echo "4. Edit .env.production with your GitHub repository"
echo "5. Deploy: make swarm-deploy"
