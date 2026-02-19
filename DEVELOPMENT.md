# Development Guide

## Quick Start

### Option 1: Local Development (Recommended)

Run Flask directly on your machine for fastest development:

```bash
# Install dependencies
make install

# Run development server
make dev
```

Visit http://localhost:5000

**Features:**
- Hot reload on file changes
- Debug mode enabled
- Fastest iteration speed

### Option 2: Docker Development

Run Flask in Docker for environment consistency:

```bash
make dev-docker
```

Visit http://localhost:5000

**Features:**
- Matches production environment
- Volume mounts for live code reload
- Isolated dependencies

## Development Workflow

1. **Make changes** to Python files, templates, or static files
2. **Refresh browser** - Flask auto-reloads on file changes
3. **Check logs** for errors in terminal/console

## Project Structure

```
website/
├── main.py              # Flask app entry point
├── site_blueprints.py   # Route definitions
├── templates/           # Jinja2 templates
│   ├── base.html       # Base template
│   └── example.html    # Example page
├── static/             # CSS, JS, images
├── pyproject.toml      # Dependencies
└── Dockerfile          # Production build
```

## Adding Dependencies

```bash
# Add a new package
make add PACKAGE=package-name

# Or manually
cd website
uv add package-name
uv sync
```

## Environment Variables

Create `website/.env` for local development:

```bash
FLASK_ENV=development
FLASK_DEBUG=1
SECRET_KEY=dev-secret-key
PORT=5000
```

## Common Tasks

### Run tests
```bash
make test
```

### Access Python shell
```bash
cd website
uv run python
>>> from main import app
>>> app.config
```

### Clean up
```bash
make clean
```

### Sync dependencies
```bash
make sync
```

## Debugging

### Enable verbose logging
```python
# In main.py
import logging
logging.basicConfig(level=logging.DEBUG)
```

### Check routes
```bash
cd website
uv run flask routes
```

### Interactive debugger
When an error occurs in debug mode, you'll see an interactive debugger in the browser.

## Hot Reload

Flask's debug mode watches for file changes and automatically reloads:
- ✅ Python files (.py)
- ✅ Templates (.html)
- ✅ Configuration changes

Note: Some changes require manual restart:
- Adding new dependencies
- Changing Dockerfile
- Modifying docker-compose.yml

## VS Code Setup

Recommended `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flask",
      "type": "debugpy",
      "request": "launch",
      "module": "flask",
      "env": {
        "FLASK_APP": "main.py",
        "FLASK_DEBUG": "1"
      },
      "args": ["run", "--no-debugger", "--no-reload"],
      "jinja": true,
      "cwd": "${workspaceFolder}/website"
    }
  ]
}
```

## Tips

- **Use uv**: It's much faster than pip
- **Keep debug on**: Helps catch errors early
- **Check browser console**: For JavaScript errors
- **Use Flask templates**: Don't put HTML in Python
- **Static files**: Put in `static/`, reference with `url_for('static', filename='...')`

## Makefile Commands

This project uses a Makefile for common tasks. See [MAKEFILE.md](MAKEFILE.md) for complete documentation.

**Development commands:**
```bash
make dev          # Run Flask development server locally
make dev-docker   # Run Flask in Docker for development
make install      # Install Python dependencies
make add          # Add new dependency (usage: make add PACKAGE=flask-cors)
make test         # Run tests
make clean        # Clean up Python cache and Docker resources
```

## Troubleshooting

**Port already in use?**
```bash
lsof -ti:5000 | xargs kill
```

**Dependencies not installing?**
```bash
make install
# Or manually reset
cd website
rm -rf .venv
uv sync
```

**Code changes not reflecting?**
- Check debug mode is enabled
- Restart Flask server (Ctrl+C, then `make dev`)
- Clear browser cache

**Import errors?**
```bash
cd website
uv run python -c "import flask; print(flask.__version__)"
```
