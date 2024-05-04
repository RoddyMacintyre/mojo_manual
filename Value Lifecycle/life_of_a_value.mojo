# ========== Introduction ==========
"""
A value's life begins at iitialization and ends at its last use, after which it gets destoryed.
Below explains how Mojo creates, copies, and moves values.

All data types (including primitives) are defined as a STRUCT. Meaning they all follow the same
LIFECYCLE rules defined in the STRUCT. You can implement this yourself as well.

MOJO STRUCTS don't have default LIFECYCLE METHODS. This means you can create a struct without
a constructor, but cannot instantiate it. This could only be useful for things like namespaces for static methods
like below:
"""

struct NoInstances:
    """
    This struct cannot be instantiated, because it has no constructor and thus no defined lifecycle.
    The state field is also useless because the struct cannot be instantiated because Mojo does not support
    default field values, you have to initialize them in a constructor.
    """
    var state: Int

    @staticmethod
    fn print_hello():
        print("Hello world!")


fn main():
    NoInstances.print_hello()