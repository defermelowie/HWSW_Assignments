#include "print.h"
#include "hamming.h"

void main(void)
{
	print_dec(get_hamming_distance(0b11111, 0b10001));
}