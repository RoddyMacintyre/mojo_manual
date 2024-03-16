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

# ========== VARIADIC ARGUMENTS ==========
"""
Lets function accept a variable number of arguments.
Variadic syntax: *argument_name
It accepts any number of passed positional arguments.
Can define 0 or more args before the variadic arg. 
Any remaining positional args will be assigned to the variadic arg
Any args after it have to be keyword args.

NO VARIADIC KWARGS YET! ALSO NO MULTITYPE VARIADIC ARGS.

Print does support mixed type variadics, but requires working with undocumented MLIR APIs

Variadic args are projected to iterable lists. 
Some differences in handling between register-passable types (e.g. Int -> VariadicList) 
and memory-only types (String -> VariadicListMem (refs instead of values, need to dereference with []))
"""
fn sum(*values: Int) -> Int:
    var sum: Int = 0
    # Account for all the Ints in the variadic arg
    for value in values:
        sum = sum + value
    return sum

fn make_worldly(inout *strs: String):
    # Need [] to dereference
    for i in strs:
        i[] += " world"

fn _make_worldly(inout *strs: String):
    # Works as expected in Py
    for i in range(len(strs)):
        strs[i] += " world"

# ========== POSITIONAL-ONLY & KEYWORD-ONLY ARGS ==========
"""
Restrict args to positional only, or keyword only

Positional-only:
To define them, add a / to the argument list. Arguments before the / are positonal only, and cannot be passed as keyword

for example:
fn min(a: Int, b: Int, /) -> Int:
    return a if a < b else b

Reasons for  positional-only:
- arg names are not meaningful
- Freedom to change arg names later on without breaking code

Keyword-only
Inverse of positonal-only, can only be specified by a keyword. 
If func accepts variadic args, everything after the variadics are keyword-only
keyword-only args often have a default, but is not required. If it hasn;t got a default, it's a required keyword-only arg

for example:
fn sort(*values: Float64, ascending: Bool = True)

Or without variadic args, can signify keyword-only with a *

fn kw_only_args(a1: Int, a2: Int, *, double: Bool) -> Int:
    var product = a1 * a2
    if double:
        return product * 2
    else:
        return product

"""

def main():
    greeting = greet("Roddy")
    print(greeting)