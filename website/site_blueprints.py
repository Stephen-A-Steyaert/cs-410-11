from flask import Blueprint, render_template

blueprint = Blueprint('blueprint', __name__, static_folder='static', template_folder='templates')

@blueprint.route('/')
def home():
    return render_template("home.html")

@blueprint.route('/bios')
def bios():
    return render_template('bios.html')

@blueprint.route('/problem')
def problem():
    return render_template('problem.html')

@blueprint.route('/solution')
def solution():
    return render_template('solution.html')
    
@blueprint.route('/feasibility-v1')
def feasibility_version_one():
    return render_template('feasibility-slides-version-1.html')

@blueprint.route('/feasibility-v2')
def feasibility_version_two():
    return render_template('feasibility-slides-version-2.html')

@blueprint.route('/feasibility-v3')
def feasibility_version_three():
    return render_template('feasibility-slides-version-3.html')

@blueprint.route('/wip-feasibility')
def wip_feasibility():
    return render_template('wip-feasibility-slides.html')

@blueprint.route('/deliverables')
def deliverables():
    return render_template('deliverables.html')

@blueprint.route('/references')
def references():
    return render_template('references.html')

@blueprint.route('/glossary')
def glossary():
    return render_template('glossary.html')

@blueprint.route('/easter-egg')
def easter_egg():
    return render_template('ee.html')