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


# ========== Field Initialization ==========
"""
By the end of each constructor, all fields must be initialized (the only requirement).

__init__ is smart enough to treat the self object as fully initialized before the constructor is finished,
so long all fields are initialized.

Below the constructor can pass around self as soon as all fields are initialized.
"""
fn use(arg: MyPet2):
    pass


struct MyPet2:
    var name: String
    var age: Int

    fn __init__(inout self, name: String, age: Int, cond: Bool):
        self.name = name
        if cond:
            self.age = age
            use(self)   # self can be used from this point!

        self.age = age
        use(self)   # self can be used from this point!


# ========== Constructors and Implicit Conversion ==========
"""
Mojo supports implicit conversion of types. Implicit conversion can happen when:
    - A value of one type is assigned to a var with a different type
    - Passing a value of one type as an arg to a func that requires a differen type.

In both cases, implicit conversion is supported when the target type defines a constructor with one single, required, non-keyword argument of the source type.
var a = Source()
var b: Target = a

The matching constructor in Target could look like the following:
struct Target:
    fn __init__(inout self, s: Source):
        ...

The implicit conversion makes the assignment equivalent to the following:
var b = Target(a)

Implicit conversion constructor can also take optional args, so long it's a keyword argument
struct Target:
    def __init__(inout self, s: Source, reverse: Bool = False):
        ...

Implicit conversion also occurs if the type doesn;t declare its own constructor, 
but rather uses the @value decorator, AND the type has only one field.
Mojo creates a member-wise constructor for each field (remember that all types are Structs!),
and when there is only one field, that constructor works like a conversion constructor.

The following type can also convert Source to Target:
@value
struct Target:
    var s: Source

Implicit conversion can fail if Mojo cannot unambiguously match the conversion to a constructor.
e.g. if the Target type has 2 overloaded constructors that take different types, and each of those types
supports an implicit conversion from the Source type, the compiler cannot figure out which one to use .

struct A:
    fn __init__(inout self, s: Source): 
        ...

struct B:
    fn __init__(inout self, s: Source):
        ...

struct Target:
    fn __init__(inout self, a: A):
        ...
    
    fn __init__(inout self, b: B):
        ...

Both target inits accept a Source type, so removing either of them will help the compiler along.

***
If you want to define a single-arg constructor, but don;t want the types to implicitly convert,
you can define the constructor with a keyword-only argument!
***

struct Target:
    # Does not support implicit conversion
    fn __init__(inout self, *, source: Source):
        ...

# Constructor must be called with a keyword arg
var t = Target(source=a)
"""


fn main():
    NoInstances.print_hello()

    # Constructor
    var mine = MyPet("Loke", 4)

    # Constrtuctor overloading
    var mine1 = MyPet1()
    var mine2 = MyPet1("Kingy")