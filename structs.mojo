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