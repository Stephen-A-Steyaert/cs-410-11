from flask import Blueprint, render_template

blueprints = Blueprint('blueprint', __name__, static_folder='static', template_folder='templates')

@blueprints.route('/')
def home():
    return render_template("home.html")

@blueprints.route('/example')
def example():
    return render_template("example.html")