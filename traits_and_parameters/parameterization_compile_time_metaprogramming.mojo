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