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