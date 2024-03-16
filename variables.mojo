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