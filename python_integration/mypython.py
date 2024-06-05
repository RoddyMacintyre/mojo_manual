import numpy as np 


def gen_random_values(size, base):
    # Generate a size * size array of random numbers between base and base+1
    random_array = np.random.rand(size, size)
    return random_array + base