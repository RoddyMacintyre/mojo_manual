# ========== Intro ==========
"""
When multiple parts of a program need access to the same memory, it becomes difficult to 
track who owns a value and determinewhen it's right to deallocate it.

If you don;t do it right, you can get the following errors:
- use-after-free
- double-free
- memory leak

Mojo helps avoiding this by ensuring there is only one variable that owns
each value at a time, while still allowing you to share references with other functions.
When the lifetime ends, Mojo destroys the value.

Below are the rules that govern this ownership model and how to specify arg conventions 
that define how values are shared into functions
"""

# ========== Argument Conventions ==========
"""
Code quality and perf depends a lot on how functions treat argument values.
Is it received as a unique value or a reference, and is it mutable or immutable?

Mojo attempts to provide full value semantics by default (provides consistend and predictable behavior)
Also need full control over memory optimizations, which require reference semantics.

To safely apply reference semantics, lifetime of every value is tracked, and destroyed at the right time
Achieved by every value having only one owner.

Arg convention specifies whether an argument is mutable or immutable, and whether the func owns the value.
Each convention is defined by a keyword at the beginning of an argument declaration.

- borrowed
    Immutable reference (Read-only)
- inout
    Mutable reference (Read-Write - NOT a copy)
- owned
    function takes ownership (exclusive mutable access). Caller loses acces to the value.
    Caller should transfer ownership to the function (not always what happens, and might instead be a copy)

E.g.
Below function has one mutable reference andone immutable reference.

Sometimes arguments are not declared because every argument has a default convention
depending on if the function is fn or def
    - def: owned by default
    - fn: borrowed by default
"""
fn add(inout x: Int, borrowed y: Int):
    x += y


# ========== Ownership Summary ==========
"""
Fundamental rules for ownership:

- Every value has one owner at a time
- when the lifetime of the owner ends, the value is destroyed

Borrow checker:
Process in the Mojo compiler ensuring unique ownerships for values, 
and also enforces the following memory-dafety rules:

- Cannot create multiple mutable references (inout) for the same value (multi borrows are ok)
FLAG!
- cannot create a mutable reference (inout) if there exists an immutable reference (borrowed)
    for the same value !!!NOT CURRENTLY IMPLEMENTED!!!

Mojo disallows mutable references overlapping with another mutable or immutable reference.
When the lifetime has ended, references become invalid.
Because of this, Mojo can immediately destroy a value when the lifetime ends.
"""


# ========== Immutable Arguments ==========
"""
For an immutable reference, add borrowed keyword.
It's the default for all args in an fn func, but can still explicitly specify it.
Also works with def funcs, but it's not the default.
"""

from tensor import Tensor, TensorShape

def print_shape(borrowed tensor: Tensor[DType.float32]):
    shape = tensor.shape()
    print(shape.__str__())


# ========== Compared to C++ & Rust ==========
"""
Mojo's borrowed is similar to C++ const&, which also avoids a copy and disables mutability in the callee.
It does also differ in 2 important ways:
    - Mojo compiler implements a borrow checker, preventing code from dynamically formin mutable references to a value
        when there are immutable references outstanding, and prevents multiple mutable references to the same value
    - Small values like Int, Float, SIMD, etc are passed directly to machine registers instead of through an extra indirection (@register_passable)
        A significant perf enhancer compared to Rust & C++, and moves the optimization from every call site to a declaration on the type definition

Similar to Rust, Mojo's borrow checker enforces exclusivity of invariants. Mojo doesn;t require a sigil on the caller side to pass by borrow.
Mojo is more efficient when passing small values, and Rust defaults to moving vals and not passing them around by borrow. This provides for an easier programming model.
"""


# ========== Mutable Arguments (inout) ==========
"""
For mutable references add the inout keyword.
It literally means it goes in, and changes go out.
It's the default in def funcs...

!Using inout is more memory efficient because it does not make a copy of the value!

A value passed into inout must already be mutable. A borrowed value will not be able to be passed as an arg.
You will get a compiler error in that case.

!Cannot define defaults for inout!
"""
def mutate(inout y: Int):
    y += 1

# It's equivalent to the following:
def mutate_copy(y: Int) -> Int:
    y += 1
    return y


# ========== Transfer Arguments (owned and ^) ==========
"""
Owned keyword: function can receive value ownership
Usually combined with the ^ (transfer) operator, which ends the lifetime of that variable outside of the function

Technically, owned kw doesn't guarantee that the received value is a mutable reference to the oiriginal value.
It guarantees that the fn gets unique ownership of the particular value (value semantics). 
This unique ownership happens in 2 ways:
    - Caller passes arg with ^ operator, ehich ends lifetime of the variable, and ownership is transferred to the func,
        without making a copy of any heap-allocated data
    - Caller does not use ^. Original variable stays valid and the value is copied into the func arg.

Regardless "owned" args have unique mutable access to the value.

Following code makes a copy of a string, because the caller of the func doesn't include the ^ operator
"""
fn take_text(owned text: String):
    text += "!"
    print(text)

fn my_function():
    var message: String = "Hello"
    take_text(message)
    print(message)

# If you add the ^ transfer operator when calling take_text, you cannot print message again, 
# because the ownership is transferred, and the message variabel becomes invalid.
fn my_function_transfer():
    var message: String = "Hello"
    take_text(message^)


# ========== Transfer Implementation Details ==========
"""
Ownership transfer and move operation are not strictly the same things. 

Multiple ways Mojo tranfers ownership of a value without making a copy:
    - If type is movable (__moveinit__()), Mojo may invoke this method IF a value of that type is 
        transferred into a function as an OWNED argument, AND the original value's lifetime ends at that same point
        (with or without using the ^ operator)
    - If a type hasn't implemented __moveinit__(), Mojo may transfer ownership by simply passing the recipient
        a ref to the val in the caller's stack

For the OWNED to work without the transfer operator ^, the value type must be COPYABLE (__copyinit__())
"""


fn main():
    var a = 1
    var b = 2
    add(a, b)
    print(a)

    # Immutable arguments
    try:
        var tensor = Tensor[DType.float32](256, 256)
        _ = print_shape(tensor)
    except:
        print("Cannot execute print_shape")

    # Mutable arguments
    var x = 1
    var y = 1
    try:
        _ = mutate(x)
        print(x)
        y = mutate_copy(y)
        print(y)
    except:
        print("Cannot execute mutate(_copy)")

    # Transfer args calls. My function makes a copy of the arg from take text, because no ^ operator is used.
    my_function()
    # Here, the transfer is used, and cannot use original message var after transferring it to take_text
    my_function_transfer()