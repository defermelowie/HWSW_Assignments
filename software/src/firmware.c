#include "print.h"

void main(void)
{
	volatile int i = 6;
	volatile int j = 13;
	int z = i % j;
	print_hex(z, 2);
}