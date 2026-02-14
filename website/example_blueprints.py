from flask import Blueprint, render_template

example_blueprint = Blueprint('development_example', __name__, static_folder='static', template_folder='examples')

@example_blueprint.route('/example')
def example():
    return render_template("example.html")