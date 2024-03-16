"""
Variable is a name that holds a value or an object.
All vars are mutable in Mojo (design problem, want immutable as standard)

let has been removed to signify an immutable variable
"""

# ========== Undeclared Variables ==========
"""
Within a def func of REPL, can create a variable with just a name & val
name = "Sam"
They are not allowed in a fn or Struct field
"""

# ========== Declared Variables ==========
"""
Can declare a variable with the var keyword
e.g. 
var name = "Sam"    -> Initialized
var user_id: Int    -> Uninitialized

All declared variables are types, either implicit or explicit with annotation
Can't assign variable a value of a different type, unless the types can be implicitly converted
This will not compile:
var user_id: Int = "Sam"

Declared vars also follow lexical scoping, unlike undeclared vars

Using var helps prevent runtime errs caused by typos.
Example: if you misspell name of undeclared var, mojo instantiates a new var for it. 
But when mutable vars must first be declared with var, misspellings like below are caught by the compiler

var name = "Same"
nane = "Sammy"  # This is not allowed in an fn func

Can use var in a def func, but the benifits stated above drop.
"""

# ========== Type Annotations ==========
"""
Mojo supports dynamic and static type annotations on variables, enabling strong compile-time checking.
Makes code more predictable, manageable, and secure

var name: String = "Sam"    # name now must always be a String or anything implicitly convertable to a String
Must use var for type annotations

If a type has a constructor with 1 arg, can initialize in 2 ways:
var name1: String = "Sam"
var name2 = String("Sam")

Both create a string from a StringLiteral type
"""

# ========== Late Initialization ==========
"""
Type annotations allow for late initialization; declare with type but no concrete value.
e.g.

fn my_function(x: Int):
    var z: Float32
    if x != 0:
        z = 1.0
    else:
        z = foo()
    print(z)

fn foo() -> Float32:
    return 3.14
"""