#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/home/lowie/Programs/Xilinx/Vivado/2021.1/ids_lite/ISE/bin/lin64:/home/lowie/Programs/Xilinx/Vivado/2021.1/bin
else
  PATH=/home/lowie/Programs/Xilinx/Vivado/2021.1/ids_lite/ISE/bin/lin64:/home/lowie/Programs/Xilinx/Vivado/2021.1/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/lowie/Documents/IIW/S8/HW_SW_Codesign/exercises/E101/E101.runs/synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log picorv32_axi.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source picorv32_axi.tcl
