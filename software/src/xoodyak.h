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

#define XOODYAK_NUMOF_SHEETS 4 // this is the X coordinate
#define XOODYAK_NUMOF_PLANES 3 // this is the Y coordinate
#define XOODYAK_LANESIZE 4 // this is the Z coordinate

typedef unsigned char xoodyak_lane[XOODYAK_LANESIZE];
typedef xoodyak_lane xoodyak_plane[XOODYAK_NUMOF_SHEETS];
typedef xoodyak_plane xoodyak_state[XOODYAK_NUMOF_PLANES];

struct cyclist {
    xoodyak_state state;
    unsigned char phase;
    unsigned char mode;
    unsigned char Rabsorb;
    unsigned char Rsqueeze;
};

/**
 * @brief Create a cyclist
 * 
 * @param c Cyclist object to fill
 */
void cyclist_initialise_hash(struct cyclist *c);

/**
 * @brief Absorb the message
 * 
 * @param c Cyclist to use
 * @param m Message
 * @param mlen Message lenght
 */
void cyclist_absorb(struct cyclist *c, unsigned char *m, int mlen);

/**
 * @brief Squeeze out the digest
 * 
 * @param c Cyclist to use
 * @param m Message
 * @param mlen Message lenght
 * @param breadcrumb 
 */
void cyclist_squeeze(struct cyclist *c, unsigned char *m, int mlen, unsigned char breadcrumb);

#endif