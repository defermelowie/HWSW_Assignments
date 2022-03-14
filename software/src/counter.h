/*
 * counter.h
 */
#ifndef COUNTER_DRIVER_H
#define COUNTER_DRIVER_H

#define COUNTER_BASEADDRESS 0x81000000
#define COUNTER_REG0_ADDRESS (COUNTER_BASEADDRESS + 0 * 4)
#define COUNTER_REG1_ADDRESS (COUNTER_BASEADDRESS + 1 * 4)

#define COUNTER_CR (*(volatile unsigned int *)COUNTER_REG0_ADDRESS)
#define COUNTER_VALUE (*(volatile unsigned int *)COUNTER_REG1_ADDRESS)

#define COUNTER_CR_ENABLE 0x00000001U
#define COUNTER_CR_CLEAR 0x00000002U

#define counter_clear()                  \
    {                                    \
        COUNTER_CR |= COUNTER_CR_CLEAR;  \
        COUNTER_CR &= ~COUNTER_CR_CLEAR; \
    }
#define counter_start() (COUNTER_CR |= COUNTER_CR_ENABLE)
#define counter_stop() (COUNTER_CR &= ~COUNTER_CR_ENABLE)
#define counter_get_value() (COUNTER_VALUE)

#endif