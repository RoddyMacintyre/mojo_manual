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