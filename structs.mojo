# ========== STRUCTS ==========
"""
A structure that allows encapsulation of fields and methods that operate on an abstraction

Fields:
Data relevant to the struct

Methods:
Functions inside a struct that generally act upon the Field data

E.g. for a graphics app, you can define an Image struct that stores info about each image

In Mojo, a struct is designed to be
- Static
- Memory safe
- High level data types

All data types in Mojo (Int, Bool, String, Tuple) are Structs

Def and fn are both valid for Structs, but you do need to declare all Fields with "var"
"""

# ========== Struct Definition ==========
# Example:
struct MyPair:
    var first: Int
    var second: Int

# This struct has no constructor, so cannot create an instance
struct MyPairInit:
    var first: Int
    var second: Int

    fn __init__(inout self, first: Int, second: Int):
        # inout makes self a mutable reference
        # You need to initialize all declared fields, or it will not compile
        self.first = first
        self.second = second

# ========== Methods ==========
# can add methods freely, aside from dunder methods.
# Methods referencing self are called instance methods because they act on an instance of a struct
struct MyPairMethods:
    var first: Int
    var second: Int

    fn __init__(inout self, first: Int, second: Int):
        self.first = first
        self.second = second

    fn get_sum(self) -> Int:
        # Self is referenced to get the Struct's fields out.
        return self.first + self.second

# ========== Static Methods ==========
"""
Static method can be called without creating an instance. 
It doesn't receive the implicit self arg, and can therefore not access instance fields
Can call the static method solely with the type, but also on an instance of the type
"""
struct Logger:
    fn __init__(inout self):
        pass
    
    @staticmethod
    fn log_info(message: String):
        print("Info: ", message)


# ========== Structs Compared to Classes ==========
"""
Mojo Structs vs Python classes

Both support:
    - methods
    - fields
    - operator overloading
    - decorators for metaprogramming
    - etc.

Key differences:
    - Python classes are dynamic (dynamic dispatch, monkey patching, binding instance fields at runtime)
    - Mojo structs are static (bound at compile time; flexibility vs. performance)
    - Mojo structs do not dupport inheritence, but can implement Traits
    - Python supports class attrs (values shared by all instances)
    - Mojo structs don't support static data members

All fields must be explicitly declared with var
Dunder/special methods for operator overflow (much like Python)
All Mojo's standard types are made using structs
"""

# ========== Special Methods ==========
"""
Dunder methods (double underscore) are predetermined methods that can be defined for a Struct
Best practise to not use them explicitly; Mojo invokes them automagically when needed
e.g. __init__() for instance creation, __del__() as a destructor

Operator behavior is also defined in this way (like +, <, ==, |, etc.)
Almost all special methods match the Python special methods and handle 2 types of tasks:
    - Operator overloading
    - Lifecycle event handling (including ownerships)

Can synthesize boilerplate methods essential for lifecycle handling by adding the @value decorator
"""

# ========== @value Decorator ==========
"""
When adding the @value decorator, Mojo will synthesize essential lifecycle methods, to provide an object with full value semantics
Then following are specifically synthesized:
    - __init__()
    - __copyinit__()
    - __moveinit__()

These are the Construct, Copy, and Move semantic compatible with Mojo's ownership model
"""

@value
struct MYPEt:
    var name: String
    var age: Int

# Mojo will synthesize the above behind the scenes as if you had written the following:
struct _MyPet:
    var name: String
    var age: Int

    fn __init__(inout self, owned name: String, age: Int):
        self.name = name
        self.age = age

    fn __copyinit__(inout self, existing: Self):
        self.name = existing.name
        self.age = existing.age

    fn __moveinit__(inout self, owned existing: Self):
        self.name = existing.name^  # What's this carat symbol for?
        self.age = existing.age

# Without a copy construcor, could not assign an instance to a new variable by means of a copy.
# Custom implementations of the above synthesized methods will override the default synthesized ones
# "Owned" signifies unique ownership of the value


fn main():
    # Instantiating a struct:
    var mine = MyPairInit(2, 4)
    print(mine.first)

    var mine2 = MyPairMethods(6, 8)
    print(mine2.get_sum())

    # Call static method from the type
    Logger.log_info("Static method called")

    # Call static method from the instance
    var l = Logger()
    l.log_info("Static method called from instance")

    var pet_cat = _MyPet(name="Kingston", age=15)
    var copycat = pet_cat   # Copy (__copyinit__)