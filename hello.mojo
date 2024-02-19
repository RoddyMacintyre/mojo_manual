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


# Mojo doesn't support top-level code yet. So every program must include a func named main() as an entry point
fn main():
    print("Hello, world!")
    # greet("Roddy")