#include "print.h"

void main(void)
{
	volatile int i = 6;
	volatile int j = 18;
	int z = i + j; // Use remainder instruction for average calculation
	z = z >> 1;
	print_hex(z, 2);
}