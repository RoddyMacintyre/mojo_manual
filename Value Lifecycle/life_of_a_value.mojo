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

# ========== Copy Constructor ==========
"""
Mojo tries to make a copy of the right side value when it encounters the assingment operator
by calling the type's copy constructor (__copyinit).
It's the responsibility of the author to implement this copy constructor.

e.g. the MyPet type does not have a copy constructor, so the following code will fail:
var mine = MyPet2("Kingy")
var yours = mine    # Requires a copy, but MyPet2 doesn' implement it.

To make this work, implement the copy sconstructor __copyinit__() method

NOTE:
In the copy constructor the 2nd self (for existing) is capitalized. This is merely a convention to distinguish
between the mandatory inout self arg and the copy constructor arg.

NOTE:
The existing arg in __copyinit__ is immutable because the default arg convention in an fn function is BORROWED.
This is a good convention because the function should not modify the contents of the value being copied.
"""

struct MyPet3:
    var name: String
    var age: Int

    fn __init__(inout self, name: String, age: Int):
        self.name = name
        self.age = age

    fn __copyinit__(inout self, existing: Self):    # Note how the 2nd self is capitalized to Self
        self.name = existing.name
        self.age = existing.age

"""
Contrary to most other languages, Mojo's copy behaviour performs a deep copy of all fields in the type (as per VALUE SEMANTICS).
It copies heap-allocated values rather than copying the pointer.

The Mojo Compiler doesn't enforce this, so it's the responsibility of the author to implement __copyinit__()
with VALUE SEMANTICS.
e.g. a HeapArray type that perfomrs a deep copy in the copy constructor:
"""

struct HeapArray:
    var data: Pointer[Int]
    var size: Int
    var cap: Int

    fn __init__(inout self, size: Int, val: Int):
        self.size = size
        self.cap = size * 2
        self.data = Pointer[Int].alloc(self.cap)

        for i in range(self.size):
            self.data.store(i, val)

    fn __copyinit__(inout self, existing: Self):
        # Deep-cpopy of the existing value
        self.size = existing.size
        self.cap = existing.cap
        self.data = Pointer[Int].alloc(self.cap)

        for i in range(self.size):
            self.data.store(i, existing.data.load(i))   # LOAD instead of STORE
    
    fn __del__(owned self):
        # Must free the Heap-allocated data, but Mojo knows how to destroy the other fields
        self.data.free()

    fn append(inout self, val: Int):
        # Update the array
        if self.size < self.cap:
            self.data.store(self.size, val)
            self.size += 1
        else:
            print("Out of bounds")

    fn dump(self):
        # Print the array
        print("[", end="")
        for i in range(self.size):
            if i > 0:
                print(", ", end="")
            print(self.data.load(i), end="")
        print("]")

"""
NOTE:
__copyinit__() does not copy the Pointer value (otherwise it would reference the same data as the original self).
Instead, a new Pointer is initialized to allocate a new block of memory, to copy all heap-allocated values to (deep-copy).

So, when we copy HeapArray, each copy has its own value on the heap. Cahanges are isolated per instance because of this.
"""

fn copies():
    var a = HeapArray(2, 1)
    var b = a   # Calls implemented __copyinit__()

    a.dump()    # [1, 1]
    b.dump()    # [1, 1]

    b.append(2) # Changes only copied data in b, and doesn't affect a
    b.dump()    # [1, 1, 2]
    a.dump()    # [1, 1] (original a, unchanged)

"""
NOTE:
In HeapArray, we must use __del__ to free heap-allocated data when the lifetime ends, but Mojo automatically
destroys all other fields when their own lifetimes end. This is discussed further in Death of a Value

If a type doesn't use any Pointers for heap-allocated data, then you don't have to implement
the constructor and copy constructor (is only boilerplate at this state).
For most structs that don't manage memory explicitly, you can just add the @value decorator to the struct definition 
and Mojo will synthesize the __init__(), __copyinit__(), and __moveinit__() methods.

NOTE:
Mojo also calls the copy constructor when a value is passed as OWNED, AND when the LIFETIME of the value doesn't end at that point.
If the lifetime of the value does end there (e.g. by declaring it transferred with the ^ operator), Mojo will invoke the MOVE constructor
"""

fn main():
    NoInstances.print_hello()

    # Constructor
    var mine = MyPet("Loke", 4)

    # Constrtuctor overloading
    var mine1 = MyPet1()
    var mine2 = MyPet1("Kingy")

    # Copy Constructor
    var mine3 = MyPet3("Kingy", 15)
    var yours = mine3

    # Copy constructor HeapArray example
    copies()