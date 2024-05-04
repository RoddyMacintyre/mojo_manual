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


# ========== Constructor ==========
"""
To create instances in Mojo, you need to implement the __init__ method.
Its main responsibility is to iitalize fields (see MyPet)

MyPet can be borrowed, but as of now cannot be copied or moved. This is a good starting point,
and it's up to the author to decide whether to implement lifecycle methods, and how they should behave.

NOTE: 
Mojo doens;t require a desturctor to destroy an object. As long as all fields are destructible,
Mojo knows how to destroy the type when the lifetime ends.
"""

struct MyPet:
    var name: String
    var age: Int

    fn __init__(inout self, name: String, age: Int):
        self.name = name
        self.age = age


# ========== Constructor Overloading ==========
"""
You can overload any method, including the __init__. You might want a default constructor
that sets some default values and takes no args, plus one that does accept args for extra values/

Be aware that to modify fields, the __init__ must declare self with the INOUT convention.
You can also call one constructor from the other.

Below an example of constructor overloading.

"""

struct MyPet1:
    var name: String
    var age: Int

    fn __init__(inout self):
        self.name = ""
        self.age = 0

    fn __init__(inout self, name: String):
        self = MyPet1()
        self.name = name



fn main():
    NoInstances.print_hello()

    # Constructor
    var mine = MyPet("Loke", 4)

    # Constrtuctor overloading
    var mine1 = MyPet1()
    var mine2 = MyPet1("Kingy")