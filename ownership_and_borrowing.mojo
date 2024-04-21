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