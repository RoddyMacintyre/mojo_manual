# ========== Introduction ===========
"""
If a value/obj is no longer used, Mojo destroys it immediately and doesn't wait for an end in a code block or expression.
Destruction is on an ASAP basis that runs every sub-expression (even in a+b+c+d, a could be destroyed before d is evaluated).

To achieve this, Mojo uses static compiler analysis to identify when a value is last used, and immediately calls the __end__ method.

Notice when __del__() is called in the following struct and its instances:
"""

@value
struct MyPet:
    var name: String
    var age: Int

    fn __del__(owned self):
        print("Destruct", self.name)


fn pets():
    var a = MyPet("Loki", 4)
    var b = MyPet("Sylvie", 2)
    print(a.name)
    # a.__del__() runs hier for "Loki"

    a = MyPet("Charlie", 8)
    # a.__del__() runs immediately because "Charlie" is never used

    print(b.name)
    # b.__del__() runs here

"""
Each initialization is matched with a destructor, and a is actually destroyed multiple times (once for every new value).
This __del__ actually doesn't do anything but expose its calls. Mojo adds a no-op destructor if you don't define one yourself.
"""

# ========== Default Destruction Behavior ==========
"""
Mojo can destroy a type without a destructor, and a no-op destructor is not necessary because Mojo only needs to destroy fields of MyPet.
MyPet dioesn't dynamically allocate memory or use long-lived resources like filehandles.

MyPet includes an Int and a String. Int is a trivial type, String is a mutable object with an internal List buffer field.
This List stores contents in dynamically allocated memory on the Heap. The String itself has no destructor, but the List does, and that's what Mojo calls.

Since String and Int don't require custom destruction, they have no-op destructors (__del__() methods that do nothing).
They are still there because Mojo can always call a destructor, making it easier to write generic library features.
"""

# ========== Benefist of ASAP Destruction ===========
"""
Mojo's ASAP destruction has some benefits over scope-based destruction (like RAII in C++)
    - Composes nicely with the MOVE optimization, which transforms a copy+del into a move
    - Destroying at the end of scop can take performance hits in things like tail recursion, 
        which could pose a memory problem as well for certain functional programming patterns.
In Mojo, destruction always happens before the tail.

ASAP destruction works well with Python style def functions, because Python doesn't provide scopes beyond a function scope.
Meaning the Garbage Collector cleans up more often than a scope-based policy would.
Mojo's ASAP is even more fine-grained than Python's garbage collection.

Mojo's destruction policy is more like Rust and Swift, both having strong value ownership tracking and memory safety.
Rust and Swift both make use of a dynamic "drop flag" (hidden shadow variables that do state tracking of values for safety)
Often optimized away, Mojo drops it altogether, making code faster and less ambiguous.
"""

# ========== Destructor ==========
"""
Mojo calls a value's destructor when the lifetime ends (when it is last used).
Mojo provides a default no-op destructor for all types, and mostly don't need to implement it.

Define the __del__() to perform any kind of cleanup required for a type. Typically, this means freeing mem
for any fields that have memory dynamically allocated to them (e.g. via Pointer or DTypePointer),
and closing any long-lived resources (like filehandles).

Simple structs composed of other types typically don't need a custom __del__().
Consider the following struct:
"""

struct MyPet2:
    var name: String
    var age: Int

    fn __init__(inout self, name: String, age: Int):
        self.name = name
        self.age = age

"""
It's a simple collection of types, and has no dynamically allocated memory, so __del__ is not needed

Below is a struct that does need to define a __del__ method to free memory allocated for its Pointer:
"""

struct HeapArray:
    var data: Pointer[Int]
    var size: Int

    fn __init__(inout self, size: Int, val: Int):
        self.size = size
        self.data = Pointer[Int].alloc(self.size)

        for i in range(self.size):
            self.data.store(i, val)

    fn __del__(owned self):
        self.data.free()

"""
A Pointer doesn't own any values in the meory it points to, so when a Pointer is destroyed, 
Mojo doesn't call the destructor on those values. In the above case that's ok, because Int has a no-op destructor.

In the general case, if you store values that might have functional destructors, free()-ing the Pointer is not enough.
You should ensure Mojo destroys all the allocated types through their destructors.

The example below updates the destructor to ensure the destructors of Array elements are called as well.
This is done by assigning each value to the DISCARD pattern "_". This "_" tells the compiler that it is the last point of use of the value.
"""

struct HeapArray2:
    var data: Pointer[Int]
    var size: Int

    fn __del__(owned self):
        for i in range(self.size):
            _ = __get_address_as_owned_value((self.data + i).address)
        self.data.free()

"""
NOTE:
You can't just call the destructor explicitly. __del__ takes self as an owned value, and those are copied by default.
foo.__del__() creates a copy of foo and destroys that.
In Mojo's hands, it passes the original self instead of a copy.

UnsafePointer: In the case of an UnsafePointer, use destroy_pointee() instead of the dicard "_" pattern.
For example:
"""

struct HeapArray3:
    var data: UnsafePointer[Int]
    var size: Int

    fn __del__(owned self):
        for i in range(self.size):
            destroy_pointee(self.data + i)
        self.data.free()

"""
IMPORTANT:
__del__ provides extra cleanup, and it doesn't override any default destruction behaviour.
Below, Mojo destroys all fields in MyPet regardless of implementing __del__
"""

struct MyPet3:
    var name: String
    var age: Int

    fn __init__(inout self, name: String, age: Int):
        self.name = name
        self.age = age

    fn __del__(owned self):
        # Mojo destroys all fields hen they're last used.
        pass

"""
The self value inside the __del__ is still whole (so all fields still usable) until the destructor returns.
This will be discussed below...
"""

# ========== Field Lifetimes ==========
"""
Aside tracking the lifetime of all objects, Mojo also tracks each field of a struct independently.
This way, Mojo can track fully/partially initialized/destroyed objects, and destroys each field independently.

Consider the following change of a field value:
"""

@value
struct MyPet4:
    var name: String
    var age: Int

fn use_two_strings():
    var pet = MyPet4("Po", 8)
    print(pet.name)
    # pet.name.__del__() runs here, because this instance is no longer used.
    # It's replaced below

    pet.name = String("Lola")   # Overwrite pet.name
    print(pet.name)
    # pet.__del__() runs here

"""
The compiler already knows that pet.name is no longer used, so it calls its destructor before the new assignment.
You can also see this behavior when using the transfer operator:
"""

fn consume(owned arg: String):
    pass

fn use(arg: MyPet):
    print(arg.name)

fn consume_and_use():
    var pet = MyPet("Selma", 8)
    consume(pet.name^)
    # pet.name.__moveinit() runs here, which destroys pet.name
    # Now pet is onlt partially initialized

    # use(pet)  # This would cause a compile error because pet is only partially initialized

    pet.name = String("Lola")   # Fully initialize again
    use(pet)                    # Works now
    # pet.__del__() runs here (only if the object if whole/full)

"""
Ownership of `name` is transferred to consume(), and the compiler knows that pet is only partially initialized.
The name field is later reinitialized before being passed to use().

Additionally, if you don't reinitialize name by the end of the lifetime of pet, Mojo will complain about
destroying a partially initialized object.

So Mojo enforces that objects must be whole at construction and destruction, so the aggregate methods can be used (__init__ & __del__).
This way you need to create and destroy objects with the lifetime methods.
"""

# ========== Field lifetimes during Destruct & Move ==========
"""
The move constructor and destructor for field lifetimes is interesting, because they both take an instance of
their own type as an owned arg, which is about to be destroyed.
It is not a daily concern, but it's good to understand how this works with Field Lifetimes.

As a recap here are the typical move and destruct methods:
struct TwoStrings:
    fn __moveinit__(inout self, owned existing: Self):
        # Initialize a new `self` by consuming the contents of `existing`
    fn __del__(owned self):
        # Destroys all resources in `self`

NOTE:
The 2 types of self:
- Self: Alias for the current type name (used as a type specifier for the `existing` argument)
- self: implicitely passed reference to the current instance (aka this, also implicitly a Self type)

The move constructor and destructor must dismantle the existing/self value that's owned.
This means __moveinit__() implicitly destroys sub-elements of existing to transfer ownership to a new instance.
And __del__() implements the deletion logic for its self.

For this, they both need to own and transform elements of the owned value, and definitely don;t want the original
owned value's destructor to also run. In the case of __moveinit__() you would get a DOUBLE-FREE ERROR,
and in the case of the __del__() you would get an infinite loop.

To solve this, Mojo assumes that their whole values are destroyed when reaching any return from the method.
This means that in this case, the whole object may be used as usual, up until the field values are transferred,
or the method returns.

For example below (in the __del__ can still pass ownership of a field to another function and in the __del__ there's no infinite loop)
"""

fn consume1(owned str: String):
    print("Consumed", str)

struct TwoStrings2:
    var str1: String
    var str2: String

    fn __init__(inout self, one: String):
        self.str1 = one
        self.str2 = String("bar")

    fn __moveinit__(inout self, owned existing: Self):
        self.str1 = existing.str1
        self.str2 = existing.str2

    fn __del__(owned self):
        self.dump() # Self is still whole here
        # Mojo calls self.str2.__del__() since str2 isn't used anymore

        consume(self.str1^)
        # self.str1 has been transferred so it is also destroyed now;
        # `self.__del__()` is not called, avoiding an infinite loop

    fn dump(inout self):
        print("str1:", self.str1)
        print("str2:", self.str2)

fn use_two_strings2():
    var two_strings = TwoStrings2("foo")

# ========== Explicit Lifetimes ==========
"""
So far, we've explored default behavior and how it works. Sometimes though, Mojo cannot predict when a value is last used,
and will destory a value that is still referenced through some other means.

For example:
Building a type with a field that has a Pointer to another field. The compiler cannot reason about this (yet), and thus might destroy
a field when it's technically no longer used, even though another object still holds a Pointer to part of it.
To not break the program, you need to keep the first object alive until you can execute some special logic in the 
destructor or move initializer.

You can force Mojo to keep a value alive up to a certain point by assigning the value to the discard "_" pattern. This will signal
to Mojo the last point of use, making you able to control that point!

For example:
fn __del__(owned self):
    self.dump()     # self is still whole here

    consume(self.obj2^)
    _ = self.obj1
    # Mojo keeps obj1 alive until here, after its "last use"

If consume() refers to some value in obj1, this mechanism ensures it won;t be destroyed until "_" last use.

In other scenario's you can use the Python-style with operator to define a scope. Here,
Mojo will keep the object entered with the with statement alive until the with statement has ended.

with open("my_file.txt", "r") as file:
    print(file.read())
    # Do stuff
    foo()
    # Do more stuff...

# file is destroyed here, after the open() statement.
"""


fn main():
    pets()

    # Field lifetimes:
    use_two_strings()
    consume_and_use()

    # Field lifetimes during destruct & move
    use_two_strings2()