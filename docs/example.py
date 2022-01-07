#!/usr/bin/env python3

#:
# This is a comment in ``example.py`` which will be included in the
# documentation as native reStructuredText. It can include exemplar code
# blocks, like this ::
#
#    >>> multiply(2, 4)
#    8
#
# It is also easy to include source code directly from the file, rather than
# needing to duplicate it, and risk drift. For example, this is the actual
# implementation of the ``multiply()`` function, included directly into the
# documentation with great control of the surrounding content, and no
# duplication of code. ::
#. \codepara
def multiply(a, b):
    """Multiply two numbers."""
    return a * b

# Not every comment needs to be decorated with the ``#:`` and ``#.`` markers.
# Ones that are not are simply ignored.
