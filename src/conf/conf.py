# This file is the main Sphinx configuration entrypoint. It is responsible for
# loading the Spheode defaults, followed by user-provided configuration if any.

import os

with open('spheode.py', 'r') as f:
    exec(f.read())
if os.path.exists(os.path.join(os.getcwd(), 'userconf.py')):
    with open('userconf.py', 'r') as f:
        exec(f.read())
