# Server Setup Guide

This guide shows how to set up your server repository.

## Prerequisites

<<<<<<< HEAD
Since this is a **private repository**, you must set up authentication before pulling files. See the "Setting Up Authentication" section below.

## Automated Setup (Recommended)

**First**, set up authentication (see below), **then** run this script:

```bash
# Download and run the setup script
curl -O https://raw.githubusercontent.com/stephen-steyaert-odu/cs-410-11/main/server-setup.sh
=======
Since this is a **private repository**, you must connect to the server with SSH agent forwarding enabled. Use `ssh -A user@server` when connecting. Your local SSH key will be used for git operations.

## Initial Setup (First Time Only)

The repository administrator will set up the server initially:

```bash
# Connect to server with SSH agent forwarding
ssh -A your-server

cd /srv/classproject

# Run the setup script (already on the server)
>>>>>>> main
chmod +x server-setup.sh
./server-setup.sh
```

<<<<<<< HEAD
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
=======
The script will:
1. Initialize the git repository and pull files
2. Configure git for group access
3. Set up proper group permissions for the `classproject` group

**Note:** The script can be run multiple times safely - if the repository is already initialized, it will skip the init/pull and just apply git config and permissions.

## For Group Members

Once the repository is set up, classmates typically don't need to interact with git on the server. Application updates are deployed via GHCR images (see "Development Workflow" below).

If you need to access the server to update infrastructure files (rare), first configure git:

```bash
# Connect to server with SSH agent forwarding
ssh -A your-server

# Configure git to trust this directory (first time only)
git config --global --add safe.directory /srv/classproject
```

## SSH Agent Forwarding (For Infrastructure Updates)

**Note:** You only need this if you're updating infrastructure files on the server. Regular application development doesn't require git access on the server.

Since the repository is private, the administrator uses SSH agent forwarding for the initial setup and any infrastructure updates.

**Prerequisites:**
1. Add your SSH public key to your GitHub account:
   - Local machine: `cat ~/.ssh/id_ed25519.pub` (or `id_rsa.pub`)
   - Go to: GitHub → Settings → SSH and GPG keys → New SSH key
   - Paste your public key

**When needed, connect with agent forwarding:**

```bash
# Connect with -A flag to forward your SSH agent
ssh -A user@your-server

# Configure git to trust the shared directory (first time only)
git config --global --add safe.directory /srv/classproject

# Now git operations will use your forwarded SSH key
>>>>>>> main
cd /srv/classproject
git pull origin main
```

<<<<<<< HEAD
The authentication will use the shared deploy key (SSH)

## Complete Deployment Flow

### On Server (One-time Setup)

```bash
# 0. Set up SSH deploy key authentication (see "Setting Up Authentication" above)

# 1. Pull infrastructure files
./server-setup.sh
=======
**How it works:**
- Your local SSH key is forwarded to the server during your SSH session
- Git operations automatically use your forwarded key to authenticate with GitHub
- No credentials are stored on the server
- Each user uses their own GitHub SSH key


## Group Access Configuration

The `server-setup.sh` script automatically configures group permissions for the `classproject` group. This allows any group member to run deployment commands like `make swarm-update` on the server.

The group permissions are set up so that:
- All files are group-writable
- New files inherit the `classproject` group
- Git is configured for shared repository access

## Updating Infrastructure Files (Rare)

Git on the server is **only for infrastructure files** (docker-swarm configs, Makefile, scripts, etc.). Application code updates come through GHCR images.

If you need to update infrastructure files (rare):

```bash
# Connect with SSH agent forwarding
ssh -A user@your-server

cd /srv/classproject
git pull origin main
```

For regular application updates, see "Development Workflow" below.

## Complete Deployment Flow

### On Server (Administrator - One-time Setup)

```bash
# 0. Connect with SSH agent forwarding
ssh -A user@your-server

# 1. Run the setup script (already on server)
cd /srv/classproject
chmod +x server-setup.sh
./server-setup.sh
# Your forwarded SSH key will be used for authentication
>>>>>>> main

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

<<<<<<< HEAD
### On Your Machine (Development)

=======
### Development Workflow (All Group Members)

**On your local machine:**
>>>>>>> main
```bash
# 1. Make changes to Flask app
# 2. Commit and push
git push origin main

<<<<<<< HEAD
# 3. GitHub Actions builds and pushes to GHCR
# 4. On server, update service
ssh your-server
=======
# 3. GitHub Actions automatically builds and pushes Docker image to GHCR
```

**On the server (to deploy the new image):**
```bash
ssh user@your-server
>>>>>>> main
cd /srv/classproject
make swarm-update
```

<<<<<<< HEAD
## Troubleshooting

**Can't access repository (permission denied)?**
- Make sure you've set up the SSH deploy key correctly
- Verify the public key is added to GitHub: Settings → Deploy keys
- Test SSH connection: `ssh -T git@github.com-classproject`
- Check deploy key permissions: `ls -l /etc/ssh/deploy_keys/classproject_deploy`

=======
This pulls the new image from GHCR and does a rolling update with zero downtime. **You don't need to git pull on the server** - the application code comes from the Docker image.

## Troubleshooting

**Can't access repository (authentication failed)?**
- Make sure you connected with `ssh -A` to forward your SSH agent
- Verify your SSH key is added to GitHub: Settings → SSH and GPG keys
- Test SSH connection: `ssh -T git@github.com` (should say "Hi username!")
- Check agent forwarding is working: `ssh-add -l` (should list your keys)
- Verify you have access to the private repository on GitHub

**Git says "dubious ownership in repository"?**
```bash
git config --global --add safe.directory /srv/classproject
```
This tells git to trust the directory even though it's group-owned. Each user needs to run this once.
>>>>>>> main

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

<<<<<<< HEAD
## Alternative: Manual File Copy

If you don't want to use git at all:
=======
## Alternative: Manual File Copy (Administrator Only)

If you don't want to use git for the initial setup:
>>>>>>> main

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
