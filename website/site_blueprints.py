from flask import Blueprint, render_template

blueprint = Blueprint('blueprint', __name__, static_folder='static', template_folder='templates')

@blueprint.route('/')
def home():
    return render_template("home.html")

@blueprint.route('/bios')
def bios():
    return render_template('bios.html')

@blueprint.route('/feasibility-v1')
def feasibility_version_one():
    return render_template('feasibility-slides-version-1.html')

@blueprint.route('/feasibility-v2')
def feasibility_version_two():
    return render_template('feasibility-slides-version-2.html')

@blueprint.route('/wip-feasibility')
def wip_feasibility():
    return render_template('wip-feasibility-slides.html')
