#include "print.h"
#include "counter.h"
#include "xoodyak.h"

struct cyclist cy;

#define MSG_LEN 67
unsigned char *msg = (unsigned char*) "\0\x01\x02\x03\x04\x05\x06\x07\b\t\n\x0b\f\r\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f !\"#$%&\'()*+,-./0123456789:;<=>?@AB";    // Explicit cast is not necessary but induces awareness
// Msg could be created with Cyberchef {From_Hex, Escape_string}
// Digest should be: D34341E8B65E06C58AA217E88B392D25AE8E015EFDCC194F7E253BC9D80F2898

#define DIGEST_LEN 32
unsigned char digest[DIGEST_LEN];

// For RISC-V
void array_print_hex(unsigned char *array, unsigned int array_len){
    for (int i = 0; i < array_len; i++){
        print_hex(array[i], 2);
    }
}

void main(void)
{
	// Reset counter
	counter_stop();
	counter_clear();

	// Print msg
	// print_str("-message:");
	// array_print_hex(msg, MSG_LEN);

	// Start counter
	counter_start();

	// Calculate hash
	// cyclist_initialise_hash(&cy);
	//cyclist_absorb(&cy, msg, MSG_LEN);
	//cyclist_squeeze(&cy, digest, DIGEST_LEN, 0x40);

	// Xoodoo debugging
	xoodyak_state s;
	xoodoo_init_empty_state(&s);
    for (int z = 0; z < XOODOO_LANESIZE; z++)
    {
        for (int y = 0; y < XOODOO_NUMOF_PLANES; y++)
        {
            for (int x = 0; x < XOODOO_NUMOF_SHEETS; x++)
            {
                s[y][x][z] = x + 0x10 * y; // Note: change xoodoo state to non zero
            }
        }
    }
	xoodoo_permute(&s, 12);

	// Stop counter
	counter_stop();
	int ctr = counter_get_value();

	// Print digest
	// print_str("-digest:");
	// array_print_hex(digest, DIGEST_LEN);

	// Print counter
	// print_str("-counter:");
	// print_hex(ctr, 8);
}
