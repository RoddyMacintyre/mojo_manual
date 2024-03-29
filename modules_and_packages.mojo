"""
Allows organization and compilation of code libraries into importable files.
"""

# ========== MOJO MODULES ===========
"""
Mojo module is a single Mojo source file that includes code suitable for use by other files that import it
See the modules_and_packages directory to see how it works.
Note that for this to work, you need the module in the same directory as the file that imports it!
To make it work from other directories, you need to implement it as a package
"""

# ========== MOJO PACKAGES ==========
"""
A collection of Mojo modules in a dir that includes an __init__.mojo file
Can then import the entire package or certain modules.
Optionally, can compile it into a .mojopkg file that's easier to share and compatible across system archs

Can import directly from source files or a compiled .mojopkg (to Mojo it makes no difference)
- Import from source files:
    directory name = package name
- Import from compiled package:
    filename = package name

For a package implementation , see the mypackage folder

Mojo package:
If you want the source code in a different location than main.mojo, compile it to a package.

Package command:
`mojo package mypackage -o mypack.mojopkg`
"""