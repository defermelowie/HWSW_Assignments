#include "print.h"

void main(void)
{
	volatile int i = 6;
	volatile int j = 18;
	int z = i % j; // Use remainder instruction for average calculation
	print_hex(z, 2);
}