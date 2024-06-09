# ========== Introduction ==========
"""
When calling Python methods, Mojo needs to convert back and forth between native Python objects and native Mojo objects.
Most of these happend automatically, but some cases aren't handled yet. In those cases, you need to explicitly convert or call an extra method.
"""

# ========== Mojo Types in Python ==========
"""
Mojo primitive types implicitly convert into Python objects. As of now, we support lists, tuples, ints, floats, bools, and strings.
E.g. given the following Python function that prints Python types:

def type_printer(value):
    print(type(value))

You can pass this function Mojo types:

type_printer(4)                 # int
type_printer(3.14)              # float
type_printer(("Mojo", True))    # tuple

NOTE:
This is a simplified example, and the bottom most code is top-level Mojo code.
"""

# ========== Python Types in Mojo ==========
"""
Python objects can also be used in Mojo. If you would like heterogenous collections for Dict and List,
Mojo doesn't support this (yet), but Python does.
"""

def use_dict():
    from python import Python

    var dictionary = Python.dict()
    dictionary["name"] = "Mojo"
    dictionary["age"] = 1
    print(dictionary)

fn main():
    # Python Types in Mojo
    try:
        _ = use_dict()
    except:
        print("Python not installed")