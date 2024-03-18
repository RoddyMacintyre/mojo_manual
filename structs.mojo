# ========== STRUCTS ==========
"""
A structure that allows encapsulation of fields and methods that operate on an abstraction

Fields:
Data relevant to the struct

Methods:
Functions inside a struct that generally act upon the Field data

E.g. for a graphics app, you can define an Image struct that stores info about each image

In Mojo, a struct is designed to be
- Static
- Memory safe
- High level data types

All data types in Mojo (Int, Bool, String, Tuple) are Structs

Def and fn are both valid for Structs, but you do need to declare all Fields with "var"
"""

# ========== Struct Definition ==========
# Example:
struct MyPair:
    var first: Int
    var second: Int

# This struct has no constructor, so cannot create an instance
struct MyPairInit:
    var first: Int
    var second: Int

    fn __init__(inout self, first: Int, second: Int):
        # inout makes self a mutable reference
        # You need to initialize all declared fields, or it will not compile
        self.first = first
        self.second = second

# ========== Methods ==========
# can add methods freely, aside from dunder methods.
# Methods referencing self are called instance methods because they act on an instance of a struct
struct MyPairMethods:
    var first: Int
    var second: Int

    fn __init__(inout self, first: Int, second: Int):
        self.first = first
        self.second = second

    fn get_sum(self) -> Int:
        # Self is referenced to get the Struct's fields out.
        return self.first + self.second

fn main():
    # Instantiating a struct:
    var mine = MyPairInit(2, 4)
    print(mine.first)

    var mine2 = MyPairMethods(6, 8)
    print(mine2.get_sum())