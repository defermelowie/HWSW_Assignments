//-------------------------------------------------------------
// Hardware software codesign
//-------------------------------------------------------------
// Course assignments
//
// File: xoodoo.c (c)
// By: Lowie Deferme (UHasselt/KULeuven - FIIW)
// On: 21 April 2022
//-------------------------------------------------------------

#include "xoodoo.h"

#ifdef XOODOO_HW
#include "print.h" // note: For debugging
#endif

#ifdef __linux__
#include <stdio.h>
#endif

/* Intern */ // Most Intern functions are not used in case of hardware offload

#ifndef XOODOO_HW
// Define alternative byte vector type to hold state data
typedef unsigned char xoodoo_byte_vector[XOODOO_NUMOF_PLANES * XOODOO_NUMOF_SHEETS * XOODOO_LANESIZE];
#endif

#ifndef XOODOO_HW
// Round constants to constant array
const unsigned int round_constants[] = XOODOO_ROUND_CONSTANTS;
#endif

/**
 * @brief Conversion of state data from 3d state to lane array
 *
 * @param state 3d state to convert from
 * @param vector lane array to convert to
 */
void xoodoo_state_2_lane_array(xoodoo_state *state, xoodoo_lane_array *vector)
{
    for (int y = 0; y < XOODOO_NUMOF_PLANES; y++)
    {
        for (int x = 0; x < XOODOO_NUMOF_SHEETS; x++)
        {
            // Source: https://kuleuven-diepenbeek.github.io/hwswcodesign-course/400_xoodyak/401_xoodoo/#xoodoo-state
            unsigned int lane = (*state)[y][x][0] | ((*state)[y][x][1] << 8) | ((*state)[y][x][2] << 16) | ((*state)[y][x][3] << 24);
            (*vector)[y][x] = lane;
        }
    }
}

/**
 * @brief Conversion of state data from lane array to 3d state
 *
 * @param state 3d state to convert to
 * @param vector lane array to convert from
 */
void xoodoo_lane_array_2_state(xoodoo_state *state, xoodoo_lane_array *vector)
{
    for (int x = 0; x < XOODOO_NUMOF_SHEETS; x++)
    {
        for (int y = 0; y < XOODOO_NUMOF_PLANES; y++)
        {
            (*state)[y][x][0] = 0xff & ((*vector)[y][x] >> 8 * 0);
            (*state)[y][x][1] = 0xff & ((*vector)[y][x] >> 8 * 1);
            (*state)[y][x][2] = 0xff & ((*vector)[y][x] >> 8 * 2);
            (*state)[y][x][3] = 0xff & ((*vector)[y][x] >> 8 * 3);
        }
    }
}

#ifndef XOODOO_HW
/**
 * @brief Do a cyclic shift of 32 bit words
 *
 * @param i 32 bit word to shift
 * @param n shift amount
 * @return uint32_t
 */
uint32_t cyclic_shift_left(uint32_t i, int n)
{
    return (i << n % 32) | (i >> (32 - n));
}
#endif

#ifndef XOODOO_HW
/**
 * @brief Copy lane array form src to dst
 *
 * @param src array to copy from
 * @param dst array to copy to
 */
void copy_lane_array(xoodoo_lane_array *src, xoodoo_lane_array *dst)
{
    for (int y = 0; y < XOODOO_NUMOF_PLANES; y++)
    {
        for (int x = 0; x < XOODOO_NUMOF_SHEETS; x++)
        {
            (*dst)[y][x] = (*src)[y][x];
        }
    }
}
#endif

#ifdef __linux__
void print_state(xoodoo_state *state)
{
    printf("State:\n");
    for (int y = 0; y < XOODOO_NUMOF_PLANES; y++)
    {
        printf("    Plane %d:", y);
        for (int z = 0; z < XOODOO_LANESIZE; z++)
        {
            printf("\n      ");
            for (int x = 0; x < XOODOO_NUMOF_SHEETS; x++)
            {
                printf("0x%x ", (*state)[y][x][z]);
            }
        }
        printf("\n");
    }
}

void print_lane_array(xoodoo_lane_array *lane_array)
{
    printf("State:\n");
    for (int y = 0; y < XOODOO_NUMOF_PLANES; y++)
    {
        printf("    Plane %d:\n", y);
        for (int x = 0; x < XOODOO_NUMOF_SHEETS; x++)
        {
            printf("\t0x%08x\n", (*lane_array)[y][x]);
        }
    }
    printf("\n");
}
#endif

#ifndef XOODOO_HW
/**
 * @brief Do a xoodoo permutation round
 *
 * @note
 *  Source: https://eprint.iacr.org/2018/767.pdf - Algorithm 1
 *  Source: https://keccak.team/xoodoo.html
 *  Source: https://github.com/XKCP/XKCP/blob/master/lib/low/Xoodoo/ref/Xoodoo-reference.c
 *
 * @param state State to do round on
 * @param round_constant Round constant to add
 */
void xoodoo_round(xoodoo_state *state, uint32_t round_constant)
{
    // Setup for easier calculation using 32 bit lanes
    // printf("[XOODOO] Round setup\n");
    xoodoo_lane_array A;
    xoodoo_state_2_lane_array(state, &A);

#ifdef __linux__
    printf("Round in:\n");
    print_lane_array(&A);
#endif

    // Theta
    // printf("[XOODOO] Theta\n");
    uint32_t P[XOODOO_NUMOF_SHEETS];
    for (unsigned int x = 0; x < XOODOO_NUMOF_SHEETS; x++)
        P[x] = A[0][x] ^ A[1][x] ^ A[2][x];
    uint32_t E[XOODOO_NUMOF_SHEETS];
    for (unsigned int x = 0; x < XOODOO_NUMOF_SHEETS; x++)
        E[x] = cyclic_shift_left(P[(x - 1) % XOODOO_NUMOF_SHEETS], 5) ^ cyclic_shift_left(P[(x - 1) % XOODOO_NUMOF_SHEETS], 14);
    for (unsigned int x = 0; x < XOODOO_NUMOF_SHEETS; x++)
        for (int y = 0; y < XOODOO_NUMOF_PLANES; y++)
            A[y][x] ^= E[x];
#ifdef __linux__
    printf("Theta out:\n");
    print_lane_array(&A);
#endif
    // Rho west
    // printf("[XOODOO] Rho west\n");
    xoodoo_lane_array T; // Temporary lane array
    for (unsigned int x = 0; x < XOODOO_NUMOF_SHEETS; x++)
    {
        T[0][x] = A[0][x];                             // Plane 0
        T[1][x] = A[1][(x - 1) % XOODOO_NUMOF_SHEETS]; // Plane 1
        T[2][x] = cyclic_shift_left(A[2][x], 11);      // Plane 2
    }
#ifdef __linux__
    printf("Rho west out:\n");
    print_lane_array(&T);
#endif
    // Iota
    // printf("[XOODOO] Iota\n");
    T[0][0] ^= round_constant;
#ifdef __linux__
    printf("Iota out:\n");
    print_lane_array(&T);
#endif
    // Chi
    // printf("[XOODOO] Chi\n");
    xoodoo_lane_array B;
    for (unsigned int x = 0; x < XOODOO_NUMOF_SHEETS; x++)
        for (unsigned int y = 0; y < XOODOO_NUMOF_PLANES; y++)
            B[y][x] = T[y][x] ^ (~T[(y + 1) % XOODOO_NUMOF_PLANES][x] & T[(y + 2) % XOODOO_NUMOF_PLANES][x]);
#ifdef __linux__
    printf("Chi out:\n");
    print_lane_array(&B);
#endif
    // Pho east
    // printf("[XOODOO] Rho east\n");
    for (unsigned int x = 0; x < XOODOO_NUMOF_SHEETS; x++)
    {
        A[0][x] = B[0][x];                                                   // Plane 0
        A[1][x] = cyclic_shift_left(B[1][x], 1);                             // Plane 1
        A[2][x] = cyclic_shift_left(B[2][(x - 2) % XOODOO_NUMOF_SHEETS], 8); // Plane 2
    }
#ifdef __linux__
    printf("Rho east out:\n");
    print_lane_array(&A);
#endif
    // Convert back to state
    xoodoo_lane_array_2_state(state, &A);
}
#endif

/* API */

void xoodoo_init_empty_state(xoodoo_state *state)
{
    for (int z = 0; z < XOODOO_LANESIZE; z++)
    {
        for (int y = 0; y < XOODOO_NUMOF_PLANES; y++)
        {
            for (int x = 0; x < XOODOO_NUMOF_SHEETS; x++)
            {
                (*state)[y][x][z] = 0; // INFO: Init new xoodoo state to zero
            }
        }
    }
}

#ifndef XOODOO_HW
void xoodoo_permute(xoodoo_state *state, unsigned int number_of_rounds)
{
    for (int round = 0; round < number_of_rounds; round++)
    {
#ifdef __linux__
        printf("Round %d:\n", round);
#endif
        xoodoo_round(state, round_constants[round]);
    }
}
#else
void xoodoo_permute(xoodoo_state *state, unsigned int number_of_rounds)
{

    // Copy state to hardware
    xoodoo_state_2_lane_array(state, ((xoodoo_lane_array *)XOODOO_HW_LANE_ARRAY_OUT)); // Fixme: out of bounds if size > 12 lanes

    // Set number of rounds
    XOODOO_HW_CONTROL_REG &= ~XOODOO_HW_CONTROL_NOR_MASK;                           // Clear previous value
    XOODOO_HW_CONTROL_REG |= (XOODOO_HW_CONTROL_NOR_MASK & (number_of_rounds - 1)); // Set new value

    // Set data valid
    XOODOO_HW_CONTROL_REG |= XOODOO_HW_CONTROL_DATA_VALID;

    // Poll if hw is done
    while ((XOODOO_HW_STATUS_REG & XOODOO_HW_STATUS_FIN) == 0)
        ;

    // Get state from hardware
    xoodoo_lane_array_2_state(state, ((xoodoo_lane_array *)XOODOO_HW_LANE_ARRAY_IN)); // Fixme: out of bounds if size > 12 lanes

    // Clear data valid
    XOODOO_HW_CONTROL_REG &= ~XOODOO_HW_CONTROL_DATA_VALID;
}
#endif