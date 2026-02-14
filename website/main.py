from flask import Flask
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

# Register blueprints
app.register_blueprint(blueprint, url_prefix="")
app.register_blueprint(example_blueprint, url_prefix='/development')

if __name__ == "__main__":
    # This only runs when executing `python main.py` directly (development)
    # In production, gunicorn imports the app directly
    debug = environ.get('FLASK_ENV') != 'production'
    app.run(
        host='0.0.0.0',
        port=int(environ.get('PORT', 5000)),
        debug=debug
    )
