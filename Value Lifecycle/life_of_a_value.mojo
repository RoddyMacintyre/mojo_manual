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

# ========== Move Constructor ==========
"""
Copying values provides predictable behavior, matching Mojo's VALUE SEMANTICS. But, copying some data types
can be a heavy operation. 
With REFERENCE SEMANTICS, instead of making a copy when passing a value, you share the value as a reference.
If the original value is no longer needed, the original is nulled to avoid DOUBLE-FREE or USE-AFTER-FREE errors.

This is typically knowns as a MOVE OPERATION:
    - The memory block holding the data remains the same, but the pointer to that block moves to a new variable.

To support moves, implement the __moveinit__() method. This method performs a consuming move.
This means that ownership is transferred from one variable to another when the original variable's lifetime ends
(also known as a "destructive move")

NOTE:
Move constructor is not required to transfer ownership of a value. Unlike in Rust, ownership transfers are not always moves.
Move constructors are only part of the implementation of Mojo ownership transfers (see the section ownership transfer)

Upon a move, Mojo invalidates the original var immediately. This prevents any access to it, and disables its constructor.
Invalidating the original variable is needed to avoid memory errors (USE-AFTER-FREE & DOUBLE-FREE) on heap-allocated data.

Below is a move constructor for the HeapArray
"""

struct HeapArray2:
    var data: Pointer[Int]
    var size: Int
    
    fn __init__(inout self, size: Int, val: Int):
        self.size = size
        self.data = Pointer[Int].alloc(self.size)

        for i in range(self.size):
            self.data.store(i, val)

    fn __copyinit__(inout self, existing: Self):
        # Deep-cpopy of the existing value
        self.size = existing.size
        self.data = Pointer[Int].alloc(self.size)

        for i in range(self.size):
            self.data.store(i, existing.data.load(i))   # LOAD instead of STORE

    fn __moveinit__(inout self, owned existing: Self):  # OWNED
        print("move")
        # Shallow copy the existing value
        self.size = existing.size
        self.data = existing.data
        # Lifetime of existing ends here, but Mojo DOESN't call the destructor
    
    fn __del__(owned self):
        # Must free the Heap-allocated data, but Mojo knows how to destroy the other fields
        self.data.free()

    fn dump(self):
        # Print the array
        print("[", end="")
        for i in range(self.size):
            if i > 0:
                print(", ", end="")
            print(self.data.load(i), end="")
        print("]")

"""
The critical feature is that it takes the incoming value as OWNED, so it gets unique ownership of the value.
Becasue this is a dunder method that Mojo only calls during a move (ownership transfer), the existing arg 
is guaranteed to be a mutable reference to the original value, and not a copy (unlike other methods declaring OWNED, but
might end up receiving the value as a copy if the ^ operator is not involved).
Meaning, Mojo calls this move constructor only when the lifetime of the original variable actually ends at the point of transfer.

Below examples of using the move constructor on the HeapArray
"""

fn moves():
    var a = HeapArray2(3, 1)

    a.dump()    # [1, 1, 1]

    var b = a^  # "move" The lifetime of `a` ends here

    b.dump()    # [1, 1, 1]
    # a.dump()  # ERROR: use of uninitialized value 'a' 

"""
__moveinit__ performs a shallow copy of existing field values (Pointers instead of heap-allocation), which makes it
useful for types with heap-allocated values that are expensive to copy.

To make further efforts to avoid your type being copied, can declare it "move-only". This is done by
implementing __moveinit__ and excluding __copyinit__.
The move-only type can be passed to other vars, and to funcs with any arg convention (borrowed, inout, owned),
but you HAVE to use the ^ operator to end the lifetime of a move-only type when assiging it to a new var
or when passing it as an OWNED argument.

NOTE:
There isn't a real benefit to the move constructor for heap-allocated fields.
Copying simple types on the stack (Ints, Flaots, Booleans) is very cheap.
But, if you allow copying, there's no reason to disallow moves, so you can use @value to synthesize both constructors.
"""

# ========== Simple Value Types ==========
"""
Copy and Move constructors are optional, and provide for good usecases (like atomics), yet most structs
are simple aggregations of other types that should be copyable and movable.

Since otherwise you would need to write a lot of boilerplate for all these types,
Mojo has the @value decorator to synthesize __init__(), __copyinit__(), and __moveinit__().

Consider the following:
"""

@value
struct MyPet5:
    var name: String
    var age: Int



# Mojo detects the @value, and when it doesn't see an __init__(), copy, or move, it will synthesize them.
# It's equivalent to the following:

struct MyPet6:
    var name: String
    var age: Int

    fn __init__(inout self, name: String, age: Int):
        self.name = name
        self.age = age

    fn __copyinit__(inout self, existing: Self):
        self.name = existing.name
        self.age = existing.age

    fn __moveinit__(inout self, owned existing: Self):
        self.name = existing.name^
        self.age = existing.age


"""
Mojo synthesizes each lifecycle method when it doesn't exist. MEaning, you can use @value, and still define
overrides to the default synthesized ones.
It's common to use default member-wise and move constructors, but implement a custom copy constructor.

A common pattern is using @value for a default constructor, and then overriding this constructor for different arg sets.

Below MyPet without having to specify the age:
"""

@value
struct MyPet7:
    var name: String
    var age: Int

    fn __init__(inout self, owned name: String):
        self.name = name^
        self.age = 0

"""
This struct doewsn't override the default constructor because it doesn't share the same arg set.

The __init__ takes the args as OWNED, because the constructor must take ownership of each value to store it.
This enables the use of move-only types, and is therefore an optimization technique.
Small types are also passed as OWNED, however often OWNEd means nothing in that context, so we don't need to 
use the owned convention and ^ operator.

Mojo compiler will see that name^ in self.name is the last place of usage, so essentially, the ^ operator is redundant there.
It will make it a move instead of a copy and delete.

NOTE:
If a type contains any move-only fields, Mojo will not synthesize the copy constructor, because those fields cannot be copied.

@value will not work if any of the members are not copyable and not movable. e.g. if you have an Atomic in the struct,
then you don't have a "true" value type, and don't want move and copy anyway.

MyPet above doesn't implement __del__, because Mojo doens't need it to destroy the values (see Death of a value)
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

    # Move sonstructor/operator
    moves()