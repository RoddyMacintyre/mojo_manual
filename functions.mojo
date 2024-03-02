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


def main():
    greeting = greet("Roddy")
    print(greeting)