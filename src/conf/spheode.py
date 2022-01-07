import datetime
import logging
import os

logging.basicConfig(level=logging.DEBUG)

GIT_COMMAND = ["git", "describe", "--tag", "--always", "--dirty=+"]
REPO = os.environ['REPO']
DOCS = os.path.join(REPO, os.environ['DOCS'])

def copyright_since(author, year, until=None):
    """Format a string for the copyright year automatically."""
    start_year, end_year = int(year), int(until or datetime.datetime.today().year)
    if start_year == end_year:
        return f'{start_year:04d}, {author}'
    else:
        return f'{start_year:04d}-{end_year:04d}, {author}'

def detect_version(command=GIT_COMMAND, repo=REPO, fallback="NOVERSION"):
    import subprocess
    logging.debug(f"Determining version using: {command}")
    version = None
    try:
        version = subprocess.check_output(command, cwd=repo).strip().decode('utf-8')
        logging.info(f"Determined version to be: {version}")
    except Exception as e:
        logging.warn(f"Determining version failed: {e}")
        version = fallback
    return version

nitpicky = default_nitpicky = True
smartquotes = default_smartquotes = True

extensions = default_extensions = [
        "sphinx.ext.autodoc",
        "sphinx.ext.autosectionlabel",
        "sphinx.ext.autosummary",
        "sphinx.ext.intersphinx",
        "sphinx_copybutton",
        "sphinx_inline_tabs",
        "sphinxcontrib.cmtinc",
        "sphinxcontrib.mermaid",
        ]

tls_cacerts = "/etc/ssl/cert.pem" # use the system CA certs

# Ignore Git directories and the default pro/epilog files.
exclude_patterns = default_exclude_patterns = [
        "**/.git",
        "prolog.rst",
        "epilog.rst",
        ]

# Theme settings
html_theme = "furo"

# Autosectionlabel settings
autosectionlabel_prefix_document = True # avoid conflicting subsection labels
autosectionlabel_maxdepth = None

# Set the release from the environment or VCS
release = default_release = os.environ.get('RELEASE', None) or detect_version()

# Automatically add the prolog and epilog if files are present.
prolog_file = os.path.join(DOCS, 'prolog.rst')
epilog_file = os.path.join(DOCS, 'epilog.rst')
if os.path.exists(prolog_file):
    with open(prolog_file, 'r') as prolog:
        rst_prolog = default_rst_prolog = prolog.read()
if os.path.exists(epilog_file):
    with open(epilog_file, 'r') as epilog:
        rst_epilog = default_rst_epilog = epilog.read()
