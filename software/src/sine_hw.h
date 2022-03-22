//-------------------------------------------------------------
// Hardware software codesign
//-------------------------------------------------------------
// Course assignments
//
// File: sine_hw.h (c)
// By: Lowie Deferme (UHasselt/KULeuven - FIIW)
// On: 21 March 2022
//-------------------------------------------------------------

#ifndef SINE_DRIVER_H
#define SINE_DRIVER_H

#define SINE_BASE_ADDR 0x81100000

#define SINE_DIN_REG (*(volatile unsigned int *)(SINE_BASE_ADDR + 0 * 4))
#define SINE_DOUT_REG (*(volatile unsigned int *)(SINE_BASE_ADDR + 1 * 4))

uint32_t sin(int alpha)
{
    SINE_DIN_REG = alpha;
    return SINE_DOUT_REG;
}
#endif