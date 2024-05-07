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


fn main():
    pets()
