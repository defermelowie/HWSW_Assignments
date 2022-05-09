//-------------------------------------------------------------
// Hardware software codesign
//-------------------------------------------------------------
// Course assignments
//
// File: xoodyak.c (c)
// By: Lowie Deferme (UHasselt/KULeuven - FIIW)
// On: 21 April 2022
//-------------------------------------------------------------

#include "xoodyak.h"

/* API */

void cyclist_initialise_hash(cyclist *c)
{
    xoodoo_init_empty_state((xoodoo_state *)&(c->state));
    c->mode = XOODYAK_MODE_HASH; // Hash mode
    c->Rabsorb = XOODYAK_R_ABSORB_HASH;
    c->Rsqueeze = XOODYAK_R_SQUEEZE_HASH;
    c->phase = XOODYAK_PHASE_UP; // Start phase is up
}

void cyclist_absorb(cyclist *c, unsigned char *m, int mlen)
{
    // TODO: create cyclist absorb
}

void cyclist_squeeze(cyclist *c, unsigned char *m, int mlen, unsigned char breadcrumb)
{
    // TODO: create cyclist squeeze
}

#ifdef __linux__

#include <stdio.h>

void cyclist_print(cyclist *c)
{
    printf("Cyclist:\n");
    printf("  Mode: %d (%s)\n", c->mode, (c->mode == XOODYAK_MODE_HASH) ? "Hash" : "Key");
    printf("  Rabsorb: %d\n", c->Rabsorb);
    printf("  Rsqueeze: %d\n", c->Rsqueeze);
    printf("  Phase: %d (%s)\n", c->phase, (c->phase == XOODYAK_PHASE_UP) ? "Up" : "Down");
    printf("  State:\n");
    for (int y = 0; y < XOODYAK_NUMOF_PLANES; y++)
    {
        printf("    Plane %d:", y);
        for (int z = 0; z < XOODYAK_LANESIZE; z++)
        {
            printf("\n      ");
            for (int x = 0; x < XOODYAK_NUMOF_SHEETS; x++)
            {
                printf("0x%x ", c->state[y][x][z]);
            }
        }
        printf("\n");
    }
}
#endif

/* Helpers */
