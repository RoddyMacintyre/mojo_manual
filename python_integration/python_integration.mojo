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

fn main():
    try:
        _ = use_array()
    except:
        print("Could not use Python's numpy module. Reason: ???")
