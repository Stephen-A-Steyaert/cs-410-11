from flask import Flask
from site_blueprints import blueprints
from os import environ

app = Flask(__name__)

# Optional: Add configuration
app.config['SECRET_KEY'] = environ.get('SECRET_KEY', 'dev-secret-key-change-in-production')

# Register blueprints
app.register_blueprint(blueprints, url_prefix="")

if __name__ == "__main__":
    # This only runs when executing `python main.py` directly (development)
    # In production, gunicorn imports the app directly
    debug = environ.get('FLASK_ENV') != 'production'
    app.run(
        host='0.0.0.0',
        port=int(environ.get('PORT', 5000)),
        debug=debug
    )
