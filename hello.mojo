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