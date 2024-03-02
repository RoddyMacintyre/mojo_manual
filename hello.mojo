# ========== Functions ===========
# Can either be declared with fn or def
# fn enforces typechecking a-la Rust/C++
# def behaves like Python would

# Receives arguments by value
def greet(name):
    return "Hello, " + name + "!"


# Provides compile time checks
# Receives arguments by immutable reference
fn greet2(name: String) -> String:
    return "Hello, " + name + "!"


# ========== Variables =========
# can declare vars in 3 ways:
# 1. var (mutable)
# 2. let (immutable)
# 3. if in a def function, can omit both & default to var (fn func must be mutable)
def do_math(x):
    var y = x + x   # y is mutable
    y = y * y
    let z = y + x   # z is immutable
    print(z)


# Alternatively
def add_one(x):
    let y: Int = 1
    print(x + y)


# ========== Structs ==========
# Can build high-level abstrations for types (or objects) as a struct
# Struct is similar to a Python class
# But Mojo structs are completely static (bound at compile time, so no monkey patching, dynamic dispatch, orother runtime changes to the structure)
# Mojo will support Python style classes in the future

# Basic struct:
struct MyPair:
    var first: Int
    var second: Int

    fn __init__(inout self, first: Int, second: Int):
        self.first = first
        self.second = second

    fn dump(self):
        print(self.first, self.second)


# Use MyPAir
fn use_mypair():
    let mine = MyPair(2, 4)
    mine.dump()


# ========== Traits ==========
# Trait is like a template of characteristics for a Struct
# When you use traits, all characteristics of a struct must be from a trait??
# Each characteristic of a trait is a requirement for the struct, aka conform to it
# Currently only method signatures are allowed to be traits, with no default behaviours

# Allows generic functions that can accept any type that conforms to a trait
trait SomeTrait:
    fn required_method(self, x:Int): ...


# Struct conforming to the trait
struct SomeStruct(SomeTrait):
    fn __init__(inout self):
        pass

    fn required_method(self, x: Int):
        print("Hello traits", x)


# A func that uses the trait as an argument type (instead of the struct type)
fn fun_with_traits[T: SomeTrait](x: T):     # Generic function, accepts any Struct that implements the trait SomeTrait
    x.required_method(42)


fn use_trait_function():
    var thing = SomeStruct()
    fun_with_traits(thing)


# ========== Parameterization ==========
# In Mojo, a parameter is a compile-time variable that becomes a runtime constant.
# Declared in square brackets on a func or struct
# Allow compile-time metaprogramming (like a template), generating or modifying code at compile-time

fn repeat[count: Int](msg: String):
    for i in range(count):
        print(msg)


# To call this func, specify both parameter (count) and argument (msg)
fn call_repeat():
    repeat[3]("Hello")

# Count is guaranteed to not change at runtime, so the compiler can optimize for this
# Compiler generates a unique version of repeat, repeating 3 times
# The same principle goes for Structs


# Mojo doesn't support top-level code yet. So every program must include a func named main() as an entry point
fn main():
    print("Hello, world!")
    # greet("Roddy")
    try:
        _ = do_math(3)
    except:
        print("Could not execute do_math")
    
    try:
        _ = add_one(3)
    except:
        print("Could not execute add_one")

    use_mypair()    # Why doesn't it require try/except??

    # Use traits call
    use_trait_function()

    # Call parameterized function (some compiler overhead)
    call_repeat()    