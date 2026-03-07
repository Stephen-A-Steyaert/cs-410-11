from flask import Blueprint, render_template

blueprint = Blueprint('blueprint', __name__, static_folder='static', template_folder='templates')

# Cache will be injected by main.py
cache = None

def init_cache(cache_instance):
    """Initialize cache from main.py"""
    global cache
    cache = cache_instance

@blueprint.route('/')
def home():
    if cache:
        @cache.cached(timeout=86_400, key_prefix='home')
        def _cached():
            return render_template("home.html")
        return _cached()
    return render_template("home.html")

@blueprint.route('/bios')
def bios():
    if cache:
        @cache.cached(timeout=86_400, key_prefix='bios')  # 24 hours
        def _cached():
            return render_template('bios.html')
        return _cached()
    return render_template('bios.html')

@blueprint.route('/problem')
def problem():
    if cache:
        @cache.cached(timeout=86_400, key_prefix='problem')
        def _cached():
            return render_template('problem.html')
        return _cached()
    return render_template('problem.html')

@blueprint.route('/solution')
def solution():
    if cache:
        @cache.cached(timeout=86_400, key_prefix='solution')
        def _cached():
            return render_template('solution.html')
        return _cached()
    return render_template('solution.html')

@blueprint.route('/feasibility-v1')
def feasibility_version_one():
    if cache:
        @cache.cached(timeout=86_400, key_prefix='feasibility_v1')
        def _cached():
            return render_template('feasibility-slides-version-1.html')
        return _cached()
    return render_template('feasibility-slides-version-1.html')

@blueprint.route('/feasibility-v2')
def feasibility_version_two():
    if cache:
        @cache.cached(timeout=86_400, key_prefix='feasibility_v2')
        def _cached():
            return render_template('feasibility-slides-version-2.html')
        return _cached()
    return render_template('feasibility-slides-version-2.html')

@blueprint.route('/feasibility-v3')
def feasibility_version_three():
    if cache:
        @cache.cached(timeout=86_400, key_prefix='feasibility_v3')
        def _cached():
            return render_template('feasibility-slides-version-3.html')
        return _cached()
    return render_template('feasibility-slides-version-3.html')

@blueprint.route('/wip-feasibility')
def wip_feasibility():
    if cache:
        @cache.cached(timeout=3600, key_prefix='wip_feasibility')  # Shorter for WIP
        def _cached():
            return render_template('wip-feasibility-slides.html')
        return _cached()
    return render_template('wip-feasibility-slides.html')

@blueprint.route('/deliverables')
def deliverables():
    if cache:
        @cache.cached(timeout=86_400, key_prefix='deliverables')
        def _cached():
            return render_template('deliverables.html')
        return _cached()
    return render_template('deliverables.html')

@blueprint.route('/references')
def references():
    if cache:
        @cache.cached(timeout=86_400, key_prefix='references')
        def _cached():
            return render_template('references.html')
        return _cached()
    return render_template('references.html')

@blueprint.route('/glossary')
def glossary():
    if cache:
        @cache.cached(timeout=86_400, key_prefix='glossary')
        def _cached():
            return render_template('glossary.html')
        return _cached()
    return render_template('glossary.html')

@blueprint.route('/easter-egg')
def easter_egg():
    if cache:
        @cache.cached(timeout=86_400, key_prefix='easter_egg')
        def _cached():
            return render_template('ee.html')
        return _cached()
    return render_template('ee.html')