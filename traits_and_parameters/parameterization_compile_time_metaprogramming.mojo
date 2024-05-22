# ========== Introduction ==========
"""
Metaprogramming generates or mofdifies code. Python has facilities for dynamic metaprogramming,
like decorators and metaclasses. They make Python very flexible, but come with runtime overhead.
Compiled languages might have compile-time metaprogramming, like C preprocessor macros and C++ templates.
Those can be limiting or hard to use.

For the sake of AI, Mojo aims to provide powerful, and usable metaprogramming with zero runtime cost.
This compile-time metaprogramming uses the same language as runtime programs.

The main new Mojo feature is Parameters. Thinnk of them as a compile-time var that becomes a runtime constant.
Unlike in other languages, in Mojo, a parameter is considered as a compile-time value, and argument and expression refer
to runtime values.

In Mojo, you can add parameters to a struct or func, and you can define named parameter expressions (aliases)
that you can use as runtime constants.
"""

# ========== Parameterized Functions ==========
"""
To define a Parameterized func, add parameters in square brackets between then name and the arg list.
Parameters are formatted like and argument: Parameter name, followed by its type [Count: Int].
For example:
"""

fn repeat[count: Int](msg: String):
    @unroll
    for i in range(count):
        print(msg)

"""
@unroll unrolls loops at compile time. It only works if the loop limits are compile-time constants.
In main the Parameterized function is called.

The compiler resolves the Parameter values at compile-time, and creates a concrete version of it
for each unique parameter value. After resolving the Param values, and unrolling the loop, it basically is the following:

fn repeat_3(msg: String):
    print(msg)
    print(msg)
    print(msg)

NOTE:
Above isn't actually code generated by the compiler. After the Params are resolved, Mojo code has already
been transformed to an intermediate MLIR representation.

If the compiler cnnot resolve all Parameters, it fails.
"""

# ========== Parameterized Structs ==========
"""
You can use parameterized structs to build generic containers. 
Below an example of a generic Array type:
"""

struct GenericArray[T: AnyRegType]:
    var data: Pointer[T]
    var size: Int

    fn __init__(inout self, *elements: T):
        self.size = len(elements)
        self.data = Pointer[T].alloc(self.size)

        for i in range(self.size):
            self.data[i] = elements[i]

    fn __del__(owned self):
        self.data.free()

    fn __getitem__(self, i: Int) raises -> T:
        if (i < self.size):
            return self.data[i]
        else:
            raise Error("Out of bounds")

"""
The T is a placeholder for the datatype to store in the Array (a Type parameter). T is typed as AnyRegType.
This is a meta type representing any register-passable type, meaning the Array can hold fixed-size datatypes (e.g. Ints, Flaots)
that can be passed in a machine register. It does not represent dynamically allocated data (Strings, vectors, etc.)

NOTE:
"T" can be anyu name or symbol, it's used as a convention

As with Parameterized funcs,  you need to pass Parameter values when using a Parameterized struct. In the case of the example,
when instantiating the Array, you need to specify the type to store.
T is used throughout the struct where you'd usually see a single type name (e.g. return type of __getitem__).

Besides an AnyRegType, there's a more generic AnyType, which includes all Mojo types.

A parametereized struct can use the Self type to represent a concrete instance of the struct (all Params specified).
You could add a static factory method to create concrete types structs.

@staticmethod
fn splat(count: Int, value: T) -> Self
    # create new array with {count} instances of the given value

GenericArray[Float64].splat(8, 0)
"""

# =========== CASE STUDY: The SIMD type ==========
"""
Single Instruction Multpile Data is a parallel processing technique built into many modern Processors. It allows you to do a
single operation on multiple pieces of data at once.

Processors implement SIMD using low-level vector registers in hardware that hold multiple instancees of a Scalar data type.
The data must be shaped into the proper SIMD width (datatype) and length (vector size). Processors may support 512-bit or longer
SIMD vectors, and support many datatypes (from 8-bit ints to 64-bit floats).

Mojo's SIMD type is defined as a struct, and exposes the common SIMD operations through itsmethods,
and makes the SIMD datatype and values Parametric, allowing you to directly map data to SIMD vectors on any hardware.

Below an abridged version:

struct SIMD[type: DType, size: Int]:
    var value: ... # low-level MLIR stuff...

    # Create new SIMD from a number of Scalars
    fn __init__(inout self, *elems: SIMD[type, 1]): ...

    # Fill SIMD with duplicated Scalar data
    @staticmethod
    fn splat(x: SIMD[type, 1]) -> SIMD[type, size]: ...

    # Cast SIMD elems to different elt type.
    fn cast[target: DType](self) -> SIMD[target, size]: ...

    # Many standard operators are supported
    fn __add__(self, rhs: Self) -> Self

You can create a SIMD vector as follows:

var vector = SIMD[DType.int16, 4](1, 2, 3, 4)
vector = vector * vector
for i in range(4):
    print(vector[i], sep=" ", end="")

prints: 1  4  9  16

As can be seen, * operates on the entire vector at once.
Defining each SIMD variant with Parameters is great for code reuse because the SIMD type ccan express all the different
vector variants statically, in stead of requiring to pre-define every variant.

Because SIMD is Parameterized, the self arg in its functions carry those Parameters (the full type name is SIMD[type, size]).
Although valid to write this out, this can be verbose, so instead using Self is recommended as it does the same.
"""

# ========== Overloading on Parameters ==========
"""
Functions and methods can be overloaded on their PArameters. The overload resolution logic filters for candidates according to the following rule in ordeR:
    1. Minimal number of implicit conversions
    2. Without variadic args
    3. without variadic parameters
    4. shortest parameter signature
    5. Non-@staticmethod over @ststicmethod

If there is more than one candidate, overload resolution fails.
For example:
"""

# Is used in parameters
@register_passable("trivial")
struct MyInt:
    """A type that is implicitly convertible to `Int`"""
    var value: Int

    @always_inline("nodebug")
    fn __init__(_a: Int) -> Self:    # Why is this returned here?
        return Self {value: _a}

# Some overloading
fn foo[x: MyInt, a: Int]():
    print("foo[x: MyInt, a: Int]")

fn foo[x: MyInt, a: MyInt]():
    print("foo[x: MyInt, a: MyInt]")

fn bar[a: Int](b: Int):
    print("bar[a: Int](b: Int)")

fn bar[a: Int](*b: Int):
    print("bar[a: Int](*b: Int)")

fn bar[*a: Int](b: Int):
    print("bar[*a: Int](b: Int)")

fn parameter_overloads[a: Int, b: Int, x: MyInt]():
    # foo[x: MyInt, a: Int]() is called because it requires no implicit conversions
    # foo[x: MyInt, y: MyInt] does require implicit conversion.
    foo[x, a]()

    # bar[a: Int](b: Int) is called because it does not have variadic args or params
    bar[a](b)

    # bar[*a: Int](b: Int) is called because it has variadic params
    bar[a, a, a](b)

# Another example with a struct
struct MyStruct:
    fn __init__(inout self):
        pass

    fn foo(inout self):
        print("Calling instance method")
    
    @staticmethod
    fn foo():
        print("Calling static method")

fn test_static_overload():
    var a = MyStruct()
    # foo(inout self) is called because it's not @staticmethod
    a.foo()

fn main():
    repeat[3]("Hello")

    # Parameterized Structs
    var gen_arr = GenericArray[Int](1, 2, 3, 4)
    try:
        for i in range(gen_arr.size):
            print(gen_arr[i], sep=" ", end="")
    except:
        print("Errrrrrr")

    # Overloading Parameters
    parameter_overloads[1, 2, MyInt(3)]()
    test_static_overload()