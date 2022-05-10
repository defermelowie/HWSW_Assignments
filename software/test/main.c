#include <stdio.h>
#include "../src/xoodyak.h"

struct cyclist cy;

#define MSG_LEN 16
unsigned char *msg = (unsigned char*) "\0\x01\x02\x03\x04\x05\x06\x07\b\t\n\x0b\f\r\x0e\x0f";    // Explicit cast is not necessary but induces awareness

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