# Development Guide

## Quick Start

### Option 1: Local Development (Recommended)

Run Flask directly on your machine for fastest development:

```bash
make sync
make dev
```

Visit http://localhost:9000

**Features:**
- Hot reload on file changes
- Debug mode enabled
- Fastest iteration speed

### Option 2: Docker Development

Run Flask in Docker for environment consistency:

```bash
make dev-docker
```

Visit http://localhost:9000

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
make add PACKAGE=package-name
# Example: make add PACKAGE=flask-cors
```

## Environment Variables

Create `website/.env` for local development:

```bash
FLASK_ENV=development
FLASK_DEBUG=1
SECRET_KEY=dev-secret-key
PORT=9000
```

## Common Tasks

### Run tests
```bash
make test
```

### Access Python shell
```bash
make shell
>>> from main import app
>>> app.config
```

### Clean up
```bash
# Remove Python and Docker cleanup
make down
make clean
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
make routes
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
        "FLASK_DEBUG": "1",
        "PORT": "9000"
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

## Troubleshooting

**Port already in use?**
```bash
lsof -ti:9000 | xargs kill
```

**Dependencies not installing?**
```bash
make clean-deps
```

**Code changes not reflecting?**
- Check debug mode is enabled
- Restart Flask server
- Clear browser cache

**Import errors?**
```bash
make check-version
```
