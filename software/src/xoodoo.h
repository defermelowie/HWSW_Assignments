//-------------------------------------------------------------
// Hardware software codesign
//-------------------------------------------------------------
// Course assignments
//
// File: xoodoo.h (c)
// By: Lowie Deferme (UHasselt/KULeuven - FIIW)
// On: 21 April 2022
//-------------------------------------------------------------

#ifndef XOODOO_H
#define XOODOO_H

// SOURCE: https://eprint.iacr.org/2018/767.pdf#6
#define XOODOO_NUMOF_SHEETS 4 // The maximum X coordinate is 4
#define XOODOO_NUMOF_PLANES 3 // The maximum Y coordinate is 3
#define XOODOO_LANESIZE 4     // The maximum Z coordinate is 4

// Define round constants
// SOURCE: https://eprint.iacr.org/2018/767.pdf - Table 5
#define XOODOO_ROUND_CONSTANTS { \
    0x00000058,                  \
    0x00000038,                  \
    0x000003C0,                  \
    0x000000D0,                  \
    0x00000120,                  \
    0x00000014,                  \
    0x00000060,                  \
    0x0000002C,                  \
    0x00000380,                  \
    0x000000F0,                  \
    0x000001A0,                  \
    0x00000012}

// Define xoodoo_state as a 3d array to hold a xoodoo state
typedef unsigned char xoodoo_state[XOODOO_NUMOF_PLANES][XOODOO_NUMOF_SHEETS][XOODOO_LANESIZE];

/**
 * @brief Initialize xoodoo state
 *
 * @param state State object to initialize
 */
void xoodoo_init_empty_state(xoodoo_state *state);

/**
 * @brief Do xoodoo permutation on state
 *
 * @param state state to permutate
 * @param number_of_rounds number of rounds (Note: Maximum 12 since there are only 12 round constants defined in xoodoo.h)
 */
void xoodoo_permute(xoodoo_state *state, unsigned int number_of_rounds);

#endif