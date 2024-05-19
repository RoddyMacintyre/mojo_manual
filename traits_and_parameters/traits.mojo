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

"""
This will get out of hand when defining a lot of types.
Notice that in Mojo versions of make_it_quack(), we don;t include the try/except statement.
It is not needed because of Mojo's static type checking. The compiler enforces that the inputs
are of the correct type before running the program.
"""

# ========== Using Traits ==========
"""
Traits solve the problem for dynamic dispatch in statically typed languages.
It lets you define a shared set of behaviors that types can implement. Then you can write functions
that depend on a trait, rather than a specific type. For example, let's update make_it_quack() using Traits.

Step 1: Define the trait
trait Quackable:
    fn quack(self)
    ...

A trait looks like a struct, except it's introduced by the trait keyword. For now, a trait can only contain method signatures,
and not method implementations.
Each method sig should be followed by ... to indicate that it's not implemented.

FUTURE: Support for defining fields and implementations is on the menu

Step 2: Create structs conforming to the Quackble trait.
To indicate conformance to a trait, include the trait name in parenthesis after the struct name.
You can include multiple traits, separated by a comma.
"""
trait Quackable:
    fn quack(self):
        ...

@value
struct Duck1(Quackable):
    fn quack(self):
        print("Quack.")

@value
struct StealthCow1(Quackable):
    fn quack(self):
        print("Moo!")

"""
The struct implementing the traits needs to declare all methods of the traits. The compiler enforces this.

Step 3: Define a function that takea a Quackable.
"""

fn make_it_quack_1[T: Quackable](maybe_a_duck: T):
    maybe_a_duck.quack()

"""
The syntax has to do with Mojo parameters. It means that maybe_a_duck is an argument of type T, where T is
a type that implements the Quackable trait.

NOTE:
You don;t need square brackets to call make_it_quack_1; the compiler infers the arg type, and enforces the trait.

LIMITATION:
You can't add traits to existing types, like adding traits to Float64, or Int. However,
the STL (Standard Type Library) already includes a few traits and more will be added.
"""

# ========== Traits can require Static Methods ==========
"""
Traits can specify required static methods. For example:
"""
# trait HasStaticMethod:
#     @staticmethod
#     fn do_stuff(self):
#         ...

# fn fun_with_traits[T: HasStaticMethod]():
#     T.do_stuff()

# ========== Implicit Trait Conformance ==========
"""
Mojo support implicit trait conformance. This means that even if a type doesn;t explicitly implement at trait,
if it has all the methods of said trait, it's treated as conforming to the trait.
For example:
"""

@value
struct RubberDucky:
    fn quack(self):
        print("Squeak!")

"""
This can be handy if you define traits that you want to work with types that you don't control (like STL/3rd party types).
It is recommended to always do trait conformance explicitly. It has the following advantages:

    - Documentation/readability; it's clear it implements the trait
    - Future feature support; when default method implementations are added to traits, they'll onlt work for explicitly conforming types.
"""


fn main():
    make_it_quack(Duck())
    make_it_quack(StealthCow())

    # Traits
    make_it_quack_1(Duck1())
    make_it_quack_1(StealthCow1())

    # Implicit trait conformance
    make_it_quack_1(RubberDucky())
