#include <stdio.h>
#include "../src/xoodyak.h"

struct cyclist cy;

#define MSG_LEN 67
unsigned char *msg = (unsigned char*) "\0\x01\x02\x03\x04\x05\x06\x07\b\t\n\x0b\f\r\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f !\"#$%&\'()*+,-./0123456789:;<=>?@AB";    // Explicit cast is not necessary but induces awareness
// Digest should be: D34341E8B65E06C58AA217E88B392D25AE8E015EFDCC194F7E253BC9D80F2898

#define DIGEST_LEN 32
unsigned char digest[DIGEST_LEN];

// For linux
void array_print_hex(unsigned char *array, unsigned int array_len){
    for (int i = 0; i < array_len; i++){
        printf("%02x", array[i]);
    }
    printf("'\n");
}

int main(void)
{
    printf("\n------------------------------------------\n");
    printf("[INFO] Start test program\n");

    printf("[INFO] message='");
    array_print_hex(msg, MSG_LEN);

    printf("[XOODYAK] Initialize hash\n");
    cyclist_initialise_hash(&cy);
    // cyclist_print(&cy);

    printf("[XOODYAK] Absorb\n");
    cyclist_absorb(&cy, msg, MSG_LEN);
    // cyclist_print(&cy);

    printf("[XOODYAK] Squeeze\n");
    cyclist_squeeze(&cy, digest, DIGEST_LEN, 0x40);
    // cyclist_print(&cy);

    printf("[INFO] digest='");
    array_print_hex(digest, DIGEST_LEN);

    printf("[INFO]Test program ended\n");
    printf("------------------------------------------\n");
    return 0;
}