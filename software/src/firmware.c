#include "print.h"

void main(void)
{
	volatile int i = 7;
	volatile int j = 4;
	int z = i * j;
	print_hex(z, 4);
}