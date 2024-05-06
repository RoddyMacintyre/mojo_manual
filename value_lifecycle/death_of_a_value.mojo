# ========== Introduction ===========
"""
If a value/obj is no longer used, Mojo destroys it immediately and doesn't wait for an end in a code block or expression.
Destruction is on an ASAP basis that runs every sub-expression (even in a+b+c+d, a could be destroyed before d is evaluated).

To achieve this, Mojo uses static compiler analysis to identify when a value is last used, and immediately calls the __end__ method.

Notice when __del__() is called in the following struct and its instances:
"""

@value
struct MyPet:
    var name: String
    var age: Int

    fn __del__(owned self):
        print("Destruct", self.name)


fn pets():
    var a = MyPet("Loki", 4)
    var b = MyPet("Sylvie", 2)
    print(a.name)
    # a.__del__() runs hier for "Loki"

    a = MyPet("Charlie", 8)
    # a.__del__() runs immediately because "Charlie" is never used

    print(b.name)
    # b.__del__() runs here

"""
Each initialization is matched with a destructor, and a is actually destroyed multiple times (once for every new value).
This __del__ actually doesn't do anything but expose its calls. Mojo adds a no-op destructor if you don;t define one yourself.
"""

fn main():
    pets()
