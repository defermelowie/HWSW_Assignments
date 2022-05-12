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

#include <stdint.h>

// Use hardware implementation
#define XOODOO_HW // note: comment out in order to use software implementation

// source: https://eprint.iacr.org/2018/767.pdf#6
#define XOODOO_NUMOF_SHEETS 4 // The maximum X coordinate is 4
#define XOODOO_NUMOF_PLANES 3 // The maximum Y coordinate is 3
#define XOODOO_LANESIZE 4     // The maximum Z coordinate is 4

// Define round constants, only needed in software
// source: https://eprint.iacr.org/2018/767.pdf#page=30 - Table 5
#ifndef XOODOO_HW
#define XOODOO_ROUND_CONSTANTS \
    {                          \
        0x00000058,            \
            0x00000038,        \
            0x000003C0,        \
            0x000000D0,        \
            0x00000120,        \
            0x00000014,        \
            0x00000060,        \
            0x0000002C,        \
            0x00000380,        \
            0x000000F0,        \
            0x000001A0,        \
            0x00000012         \
    }
#endif

// Define xoodoo_state as a 3d array to hold a xoodoo state
typedef unsigned char xoodoo_state[XOODOO_NUMOF_PLANES][XOODOO_NUMOF_SHEETS][XOODOO_LANESIZE];

// Define alternative byte vector type to hold state data
typedef uint32_t xoodoo_lane_array[XOODOO_NUMOF_PLANES][XOODOO_NUMOF_SHEETS];

/* Extra definitions for hardware implementation */

// Hardware constans & functions
#ifdef XOODOO_HW

#define XOODOO_HW_BASEADDRESS 0x81100000

#define XOODOO_HW_CONTROL_REG (*(volatile unsigned int *)(XOODOO_HW_BASEADDRESS + 0 * 4))        // Control register
#define XOODOO_HW_LANE_ARRAY_OUT ((volatile xoodoo_lane_array *)(XOODOO_HW_BASEADDRESS + 1 * 4)) // Address for lane array from SW -> HW
#define XOODOO_HW_STATUS_REG (*(volatile unsigned int *)(XOODOO_HW_BASEADDRESS + 13 * 4))        // Status register
#define XOODOO_HW_LANE_ARRAY_IN ((volatile xoodoo_lane_array *)(XOODOO_HW_BASEADDRESS + 14 * 4)) // Address for lane array from HW -> SW

#define XOODOO_HW_CONTROL_NOR_MASK 0x0000000f   // Bits 0..3
#define XOODOO_HW_CONTROL_DATA_VALID 0x00000010 // Bit 4

#define XOODOO_HW_STATUS_FIN 0x00000001 // Bit 0

#endif

/* API */

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