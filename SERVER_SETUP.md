# Server Setup Guide

This guide shows how to set up your server repository.

## Prerequisites

Since this is a **private repository**, you must set up authentication before pulling files. See the "Setting Up Authentication" section below.

## Automated Setup (Recommended)

**First**, set up authentication (see below), **then** run this script:

```bash
# Download and run the setup script
curl -O https://raw.githubusercontent.com/stephen-steyaert-odu/cs-410-11/main/server-setup.sh
chmod +x server-setup.sh
./server-setup.sh
```

This will:
1. Initialize git repository in `/srv/classproject`
2. Pull all files from the repository
3. Configure for group access

## Manual Setup

**First**, set up authentication using one of the methods above (SSH deploy key recommended).

**Then**, initialize the repository:

```bash
cd /srv/classproject
git init
git remote add origin git@github.com-classproject:stephen-steyaert-odu/cs-410-11.git
git pull origin main

# Configure for group sharing
git config core.sharedRepository group

# Set group permissions (if you have sudo)
sudo chgrp -R classproject /srv/classproject
sudo chmod -R g+w /srv/classproject
sudo chmod g+s /srv/classproject
```

## Setting Up Authentication for Private Repository

Since the repository is private, you need to set up authentication. The best approach for group access is using SSH with a shared deploy key.

### Option 1: SSH Deploy Key (Recommended for Group Access)

```bash
# 1. Generate a deploy key (do this once)
ssh-keygen -t ed25519 -C "classproject-deploy" -f ~/.ssh/classproject_deploy
# Press Enter for no passphrase (allows automated pulls)

# 2. Add the public key to GitHub
cat ~/.ssh/classproject_deploy.pub
# Copy this and add it to: GitHub repo → Settings → Deploy keys → Add deploy key
# ✓ Check "Allow write access" if you want to push from the server

# 3. Move the key to a shared location
sudo mkdir -p /etc/ssh/deploy_keys
sudo mv ~/.ssh/classproject_deploy /etc/ssh/deploy_keys/
sudo mv ~/.ssh/classproject_deploy.pub /etc/ssh/deploy_keys/
sudo chmod 600 /etc/ssh/deploy_keys/classproject_deploy
sudo chgrp classproject /etc/ssh/deploy_keys/classproject_deploy
sudo chmod 640 /etc/ssh/deploy_keys/classproject_deploy

# 4. Configure SSH for the group
sudo tee /etc/ssh/ssh_config.d/classproject.conf <<EOF
Host github.com-classproject
    HostName github.com
    User git
    IdentityFile /etc/ssh/deploy_keys/classproject_deploy
    IdentitiesOnly yes
EOF

# 5. Update git remote to use SSH
cd /srv/classproject
git remote set-url origin git@github.com-classproject:stephen-steyaert-odu/cs-410-11.git
```


## Setting Up Group Access

To allow all users in the `classproject` group to pull updates:

```bash
# Set group ownership on the directory
sudo chgrp -R classproject /srv/classproject

# Set group write permissions so anyone in the group can pull
sudo chmod -R g+w /srv/classproject

# Make new files inherit the group
sudo chmod g+s /srv/classproject

# Configure git to share the repository with the group
cd /srv/classproject
git config core.sharedRepository group
```

Now any user in the `classproject` group can pull updates using the shared credentials.

## Updating Server Files

When you or anyone in the `classproject` group wants to update:

```bash
cd /srv/classproject
git pull origin main
```

The authentication will use the shared deploy key (SSH)

## Complete Deployment Flow

### On Server (One-time Setup)

```bash
# 0. Set up SSH deploy key authentication (see "Setting Up Authentication" above)

# 1. Pull infrastructure files
./server-setup.sh

# 2. Initialize swarm
cd /srv/classproject
make swarm-init

# 3. Set up Traefik config
sudo mkdir -p /opt/traefik/dynamic
sudo cp traefik/traefik.yml /opt/traefik/
sudo cp -r traefik/dynamic/* /opt/traefik/dynamic/
sudo touch /opt/traefik/acme.json
sudo chmod 600 /opt/traefik/acme.json

# 4. Set up secrets
make swarm-secrets

# 5. Configure repository
cp .env.production.example .env.production
nano .env.production  # Set GITHUB_REPOSITORY

# 6. Deploy
make swarm-deploy
```

### On Your Machine (Development)

```bash
# 1. Make changes to Flask app
# 2. Commit and push
git push origin main

# 3. GitHub Actions builds and pushes to GHCR
# 4. On server, update service
ssh your-server
cd /srv/classproject
make swarm-update
```

## Troubleshooting

**Can't access repository (permission denied)?**
- Make sure you've set up the SSH deploy key correctly
- Verify the public key is added to GitHub: Settings → Deploy keys
- Test SSH connection: `ssh -T git@github.com-classproject`
- Check deploy key permissions: `ls -l /etc/ssh/deploy_keys/classproject_deploy`


**Need to reset?**
```bash
cd /srv/classproject
rm -rf .git
./server-setup.sh
```

## File Structure on Server

After setup, `/srv/classproject` contains:

```
/srv/classproject/
├── traefik/
│   ├── traefik.yml
│   └── dynamic/
├── website/
│   ├── main.py
│   ├── site_blueprints.py
│   └── templates/
├── .github/
│   └── workflows/
├── docker-swarm.*.yml
├── deploy-swarm.sh
├── setup-secrets.sh
├── Makefile
├── .env.production       (you create this)
└── *.md
```

## Alternative: Manual File Copy

If you don't want to use git at all:

```bash
# On your local machine, create a tarball
tar czf project.tar.gz \
  --exclude='.git' \
  --exclude='website/__pycache__' \
  --exclude='website/.venv' \
  .

# Copy to server
scp project.tar.gz your-server:/srv/classproject/

# On server, extract
cd /srv/classproject
tar xzf project.tar.gz
rm project.tar.gz
```
