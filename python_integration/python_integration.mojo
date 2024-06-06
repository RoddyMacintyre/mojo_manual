# ========== Intorduction ==========
"""
The longterm goal is to make Mojo a Pyton superset (make Mojo compatible with existing Python programs).
Mojo should be able to support all Python packages.

Mojo is still in early development, and many such features are not implemented yet.

To bridge this gap, Mojo lets you import Python modules, call Python function and interact with Python objects
from Mojo code. It runs code using a standard Python interpreter (CPython), so you existing Python code doesn't need to change.
"""

# ========== Import a Python Module ==========
"""
To import a Python module, just call Python.import_module() with the module name as an argument.
"""

from python import Python

fn use_array() raises:
    # Equivalent to import numpy as np
    var np = Python.import_module("numpy")

    # Now use numpy as if you're working in Python
    var array = np.array([1, 2, 3])
    print(array)

"""
You can import all Python modules in this fashion.

NOTES:
- Currently cannot import individual members, you must import the whole module, and access members through the module name.
- Mojo doesn't yet support top-level code, so import_module must be inside a function. Meanin gyou need to import multiple times, or pass references.
    You don't pay a perf penalty for importing multiple times, as Mojo caches the module after the first import.
- import_module() my raise an exception (e.g. the module is not installed). You need to either handle the exception with try/except or add the raises keyword.
    This also applies to calling Python funcs that raise exceptions.

NOTE:
Mojo loads the Python interpreterr and Python modules at runtime, so wherever you run a Mojo program, it must be able to access a compatible
Python interpreter, and to locate any imported Python modules. For more information, see the Python environment.
"""

# ========== Import Local Python Module ==========
"""
If you have local Python code you want to use in Mojo, add the directory tot he Python path and import the module.
E.g. suppose you have a file "mypython.py", see main.

Both absolute and relative paths work with add_to_path().
Full path works, but also the "." for current/local directory.
"""

# ========== Call Mojo from Python ==========
"""
There's currently no way to call Mojo from Python. 
This might present a challenge for certain modules, e.g. many UI frameworks have a main event loop
that makes callbacks to to user-defined code in response to events.
This is an inversion of control where the app call out to application code, instead of calling into a library.

You simply cannot pass Mojo callbacks to a Python module.

Consider Tkinter, the typical usage is something along the lines of:
    - Create a main/root window
    - Add UI widgets to the window (these can have associated callback functions)
    - Start the main event loop, listening for events and invoking callback functions.

Since Python cannot call back into Mojo, an alternative is to have Mojo drive the event loop and poll for updates.
Consider the following example (see ui_py.py).

We can call this Python module fro Mojo:
"""
fn button_clicked():
    print("Hi from a Mojo🔥 fn!")

# ========== Python Environment ==========
"""
The Mojo SDK depends on an existing Python installation that includes a shared lib version of the Python interpreter.
When installing Mojo, it looks for a compatible Python and sets up the sys.path to load matching modules.

In most cases, this just works. If you, however, do run into problems, see the following sections.
"""

# ========== Installation Issues ==========
"""
Mojo uses find_libpython to find a CPythopn shared library. This may fail with any of the following conditions:
    - No Python installed, or unsupported version by Mojo
    - No shared lib version of the CPython interpreter found (e.g. .so, .dylib). Some py dists
      don't include shared libs, which prevents Mojo from embedding the interpreter.

In all cases, install a compatible Python version, including shared libs.
Try with the following link: https://docs.modular.com/mojo/manual/python/#set-up-a-python-environment-with-conda
"""

# ========== Set up a Python Environment with Conda ==========
"""
Using a Py venv like Conda is a way to avoid problems with Mojo & Python. It provides a consistent Py env
with a known version of Py, and all the packages you want to use with Mojo.

Instructions to set up a venv with Conda:
    1. Install Conda by following https://docs.conda.io/projects/miniconda/en/latest/#quick-command-line-install 
       Make sure to initialize Conda for the shell or shells you use, e.g.:
       ~/miniconda3/bin/conda init zsh
       OR
       ~/miniconda3/bin/conda init -all
    2. Restart your shell
    3. Run the following command (configures Mojo to use the Conda env):
       "
       export MOJO_PYTHON_LIBRARY="$(find $CONDA_PREFIX/lib -iname 'libpython*.[s,d]*' | sort -r | head -n 1)"
       echo "export MOJO_PYTHON_LIBRARY=$MOJO_PYTHON_LIBRARY" >> ~/.zshrc
       "
       If you use another shell than zsh, adjust the command accordingly.
    4. Try running the Mojo REPL:
         "
         mojo
         "
         If you see the Mojo prompt, you're good to go.

After setting up the Conda venv, you can install any packages you want to use with Mojo using the "conda install" command.
e.g. conda install numpy

For more information on using Conda with Mojo, see the following blog entry:
https://www.modular.com/blog/using-mojo-with-python
"""

fn main() raises:   # Need this because Python code often raises exceptions
    try:
        _ = use_array()
    except:
        print("Could not use Python's numpy module. Reason: ???")

    # Import local Python Modules
    from python import Python

    Python.add_to_path(".") 
    var mypython = Python.import_module("mypython")

    var values = mypython.gen_random_values(2, 3)
    print("The values are:")
    print(values)

    # Call Mojo from Python
    var app = Python.import_module("ui_py").App()
    app.create("800x600")

    # The Mojo event loop for the Python UI
    while True:
        app.update()
        if app.clicked:
            button_clicked()
            app.clicked = False

