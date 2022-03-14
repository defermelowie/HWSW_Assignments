#include "print.h"
#include "counter.h"

void main(void)
{

	unsigned int counter_value;
	volatile unsigned char temp;

	print_str("count: ");
	counter_start();
	for (temp = 0; temp < 10; temp++)
		;
	counter_stop();
	counter_value = counter_get_value();
	print_hex(counter_value, 4);
}
