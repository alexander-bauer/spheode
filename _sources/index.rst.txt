Spheode
=======

Spheode is an opinionated, open-source documentation tool built atop Sphinx.
Source documentation are typically living reStructuredText documentation
intermingled with code. From those sources, Spheode renders HTML documentation
using Sphinx, either repeatably on-the-fly during authorship, or during a CI
pipeline.


Usage
-----

.. highlight:: bash

Spheode has two modes: ``autobuild`` and ``export``. When invoked without an
argument, ``autobuild`` is the default mode. In both modes, the *root* of the
source repository must be mounted to ``/repo``.

``autobuild``
^^^^^^^^^^^^^

In ``autobuild`` mode, Spheode invokes ``sphinx-autobuild``, which
automatically rebuilds the HTML documentation on changes to the source
directory, and serves it on port 8000 in the container. This is the typical
mode for developers to use while authoring documentation. ::

   $ docker run -v "$(pwd):/repo:ro" -p "8000:8000" alexanderbauer0/spheode:latest

An easy way to use this is to set an alias in your ``.bashrc``. ::

   alias spheode='docker run -v "$(pwd):/repo:ro" -p "8000:8000" alexanderbauer0/spheode:latest'

``export``
^^^^^^^^^^

In ``export`` mode, Spheode invokes ``sphinx-build`` once and delivers the
resulting HTML documentation to the volume mounted at ``/export``. This might
be used in a CI context to build static documentation for new versions of the
source, such as for GitHub or GitLab Pages. ::

   $ docker run -v "$(pwd):/repo:ro" -v "$(pwd)/export:/export" alexanderbauer0/spheode:latest export

Additional arguments, such as to ``chown`` the export to another user, may be
passed just by appending them. ::

   $ docker run -v "$(pwd):/repo:ro" -v "$(pwd)/export:/export" alexanderbauer0/spheode:latest export --chown 1000:1000

Debugging
^^^^^^^^^

Entering the Container Interactively
""""""""""""""""""""""""""""""""""""

Typically Spheode should not be entered interactively, but for debugging
purposes, it may be entered by overriding the container ``entrypoint``, like ::

   $ docker run -v $(pwd):/repo --entrypoint sh -it alexanderbauer0/spheode:latest

Details
-------

Sources
^^^^^^^

Documentation sources are reStructuredText files in the ``docs`` subdirectory
of the root of the repository. The root of the documentation is ``index.rst``.
Optionally, ``conf.py`` can be provided to set Sphinx configuration options;
see `index:Sphinx Configuration`. ::

  .                   <-- repository root
  └── docs            <-- documentation root
      ├── conf.py     <-- optional user-provided configuration
      └── index.rst   <-- documentation index or entrypoint


In addition to regular reStructuredText sources, Spheode includes the
``sphinxcontrib-cmtinc`` plugin, which adds the capability to ingest source files 

That is, plaintext sources marked up with reStructuredText living either
alongside in separate files or directly embedded within code sources.

Sphinx Configuration
""""""""""""""""""""

Optionally ``conf.py`` can be provided in the root of the ``docs`` directory in
order to set Sphinx configuration options. Many options are set automatically
by Spheode, but project-specific options (such as ``project``, ``author``, and
``copyright``) may be set. Spheode provides some functions for convenience,
such as ``copyright_since(author, start_year, end_year=current_year)``

For example, here is the ``conf.py`` included with this project.

.. literalinclude:: conf.py
   :caption: conf.py
   :language: python

Prolog / Epilog
"""""""""""""""

Files named ``prolog.rst`` or ``epilog.rst`` in the root of the ``docs``
directory are set as ``rst_prolog`` or ``rst_epilog`` in the Sphinx
configuration.  Those configuration options do not need to be set. To extend
the content of either programatically, simply override ``rst_prolog`` or
``rst_epilog`` in the custom ``conf.py``. The content as set by Spheode is
available as ``default_rst_prolog`` and ``default_rst_epilog``.

Documentation in Source Code
""""""""""""""""""""""""""""

Spheode includes the ``sphinxcontrib-cmtinc`` plugin, which provides a
directive to include Sphinx documentation embedded within other files, such as
source code. For example, here is source code and a directive for including it.

.. tab:: Source

   .. code-block:: RST
      :caption: Sphinx directive

      .. include-comment:: example.py
         :style: hash

   .. literalinclude:: example.py
      :caption: example.py
      :language: python

.. tab:: Result

   .. include-comment:: example.py
      :style: hash

Another less contrived example of this feature in action is for documenting
Ansible playbooks and roles.

.. tab:: Source

   .. code-block:: RST
      :caption: Sphinx directive

      .. include-comment:: example-playbook.yml
         :style: hash

   .. literalinclude:: example-playbook.yml
      :caption: example-playbook.yml
      :language: yaml+jinja

.. tab:: Result

   .. include-comment:: example-playbook.yml
      :style: hash

Convenience Functions
"""""""""""""""""""""

These functions are available in the local namespace of the custom ``conf.py``.
They do not need to be imported to be used.

.. highlight:: python

``copyright_since``
  This function, given an author and year, produces copyright statements in the form expected by Sphinx. ::

     >>> copyright_since("John Doe", "2002")
     "2002-2022, John doe"

     >>> copyright_since("John Doe", "2002", "2010")
     "2002-2020, John doe"

     >>> copyright_since("John Doe", "2022")
     "2022, John doe"

Internals
---------

Spheode is a container. It may be built and run using Docker or Podman. Its
entrypoint is the script ``spheode``, which invokes Sphinx in a structured way.

Configuration
^^^^^^^^^^^^^

Spheode provides its own ``conf.py`` for use by Sphinx which sets many default
options. These can be extended by a ``conf.py`` in the user ``docs`` source.
Mechanically, Spheode assembles a temporary ``conf`` directory and supplies it
to Sphinx using the ``-c`` option. This directory contains a ``conf.py``, which
is the entrypoint to the Sphinx configuration. This file reads and then runs
``exec()`` on ``spheode.py``, which sets default options, and then
``userconf.py``, which is a symlink to the user-provided ``conf.py``.
