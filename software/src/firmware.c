#include "print.h"
#include "counter.h"

//#define HW_SINE

#ifdef HW_SINE
#include "sine_hw.h"
#define SINE_MODE "HW"
#else
#include "sine_sw.h"
#define SINE_MODE "SW"
#endif

void main(void)
{
	// Reset counter
	counter_stop();
	counter_clear();

	// Calculate sine
	counter_start();
	uint32_t sine = sin(30U);
	counter_stop();

	// Print results
	print_str(SINE_MODE);
	print_str("-sin:");
	print_hex(sine, 8);
	print_str("-ctr:");
	print_hex(counter_get_value(), 3);
}
