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
#include "xoodoo.h"

// Define internal byte vector type
typedef unsigned char xoodyak_byte_vector[XOODYAK_STATESIZE];

/* Helper functions */

/**
 * @brief Fill a xoodyak byte vector from a xoodyak state
 *
 * @param [in] state Source state
 * @param [out] byte_array Destination byte vector
 */
void state_to_byte_vector(xoodyak_state *state, xoodyak_byte_vector *byte_vector)
{
    for (int z = 0; z < XOODYAK_LANESIZE; z++)
    {
        for (int x = 0; x < XOODYAK_NUMOF_SHEETS; x++)
        {
            for (int y = 0; y < XOODYAK_NUMOF_PLANES; y++)
            {
                // source: https://kuleuven-diepenbeek.github.io/hwswcodesign-course/400_xoodyak/401_xoodoo/#xoodoo-state
                (*byte_vector)[z + XOODYAK_LANESIZE * x + XOODYAK_LANESIZE * XOODYAK_NUMOF_SHEETS * y] = (*state)[y][x][z];
            }
        }
    }
}

/**
 * @brief Fill a xoodyak state from a xoodyak byte vector
 *
 * @param [out] state Destination state
 * @param [in] byte_vector Source byte vector
 */
void byte_vector_to_state(xoodyak_state *state, xoodyak_byte_vector *byte_vector)
{
    for (int z = 0; z < XOODYAK_LANESIZE; z++)
    {
        for (int x = 0; x < XOODYAK_NUMOF_SHEETS; x++)
        {
            for (int y = 0; y < XOODYAK_NUMOF_PLANES; y++)
            {
                // source: https://kuleuven-diepenbeek.github.io/hwswcodesign-course/400_xoodyak/401_xoodoo/#xoodoo-state
                (*state)[y][x][z] = (*byte_vector)[z + XOODYAK_LANESIZE * x + XOODYAK_LANESIZE * XOODYAK_NUMOF_SHEETS * y];
            }
        }
    }
}

/* Internal interface */

/**
 * @brief XOODYAK internal interface: DOWN
 *
 * @param c Cyclist struct
 * @param [in] Xi Message
 * @param [in] Xi_len Message length
 * @param cd Breadcrumb
 *
 * @return XOODYAK_SUCCESS if successful
 */
int cyclist_down(struct cyclist *c, unsigned char *Xi, unsigned int Xi_len, short unsigned int cd)
{
    // source: https://eprint.iacr.org/2018/767.pdf - Algorithm 5
    // source: https://kuleuven-diepenbeek.github.io/hwswcodesign-course/400_xoodyak/403_cyclist/#down

    // Return error if length of Xi is to big
    if (Xi_len > XOODYAK_STATESIZE - 2)
    {
        return -1;
    }

    // Create new byte vector {Xi || 0x01 || 0x00 (0+) || cd & 0x01}
    xoodyak_byte_vector new_vector;
    for (int i = 0; i < Xi_len; i++)
    {
        new_vector[i] = Xi[i];
    }
    new_vector[Xi_len] = 0x01;
    for (int i = (Xi_len + 1); i < (XOODYAK_STATESIZE - 1); i++)
    {
        new_vector[i] = 0x00;
    }
    new_vector[XOODYAK_STATESIZE - 1] = (c->mode == XOODYAK_MODE_HASH) ? cd & 0x01 : cd;

    // Create byte vector represenstation of cyclist state
    xoodyak_byte_vector state_vector;
    state_to_byte_vector(&(c->state), &state_vector);

    // XOR new vector with state vector
    // todo: Create a better implementation to skip byte vector to state conversion later
    for (int i = 0; i < XOODYAK_STATESIZE; i++)
    {
        state_vector[i] ^= new_vector[i];
    }

    // Convert back to 3d state representation
    byte_vector_to_state(&(c->state), &state_vector);

    // Set phase down
    c->phase = XOODYAK_PHASE_DOWN;

    // Return success
    return XOODYAK_SUCCESS;
}

/**
 * @brief XOODYAK internal interface: UP
 *
 * @param c Cyclist
 * @param [out] Yi Digest
 * @param [in] Yi_len Digest length
 * @param Cu Breadcrumb
 *
 * @return XOODYAK_SUCCESS if successful
 */
int cyclist_up(struct cyclist *c, unsigned char *Yi, unsigned int Yi_len, unsigned char Cu)
{
    // source: https://eprint.iacr.org/2018/767.pdf - Algorithm 5
    // note: Mode is always hash in this implementation
    // todo: Add doxygen documentation
    // todo: Cu is never used, is this correct?

    // Return error if length of Yi is to big
    if (Yi_len > XOODYAK_STATESIZE)
    {
        return -1;
    }

    // Do permutation
    xoodoo_permute(&(c->state), XOODYAK_XOODOO_ROUND_AMOUNT);

    // Fill Yi with correct bytes
    // todo: Create a better implementation to skip intermediate state vector creation
    xoodyak_byte_vector state_vector;
    state_to_byte_vector(&(c->state), &state_vector);
    for (int i = 0; i < Yi_len; i++)
    {
        Yi[i] = state_vector[i];
    }

    // Set phase up
    c->phase = XOODYAK_PHASE_UP;

    // Return success
    return XOODYAK_SUCCESS;
}

/**
 * @brief XOODYAK internal interface: ABSORB_ANY
 *
 * @param c Cyclist
 * @param X Message
 * @param X_len Message length
 * @param r Bitrate
 * @param cd Breadcrumb
 *
 * @return XOODYAK_SUCCESS if successful
 */
int absorb_any(struct cyclist *c, unsigned char *X, unsigned int X_len, unsigned int r, unsigned int cd)
{
    // source: https://eprint.iacr.org/2018/767.pdf#page=20 - Algorithm 5
    // source: https://github.com/XKCP/XKCP/blob/6a5815f7d606135abef8899a4d3861123fc184c9/lib/high/Xoodyak/Cyclist.inc#L100

    int bytes_remaining = X_len; // Amount of bytes that have yet to be absorbed
    unsigned char Yi;            // Output string of UP which is discarded
    unsigned int cd_down = cd;   // Breadcrumb of DOWN operation = first block ? cd : 0x00

    // Create local Xi and Xi_len for DOWN function
    unsigned char *Xi = X;
    unsigned int Xi_len;

    do
    {
        // UP if not done as last
        if (c->phase != XOODYAK_PHASE_UP)
        {
            if (cyclist_up(c, &Yi, 0, 0) != XOODYAK_SUCCESS)
            {
                return XOODYAK_ERR_CYCLIST_UP;
            }
        }

        // Calculate Xi length (minimum of bytes_remaining and bitrate)
        Xi_len = (bytes_remaining > r) ? r : bytes_remaining;

        // DOWN
        if (cyclist_down(c, Xi, Xi_len, cd_down) != XOODYAK_SUCCESS)
        {
            return XOODYAK_ERR_CYCLIST_DOWN;
        }

        // Setup for next block
        bytes_remaining -= Xi_len; // Subtract block from bytes_remaining
        Xi += Xi_len;              // Point to next block
        cd_down = 0x00;            // Set to 0x00 after first block
    } while (bytes_remaining > 0);

    // Return success
    return XOODYAK_SUCCESS;
}

/**
 * @brief XOODYAK internal interface: SQUEEZE_ANY
 *
 * @param c Cyclist
 * @param Y Digest
 * @param Y_len Digest length
 * @param r Bitrate
 * @param cu Breadcrumb
 *
 *  * @return XOODYAK_SUCCESS if successful
 */
int squeeze_any(struct cyclist *c, unsigned char *Y, unsigned int Y_len, unsigned int r, unsigned int cu)
{
    // todo: Implement squeeze any
    // source: https://eprint.iacr.org/2018/767.pdf#page=20 - Algorithm 5
    // source: https://github.com/XKCP/XKCP/blob/6a5815f7d606135abef8899a4d3861123fc184c9/lib/high/Xoodyak/Cyclist.inc#L150

    unsigned int bytes_remaining = Y_len; // Amount of bytes that have yet to be squeezed
    unsigned char Xi;                     // Input string of DOWN which shouldn't be used since Xi_len is 0
    unsigned int cu_up = cu;              // Breadcrumb of UP operation = first block ? cu : 0x00
    unsigned int first_block = 1;

    // Create local Yi and Yi_len for UP function
    unsigned char *Yi = Y;
    unsigned int Yi_len;

    while (bytes_remaining > 0)
    {
        Yi_len = (bytes_remaining > r) ? r : bytes_remaining; // Calculate Yi length (minimum of bytes_remaining and bitrate)

        // DOWN: do every time except first block
        if (first_block == 0)
        {
            cyclist_down(c, &Xi, 0, 0x00); // fixme: return XOODYAK_ERR_CYCLIST_DOWN in case or failure
        }
        else
        {
            first_block = 0;
        }

        // UP
        cyclist_up(c, Yi, Yi_len, cu_up); // fixme: return XOODYAK_ERR_CYCLIST_UP in case or failure

        // Setup for next block
        bytes_remaining -= Yi_len; // Subtract block from bytes_remaining
        Yi += Yi_len;              // Point to next block
        cu_up = 0x00;              // Set to 0x00 after first block
    }

    // Return success
    return XOODYAK_SUCCESS;
}

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
    absorb_any(c, m, mlen, c->Rabsorb, 0x03); // fixme: Errocodes are lost here
}

void cyclist_squeeze(cyclist *c, unsigned char *m, int mlen, unsigned char breadcrumb)
{
    squeeze_any(c, m, mlen, c->Rsqueeze, breadcrumb); // fixme: Errocodes are lost here
}

#ifdef __linux__
#include <stdio.h>
void cyclist_print(cyclist *c)
{
    printf("Cyclist:\n");
    printf("  Mode: %d (%s)\n", c->mode, (c->mode == XOODYAK_MODE_HASH) ? "Hash" : "Key");
    printf("  Absorb rate: %d\n", c->Rabsorb);
    printf("  Squeeze rate: %d\n", c->Rsqueeze);
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
