# ========== Intro to Value Ownership ==========
"""
All languages store data in one of the following places:
- Call stack
- Heap
- Sometimes in CPU registers

How languages read and write their data from- and to these structures is different.
"""

# ========== Stack and Heap overview =========
"""
In general, all languages use the call stack in the same way:
    - Function call
    - Compiler allocates an exact block of memory on the stack corresponding to the function size (but only including fixed-size local values)
    - Another function call gets stacked on top of the previous one
    - Function done: all data is destroyed from the stack, and memory released

Heap:
    - Dynamically sized values are stored on the Heap
    - Much larger region of memory, allowing dynamic access at runtime
    - A pointer for the value is stored in the stack, and the actual value is stored in the Heap

    - Values that need to outlive a call are stored in the Heap as well
    - Heap memory is accessible from everywhere in the call stack

Above last 2 points is where most of the memory errors occur, and where memory management strategies vary between languages
"""

# ========== Memory Management Strategies ==========
"""
Important that programs remove unused data from teh heap (the free memory) as quickly as possible.

- Garbage collection
Tracks all mem usage & deallocates unused heap memory periodically. 
Releives developers from the burden of manual mem management, and thereby avoiding a specific class of memory errors.
Incurs a performance cost, because the gc interrupts program execution.

- Manual mem management
Execute quicker because hte mem management is controlled. 
Is prone to errors, because data ownership is hard to track, causing errors like "use-after-free", memory leaks and "double-free". 
These errors are hard to track down.

- Mojo Memory Management
Ownership model, which relies on a collection of rules on passing values.
These rules ensure singular ownership for defined chunks of memory at any one time.
By following these rules, Mojo can automatically (de)allocate heap memory.

To achieve this goal, there are some new syntax elements and rules.
"""

# ========== VALUE SEMANTICS ==========
"""
Mojo doesn;t enfore value semantics or reference semantics, but does support them both.
Each type can define how it is created, copied, moved, and destroyed.
Mojo is designed with arg behaviors that default to value semantics, and has tight control over ref semantics to avoid mem errors

Value Ownership Model
Provides the controls over reference semantics. Value semantics menas that each var has unique access to a val
and any code outside its scope cannot modify its value
"""

# ========== Intor to Value Semantics ==========
"""
Sharing a value-semantic type means that you create a copy of the value (aka "pass by value")
e.g.

x = 1   # 1, and stays one
y = x   # 1, x is copied as a value
y += 1  # 2

Value semantics example with a function:
def add_one(y: Int):    # y value is copied, and x is not modified.
    y += 1
    print(y)    # Prints 2

x = 1
add_one(x)
print(x)        # Prints 1


In reference Semantics, y would point to the same value as x, in effect incrementing one value referenced by 2 variables.
Neither x nor y owns the value, and any var can ref and mutate the value.

Python is not value semantic even though it behaves the same as above. 
Imagine calling a Python function, and pass it an object with a pointer to a heap-allocated value.
Python gives the function a reference to that object, making the function able to mutate the heap-allocated value.

In Mojo, the default is value semantics for all func args. If a func wants to do mutations, it must be explicit about it.
All Mojo types passed to a def are passed by value, except the function has true ownership of the value (usually a copy).

Example passing an object from the heap:
def update_tensor(t: Tensor[Dtype.uint8]):
    t[1] = 3
    print(t)        # Tensor([[1, 3]], dtype=uint8, shape=2)

t = Tensor[DType.uint8](2)
t[0] = 1
t[1] = 2
update_tensor(t)
print(t)            # Tensor([[1, 2]], dtype=uint8, shape=2)

# In the above func, in Python it would print 1, 3 in both cases
"""

# ========== Value Semantics in def VS fn ==========
"""
Def funcs get ownersip of args by default.
Fn funcs receive args as immutable references by default (mem optimization to avoid copies).

e.g.
fn add_two(y: Int):
    # Make an explicit copy, to get ownership of y
    var z = y
    z += 2
    print(z)    # Prints 3

x = 1
add_two(x)
print(x)        # Prints 1

Each var maintains unique ownership of its value. The fn func receives a value in a "look but don't touch" manner.
So, both def and fn are fully value semantic; args are either copies or immutable references.

BUT: For memory efficient programs, reference semantics are basically required. 
This has to be implemented in a way that does not disturb the value semantics' predictability and safety.
To achieve this in Mojo, every value is ensured to have an "exclusive owner", and not that every var has "exclusive access".
And also Mojo destroys each value when the lifetime of its owner has ended.

"""

# ========== Python-style Reference Semantics ==========
"""
NOTE: Following only applies to def functions without type declarations

Mojo doesn't enforce value semantics or reference semantics. 
To provide Python compatibility, Mojo's object type is designed to support Python style
of argument passing to funcs/meths. This is different from Mojo's other types.

Python arg passing is by reference. You pass the reference to an object, as a value.
In effect the arg is an alias to the original object. However, if you modify the arg, you modify the original

def modify_list(l):
    l.append(3)
    print("func:", 1)

ar = [1, 2]
modify_list(ar)
print("orig:", ar)

If the python func instead assigns a value to l, the original object is not affected.
So, Python can mutate the original value, or assign a completely new object to the argument
"""

# ========== Pass by Object Reference in Mojo ==========
"""
Pass by object reference for def functions for all dynamic types will come to Mojo soon with the object type.
Meaning you can have dynamic typing and "pass by object reference" behavior by writing it like Python:
- Use def declarations
- Don't declare argument types

NOTE: Mojo is not yet a complete superset of Python.
DOCUMENTATION WILL FOLLOW
"""