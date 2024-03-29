# from mypackage.mymodule import MyPair
# from mypack.mymodule import MyPair
# Above 2 commands both have the same effect.

# After adding MyPAir to the package __init__:
from mypackage import MyPair 

fn main():
    var mine = MyPair(2, 4)
    mine.dump()