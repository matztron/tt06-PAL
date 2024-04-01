#!/usr/bin/env bash

# do 'chmod +x latch_sim.sh' on this script to execute it :)

OUTPUT_PATH="./output"
SRC_PATH="../../src"
TB_PATH="."

# in case there are already old files: delete them to avoid confusion!
rm ${OUTPUT_PATH}/*

iverilog -o ${OUTPUT_PATH}/SIM ${TB_PATH}/testbench.v ${SRC_PATH}/project.v ${SRC_PATH}/PAL.v ${SRC_PATH}/SR.v ${SRC_PATH}/crosspoint.v ${SRC_PATH}/REDUCE_AND.v ${SRC_PATH}/REDUCE_OR.v ${SRC_PATH}/STRIDE.v
vvp ${OUTPUT_PATH}/SIM
gtkwave ${OUTPUT_PATH}/SIM.vcd &