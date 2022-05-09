#include <stdio.h>
#include "../src/xoodyak.h"

struct cyclist cy;

int main(void)
{
    printf("\n------------------------------------------\n");
    printf("[INFO] Start test program\n");
    cyclist_initialise_hash(&cy);
    xoodoo_permute(&(cy.state), 12);
    printf("[INFO]Test program ended\n");
    printf("------------------------------------------\n");
    return 0;
}