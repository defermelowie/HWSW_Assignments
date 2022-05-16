#include "print.h"
#include "counter.h"
#include "xoodyak.h"

struct cyclist cy;

#define MSG_LEN 200
unsigned char *msg = (unsigned char *)"\0\x01\x02\x03\x04\x05\x06\x07\b\t\n\x0b\f\r\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f\x20\x21\"\x23\x24\x25\x26\'\x28\x29\x2a\x2b\x2c\x2d\x2e\x2f\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x3a\x3b\x3c\x3d\x3e\x3f\x40\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4a\x4b\x4c\x4d\x4e\x4f\x50\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5a\x5b\\\x5d\x5e\x5f`\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6a\x6b\x6c\x6d\x6e\x6f\x70\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7a\x7b\x7c\x7d\x7e\x7f\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8a\x8b\x8c\x8d\x8e\x8f\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9a\x9b\x9c\x9d\x9e\x9f\xa0\xa1\xa2\xa3\xa4\xa5\xa6\xa7\xa8\xa9\xaa\xab\xac\xad\xae\xaf\xb0\xb1\xb2\xb3\xb4\xb5\xb6\xb7\xb8\xb9\xba\xbb\xbc\xbd\xbe\xbf\xc0\xc1\xc2\xc3\xc4\xc5\xc6"; // Explicit cast is not necessary but induces awareness
// Msg could be created with Cyberchef {From_Hex, Escape_string}

#define DIGEST_LEN 32
unsigned char digest[DIGEST_LEN];

// For RISC-V
void array_print_hex(unsigned char *array, unsigned int array_len)
{
	for (int i = 0; i < array_len; i++)
	{
		print_hex(array[i], 2);
	}
}

void main(void)
{
	for (int i = 0; i <= MSG_LEN; i += 8)
	{
		// Reset counter
		counter_stop();
		counter_clear();

		// // Print msg
		// print_str("-message:");
		// array_print_hex(msg, MSG_LEN);

		// Start counter
		counter_start();

		// Calculate hash
		cyclist_initialise_hash(&cy);
		cyclist_absorb(&cy, msg, i);
		cyclist_squeeze(&cy, digest, DIGEST_LEN, 0x40);

		// Stop counter
		counter_stop();
		int ctr = counter_get_value();

		// // Print digest
		// print_str("-digest:");
		// array_print_hex(digest, DIGEST_LEN);

		// Print counter
		print_str("-L:");
		print_hex(i, 2);
		print_str("-c:");
		print_hex(ctr, 8);
	}
}
