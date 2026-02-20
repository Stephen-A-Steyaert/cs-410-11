from flask import Flask, url_for as flask_url_for
from site_blueprints import blueprint
from example_blueprints import example_blueprint
from os import environ
from pathlib import Path

app = Flask(__name__)

# Read secret key from Docker secret or environment variable
def get_secret(secret_name, env_var=None, default=None):
    """Read secret from Docker secret file or environment variable."""
    secret_path = Path(f'/run/secrets/{secret_name}')
    if secret_path.exists():
        return secret_path.read_text().strip()
    if env_var and environ.get(env_var):
        return environ.get(env_var)
    return default

app.config['SECRET_KEY'] = get_secret('flask_secret_key', 'SECRET_KEY', 'dev-secret-key-change-in-production')

# Automatic cache busting for static files
@app.context_processor
def override_url_for():
    return dict(url_for=dated_url_for)

def dated_url_for(endpoint, **values):
    """Add file modification timestamp to static file URLs for cache busting."""
    if endpoint == 'static':
        filename = values.get('filename', None)
        if filename:
            file_path = Path(app.root_path) / 'static' / filename
            if file_path.exists():
                values['v'] = int(file_path.stat().st_mtime)
    return flask_url_for(endpoint, **values)

# Register blueprints
app.register_blueprint(blueprint, url_prefix="")
app.register_blueprint(example_blueprint, url_prefix='/development')

if __name__ == "__main__":
    # This only runs when executing `python main.py` directly (development)
    # In production, gunicorn imports the app directly
    debug = environ.get('FLASK_ENV') != 'production'
    app.run(
        host='0.0.0.0',
        port=int(environ.get('PORT', 5001)),
        debug=debug
    )
