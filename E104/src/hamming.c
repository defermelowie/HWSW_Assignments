#include "hamming.h"

unsigned int get_hamming_weight(unsigned int x)
{
    return __builtin_popcount(x);
}

unsigned int get_hamming_distance(unsigned int x, unsigned int y)
{
    unsigned int z = x ^ y;
    return __builtin_popcount(z);
}