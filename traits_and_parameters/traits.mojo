# ========== Introduction ==========
"""
A trait is a set of requirement that a type must implement (like a prototype).
Think of it as a contract: a type that conforms to a trait, guarantees that it implements all of the features of the trait.

Traits in other languages:
Java - Interface
C++ - Concept
Swift - Protocol
Rust - Trait
"""

# ========== Background ==========
"""
In dynamically typed languages like Python, you don;t need to explicitly declare that 2 classes are similar.

For example:
%%python
class Duck:
    def quack(self):
        print("Quack.")

class StealthCow:
    def quack(self):
        print("Moo!")

def make_it_quack_python(maybe_a_duck):
    try:
        maybe_a_duck.quack()
    except AttributeError:
        print("This thing doesn't quack.")

make_it_quack_python(Duck())
make_it_quack_python(StealthCow())

The Duck and StealthCow classes are not related, but since both define a quack() method, they can both be used 
in make_it_quack_python(). This is because Python uses dynamic dispatch (identify methods to call at runtime).
make_it_quack_python() doesn;t care what types are passed to the function, as long as they have a quack() method.

VS. STATICALLY TYPED LANGUAGES
The above approach doesn't work in case of statically typed languages. In Mojo, doing so without Traits, 
you'd need to write a function overload for each input type.

For example:
"""

@value
struct Duck:
    fn quack(self):
        print("Quack")

@value 
struct StealthCow:
    fn quack(self):
        print("Moo!")

fn make_it_quack(definitely_a_duck: Duck):
    definitely_a_duck.quack()

fn make_it_quack(not_a_duck: StealthCow):
    not_a_duck.quack()

fn main():
    make_it_quack(Duck())
    make_it_quack(StealthCow())

"""
This will get out of hand when defining a lot of types.
Notice that in Mojo versions of make_it_quack(), we don;t include the try/except statement.
It is not needed because of Mojo's static type checking. The compiler enforces that the inputs
are of the correct type before running the program.
"""