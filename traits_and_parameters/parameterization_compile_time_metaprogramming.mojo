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

# ========== Using Parameterized types and Functions ==========
"""
You can instantiate Parametric types and functions by passing values to the parameters in [].
E.g. For the SIMD type above, type specifies the data type, and size specifies the length of the SIMD vector (power of 2).

var small_vec = SIMD[DType.float32, 4](1.0, 2.0, 3.0, 4.0)

# Make a big vector containing 1.0 in float16 format
var big_vec = SIMD[DType.float16, 32].splat(1.0)

# Do some math and convert the elements to float32
var bigger_vec = (big_vec+big_vec).cast[DType.float32]()

# You can write types out explicitly if you want
var bigger_vec: SIMD[DType.float32, 32] = bigger_vec

print('small_vec type:', small_vec.element_type, 'length: ', len(small_vec))
print('bigger_vec2 type:', bigger_vec2.element_type, 'length: ', len(bigger_vec2)

PRINTS:
small_vec_type: float32 length: 4
bigger_vec2 type: float32 length: 32

NOTE:
cast() also needs a parameter to specify the type you want to cast to (target Parametric value).
So, just as SIMD is a generic Type definition, cast is a generic method definition that gets instantiated
at compile-time instead of runtime, based on the parameter value.

The code above shows use of concrete types, but the major power of Parameters comes from the ability
to defin Parametric algorithms and Types (code that uses the parameter values).

e.g. here's how to define a parametric algorithm with SIMD that is type- and width- agnostic:
"""

from math import sqrt

fn rsqrt[dt: DType, width: Int](x: SIMD[dt, width]) -> SIMD[dt, width]:
    return 1 / sqrt(x)

"""
The x argument is actually a SIMD type, based on the func params. The runtime program can use the value
of the params, because the params are resolved at compile-time before they are needed by the program.
Compile-time parameter expressions, however, cannot use runtime values.

NOTE:
Above function is able to call the parametric sqrt[]() func without specifying the parameters - the compiler
infers its parameters based on the parametric x value passed into it, as if you wrote sqrt[dt, width](x) explicitly.

NOTE:
rsqrt() chose to name its second parameter width, eventhough the SIMD type names it size, and that's not a problem.
"""

# ========== Optional Parameters and Keyword Parameters ==========
"""
You can define optional parameters by giving it a default value. You can also pass parameters by keyword arguments.
This way for a function or struct with params, you can specify the parameter you wish to pass and keep the rest as defaults.

e.g.:
"""
fn speak[a: Int = 3, msg: StringLiteral = "woof"]():
    print(msg, a)

fn use_defaults() raises:
    speak()
    speak[5]()
    speak[7, "meow"]()
    speak[msg="baa"]()

"""
When a parametric function is called, Mojo can infer the values; it can use the parameter values attached to an
argument value (see the sqrt[]() example).
If the parametric func also has a default value defined, then the inferred parameter type takes precedence.

E.g. in the follwing code, we update speak[]() to take an argument with a paremtric type. Although it has a default 
parameter value for a, Mojo instead uses the inferred a parameter value from the bar argument.
"""

@value
struct Bar[v: Int]:
    pass

fn foo[a: Int = 3, msg: StringLiteral = "woof"](bar: Bar[a]):
    print(msg, a)

fn use_inferred():
    foo(Bar[9]())   # prints "woof 9"

"""
You can also use optional parameters and kwargs in a struct:
"""
struct KwParamStruct[greeting: String = "Hello", name: String = "🔥mojo🔥"]:
    fn __init__(inout self):
        print(greeting, name)

fn use_kw_params():
    var a = KwParamStruct[]()
    var b = KwParamStruct["World"]()
    var c = KwParamStruct[greeting="Hola"]()

"""
NOTE:
Mojo supports positional-only and keyword-only parameters, following the same rules as positional-only and keyword-only arguments.
"""

# ========== Variadic Parameters ==========
"""
Example of variadic parameters:
"""
struct MyTensor[*dimensions: Int]:
    pass

"""
Variadic parameters currently have some limitations as opposed to variadic arguments:
    - Must be homogeneous (same Types)
    - Must be register-passable
    - The values are not automatically projected into a VariadicList, so you need to construct it explicitly

NOTE:
Variadic kw parameters are not supported yet.
"""
fn sum_params[*values: Int]() -> Int:
    alias list = VariadicList(values)
    var sum = 0
    
    for v in list:
        sum += v

    return sum


# ========== Parameter Expressions (are just Mojo code) ==========
"""
A parameter expression is any expression where a parameter is expected. They support operators and function calls,
just like runtime code, and all parameter types use the same type system as the runtime program (like Int, DType, etc.)

Because they use the same grammar and types as runtime Mojo, you can use many "dependent type" features.
E.g. A helper function to concatenate 2 SIMD vectors:
"""

fn concat[ty: DType, len1: Int, len2: Int](
    lhs: SIMD[ty, len1], rhs: SIMD[ty, len2]) -> SIMD[ty, len1+len2]:

    # Resulting len is nothing more than the sum of the input vector lengths, expressed with a + operator.
    var result = SIMD[ty, len1 + len2]()

    for i in range(len1):
        result[i] = SIMD[ty, 1](lhs[i])
    
    for j in range(len2):
        result[len1 + j] = SIMD[ty, 1](rhs[j])
    
    return result


# ========== Powerful Compile-time Programming ==========
"""
While simple expressions are useful, sometimes you need imperative compile-time logic with control flow.
Can even do compile-time recursion.

E.g. Here's a "tree reduction" algorithm that sums all elements of a vector recursively into scalar:
"""

fn slice[ty: DType, new_size: Int, size: Int](
    x: SIMD[ty, size], offset: Int) -> SIMD[ty, new_size]:
    var result = SIMD[ty, new_size]()

    for i in range(new_size):
        result[i] = SIMD[ty, 1](x[i + offset])
    
    return result

# The recusrive function:
fn reduce_add[ty: DType, size: Int](x: SIMD[ty, size]) -> Int:
    # Use @parameter to create a parametric if condition (compile-time if)
    # Condition needs to be a valid parameter expression, and ensures only the live branch is
    # compiled into the program.
    @parameter
    if size == 1:
        return int(x[0])
    elif size == 2:
        return int(x[0]) + int(x[1])
    
    # Extract the top/bottom halves, add, and sum the elements
    alias half_size = size // 2
    var lhs = slice[ty, half_size, size](x, 0)
    var rhs = slice[ty, half_size, size](x, half_size)

    return reduce_add[ty, half_size](lhs + rhs)


# ========== Mojo Types are just Parameter Expressions ==========
"""
Type annotations themselves can be arbitrary expressions (just like in Python).
Types in Mojo have a special Metatype Type, allowing type-parametric algorithms and functions to be defined.

E.g. A simplified Array that supports arbitrary types of elements (AnyRegType parameter):
"""

struct Array[T: AnyRegType]:
    var data: Pointer[T]
    var size: Int

    fn __init__(inout self, size: Int, value: T):
        self.size = size
        self.data = Pointer[T].alloc(self.size)

        for i in range(self.size):
            self.data[i] = value

    fn __getitem__(self, i: Int) -> T:
        return self.data[i]

    fn __del__(owned self):
        self.data.free()

"""
NOTE:
The T parameter is being used as the formal type for the VALUE arguments and the return type of __getitem__().
Parameters allow the Array type to provide different APIs based on different use-cases.

Many cases benefit from advanced Parameter usage, e.g. execute a closure n times in parallel,
feeding in a value from the context as follows:
"""
fn parallelize[func: fn(Int) -> None](num_work_items: Int):
    # Not actually parallel, see the algorithm module for a real impl.
    for i in range(num_work_items):
        func(i)

"""
Another important example is variadic generics, where an algorithm or datastructure may need to be defined over
a list of heterogeneous types, such as for a tuple.
It is not yet fully supported in Mojo, and requires some MLIR tweaking by hand. It's scheduled for the future!
"""

# ========== ALIAS: named parameter expressions ==========
"""
It's common to name cimpile-time values. Var defines a runtime value, ALIAS defines a compile-time value.

E.g. the DType struct implements a simple enum using aliases for the enumerators:

struct DType:
    var value: UInt8
    alias invalid = DType(0)
    alias bool = DType(1)
    alias int8 = DType(2)
    alias uint8 = DType(3)
    alias int16 = DType(4)
    alias uint16 = DType(5)
    ...
    alias float32 = DType(15)

The above allows a client to use DType.float32 as a parameter expression (also works as a runtime value) naturally.
NOTE: This is invoking the runtime constructor for DType at compile-time.

Types are another common use for aliases. Because Types are compile-time expressions, 
it's handy to do things like the following:

alias Float16 = SIMD[DType.float16, 1]
alias UInt8 = SIMD[DType.uint8, 1]

var x: Float16    # Floatq16 works like a "typedef"

NOTE:
Aliases also obey scope, so you can use local ALIASES.
"""

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

    # Parametered types and functions
    var v = SIMD[DType.float16, 4](42)
    print(rsqrt(v))

    # Optional & kw params
    try:
        _ = use_defaults()
    except:
        print("Could not execute function")

    use_inferred()
    use_kw_params()

    # Parameter Expressions (are just Mojo code)
    var a = SIMD[DType.float32, 2](1, 2)
    var x = concat[DType.float32, 2, 2](a, a)

    print('Result type: ', x.element_type, '\tLength: ', len(x))

    # Powerful Compile-time Programming
    var y = SIMD[DType.index, 4](1, 2, 3, 4)
    print(y)
    print("Elements sum: ", reduce_add(y))

    # Mojo Types are just Parameter Expressions
    var w = Array[Float32](4, 3.14)
    print(w[0], w[1], w[2], w[3])