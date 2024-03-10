"""
def and fn both have valuable uses. Deciding which one to use is a personal preference, and part art, part science.
"""

# ========== DEF FUNCTIONS ==========
"""
Similar to Python's def (dynamism & flexibility)

Can do optional typing and variable declaration so that compiler knows it's a String!

What to know about def:
    - Args don't require a declared type (are passed as an object,so can be any type)
    - Return types don't need to be declared, and default to object
    - Arguments are mutable (passed by value (declared) or reference(object))
    - Variables don;t need to be declared with var
"""
def greet(name: String) -> String:
    var greeting = "Hello, " + name + "!"
    return greeting

# ========== THE OBJECT TYPE ==========
"""
If you don;t declare the type of an argument or return value in a def func, it becomes an object.
The object type allows for dynamic typing, as it can represent any type in mojo.
Very much Python like, but can create runtime errors upon unexpected types.

Object values are passed using object referencing semantics, 
and is not compatible with argument conventions that enforce value semantics
"""

# ========== FN FUNCTIONS ==========
"""
Provides strict type checking and additional memory safety. Below function looks the same, but fn is more strict:
- Args must specify a type
- Return values must specify a type (except void, defaults to None)
- Args default received as immutable references (read-only, borrowed arg convention)
- Variables must be declared using the var keyword
- If a function raises an exception, must be explicitly declared with the raises keyword

All this prevents runtime errors, and promotes performance because of compile time fixing of types
"""
fn _greet(name: String) -> String:
    var greeting = "Hello" + name + "!"
    return greeting

# ========== OPTIONAL ARGUMENTS ==========
# Argument that includes a default value
# CANNOT DEFINE A DEFAULT FOR AN ARG THAT'S DECLARED AS INOUT!
fn pow(base: Int, exp: Int = 2) -> Int:
    return base ** exp

# ========== KEYWORD ARGUMENTS ==========
# Can pass them in any order (obviously)
fn use_keywords():
    var z = pow(exp=3, base=2)
    print(z)

def main():
    greeting = greet("Roddy")
    print(greeting)