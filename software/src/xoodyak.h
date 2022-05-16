//-------------------------------------------------------------
// Hardware software codesign
//-------------------------------------------------------------
// Course assignments
//
// File: xoodyak.h (c)
// By: Lowie Deferme (UHasselt/KULeuven - FIIW)
// On: 21 April 2022
//-------------------------------------------------------------

#ifndef XOODYAK_H
#define XOODYAK_H

#include "xoodoo.h"

// Define size constants
#define XOODYAK_NUMOF_SHEETS XOODOO_NUMOF_SHEETS // this is the X coordinate
#define XOODYAK_NUMOF_PLANES XOODOO_NUMOF_PLANES // this is the Y coordinate
#define XOODYAK_LANESIZE XOODOO_LANESIZE         // this is the Z coordinate
#define XOODYAK_STATESIZE (XOODOO_NUMOF_SHEETS * XOODOO_NUMOF_PLANES * XOODOO_LANESIZE)

// Define modes
#define XOODYAK_MODE_HASH 1
#define XOODYAK_MODE_KEY 2 // NOT IMPLEMENTED

// Define bitrates
#define XOODYAK_R_ABSORB_HASH 16
#define XOODYAK_R_SQUEEZE_HASH 16

// Define phases
#define XOODYAK_PHASE_UP 1
#define XOODYAK_PHASE_DOWN 2

// Define xoodoo number of rounds
#define XOODYAK_XOODOO_ROUND_AMOUNT 12

// Define errorcodes
#define XOODYAK_SUCCESS 0
#define XOODYAK_ERR_CYCLIST_UP -1
#define XOODYAK_ERR_CYCLIST_DOWN -2

typedef unsigned char xoodyak_lane[XOODYAK_LANESIZE];
typedef xoodyak_lane xoodyak_plane[XOODYAK_NUMOF_SHEETS];
typedef xoodyak_plane xoodyak_state[XOODYAK_NUMOF_PLANES];

struct cyclist
{
    xoodyak_state state;
    unsigned char phase;
    unsigned char mode;
    unsigned char Rabsorb;
    unsigned char Rsqueeze;
} typedef cyclist;

/**
 * @brief Initialize a new cyclist to hash mode
 *
 * @param c Cyclist object to initialize
 */
void cyclist_initialise_hash(cyclist *c);

/**
 * @brief Absorb the message
 *
 * @param c Cyclist to use
 * @param m Message
 * @param mlen Message length
 */
void cyclist_absorb(cyclist *c, unsigned char *m, int mlen);

/**
 * @brief Squeeze out the digest
 *
 * @param c Cyclist to use
 * @param m Message
 * @param mlen Message leng
 * @param breadcrumb
 */
void cyclist_squeeze(cyclist *c, unsigned char *m, int mlen, unsigned char breadcrumb);

#ifdef __linux__
/**
 * @brief Print cyclist to stdout (Only for testing on linux)
 *
 * @param c The cyclist to print
 */
void cyclist_print(cyclist *c);
#endif

#endif