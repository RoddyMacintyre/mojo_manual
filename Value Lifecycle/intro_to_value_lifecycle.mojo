# ========== Introduction ==========
"""
Mojo's ownership model allows you to be safe without memory management.
However, Mojo is designed for systems programming, which often requires manual memory management for custom datatypes.
Mojo allows this!

Mojo has no built-in datatypes with special privileges; all built-in datatypes are implemented as Structs.
You can replace these types yourself by using low-level primitives provided by MILR dialects.

So, you can go under the hood and write unsafe code all you want. And so long you do it according to Mojo's VALUE SEMANTICS,
the programmer using your API doesn't need to think about memory management, and the behavior will be safe & predictable
thanks to VALUE OWNERSHIP.

Summary:
Responsibility of the type author to manage the memory and resources for each value type,
by implementing specific lifecycle methods, like the constructor, copy constructor, move constructor, and destructor, as necessary.

Mojo doesn't have default constructors
Mojo has a trivial no-op destructor for types that don't define a destructor.

The lifecycle methods and how to implement them in accordance with Mojo's VALUE SEMANTICS is explained in this section.
"""

# ========== Lifecycles and Lifetimes ==========
"""
LIFECYCLE:
    - Defined by various dunder methods in a struct. Each lifecycle event is handled by a method, such as the constructor (__init__),
        destructor (__del__), copy constructor (__copyinit__), and move constructor (__moveinit__). 
        This also means that all values from one type share a common lifecycle.

LIFETIME:
    - Span of "time" during program execution in which a value is considered valid. It begins at initialization,
        and ends at destruction (generally from __init__ to __del__).
        No 2 values have the same lifetime, because creation and destruction always occurs at different points in time/execution.

Life begins at initialization until destruction. Mojo destroys a value/object as soon as it's no longer used.
This is called the "ASAP" destruction policy that runs after every sub-expression.

It's hard to track value lifetimes if the value is shared many times across functions/routines. 
Mojo makes it more predictable, partly through VALUE SEMANTICS and VALUE OWNERSHIP.
Alongside these 2 concepts, the VALUE LIFECYCLE completes the lifetime management puzzle;
every value must implement key lifecycle methods that define creation and destruction.
"""